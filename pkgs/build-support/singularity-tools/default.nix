{ runCommand
, lib
, stdenv
, storeDir ? builtins.storeDir
, writeScript
, singularity
, writeReferencesToFile
, bash
, vmTools
, gawk
, util-linux
, runtimeShell
, e2fsprogs
, nix
, closureInfo
, lib
}:

# WARNING: this API is unstable and may be subject to backwards-incompatible changes in the future.
let

  mkDbExtraCommand = contents: let
    contentsList = if builtins.isList contents then contents else [ contents ];
  in ''
    echo "Generating the nix database..."
    echo "Warning: only the database of the deepest Nix layer is loaded."
    echo "         If you want to use nix commands in the container, it would"
    echo "         be better to only have one layer that contains a nix store."

    export NIX_REMOTE=local?root=$PWD
    # A user is required by nix
    # https://github.com/NixOS/nix/blob/9348f9291e5d9e4ba3c4347ea1b235640f54fd79/src/libutil/util.cc#L478
    export USER=nobody
    ${nix}/bin/nix-store --load-db < ${closureInfo {rootPaths = contentsList;}}/registration

    mkdir -p nix/var/nix/gcroots/docker/
    for i in ${lib.concatStringsSep " " contentsList}; do
    ln -s $i nix/var/nix/gcroots/docker/$(basename $i)
    done;
  '';

in
rec {
  shellScript = name: text:
    writeScript name ''
      #!${runtimeShell}
      set -e
      ${text}
    '';

  mkLayer = {
    name,
    contents ? [],
    extraCommands ? ""
  }:
    runCommand "singularity-layer-${name}" {
      inherit contents extraCommands;
    } ''
      mkdir $out
      for f in $contents ; do
        cp -ra $f $out/
      done
    '';

  buildImage = {
    name,
    contents ? [],
    diskSize ? 1024,
    runScript ? "#!${stdenv.shell}\nexec /bin/sh",
    runAsRoot ? null,
    extraCommands ? ""
  }:
    let layer = mkLayer {
          inherit name;
          contents = contents ++ [ bash runScriptFile ];
          };
        runAsRootFile = shellScript "run-as-root.sh" runAsRoot;
        runScriptFile = shellScript "run-script.sh" runScript;
        result = vmTools.runInLinuxVM (
          runCommand "singularity-image-${name}.img" {
            buildInputs = [ singularity e2fsprogs util-linux gawk ];
            layerClosure = writeReferencesToFile layer;
            preVM = vmTools.createEmptyImage {
              size = diskSize;
              fullName = "singularity-run-disk";
            };
          }
          ''
            rm -rf $out
            mkdir disk
            mkfs -t ext3 -b 4096 /dev/${vmTools.hd}
            mount /dev/${vmTools.hd} disk
            mkdir -p disk/img
            cd disk/img
            mkdir proc sys dev

            # Run root script
            ${lib.optionalString (runAsRoot != null) ''
              mkdir -p ./${storeDir}
              mount --rbind ${storeDir} ./${storeDir}
              unshare -imnpuf --mount-proc chroot ./ ${runAsRootFile}
              umount -R ./${storeDir}
            ''}

            # Build /bin and copy across closure
            mkdir -p bin nix/store
            for f in $(cat $layerClosure) ; do
              cp -ar $f ./$f
            done

            for c in ${toString contents} ; do
              for f in $c/bin/* ; do
                if [ ! -e bin/$(basename $f) ] ; then
                  ln -s $f bin/
                fi
              done
            done

            if [[ -n $extraCommands ]]; then
              (eval "$extraCommands")
            fi

            # Create runScript and link shell
            if [ ! -e bin/sh ]; then
              ln -s ${runtimeShell} bin/sh
            fi
            mkdir -p .singularity.d
            ln -s ${runScriptFile} .singularity.d/runscript

            # Fill out .singularity.d
            mkdir -p .singularity.d/env
            touch .singularity.d/env/94-appsbase.sh

            cd ..
            mkdir -p /var/singularity/mnt/{container,final,overlay,session,source}
            echo "root:x:0:0:System administrator:/root:/bin/sh" > /etc/passwd
            echo > /etc/resolv.conf
            TMPDIR=$(pwd -P) singularity build $out ./img
          '');

    in result;

  # Build an image and populate its nix database with the provided
  # contents. The main purpose is to be able to use nix commands in
  # the container.
  # Be careful since this doesn't work well with multilayer.
  buildImageWithNixDb = args@{ contents ? null, extraCommands ? "", ... }: (
    buildImage (args // {
      extraCommands = (mkDbExtraCommand contents) + extraCommands;
    })
  );

}
