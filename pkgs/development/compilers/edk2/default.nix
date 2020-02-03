{
  stdenv,
  clangStdenv,
  fetchgit,
  fetchpatch,
  libuuid,
  python3,
  iasl,
  bc,
  clang_9,
  llvmPackages_9,
  overrideCC,
  lib,
}:

let
  pythonEnv = python3.withPackages (ps: [ps.tkinter]);

targetArch = if stdenv.isi686 then
  "IA32"
else if stdenv.isx86_64 then
  "X64"
else if stdenv.isAarch64 then
  "AARCH64"
else
  throw "Unsupported architecture";

buildStdenv = if stdenv.isDarwin then
  overrideCC clangStdenv [ clang_9 llvmPackages_9.llvm llvmPackages_9.lld ]
else
  stdenv;

buildType = if stdenv.isDarwin then
    "CLANGPDB"
  else
    "GCC5";

  edk2-non-osi = fetchgit {
    url = "https://github.com/tianocore/edk2-non-osi";
    rev = "cf4fdbe1023f0e0cc8e22be17addf779d75074d0";
    sha256 = "sha256-2SSoSFhlSUZsDLyEArb4VJju/HqNfQNKztqNNqGtX04=";
  };
  edk2-platforms = fetchgit {
    url = "https://github.com/tianocore/edk2-platforms";
    rev = "92daaf2b276eca2cfe3b07380d3bb7a3853271df";
    sha256 = "sha256-1k6zf36o/8PwASlNFT8j8djO8I/26lJlTq64GxSEXQA=";
  };

edk2 = buildStdenv.mkDerivation {
  pname = "edk2";
  version = "202011";

  # submodules
  src = fetchgit {
    url = "https://github.com/tianocore/edk2";
    rev = "edk2-stable${edk2.version}";
    sha256 = "1fvlz1z075jr6smq9qa0asy6fxga1gljcfd0764ypzy1mw963c9s";
  };

  buildInputs = [ libuuid pythonEnv ];

  makeFlags = [ "-C BaseTools" ]
    ++ lib.optional (stdenv.cc.isClang) [ "BUILD_CC=clang BUILD_CXX=clang++ BUILD_AS=clang" ];

  NIX_CFLAGS_COMPILE = "-Wno-return-type" + lib.optionalString (stdenv.cc.isGNU) " -Wno-error=stringop-truncation";

  hardeningDisable = [ "format" "fortify" ];

  installPhase = ''
    mkdir -vp $out
    mv -v BaseTools $out/
    mv -v edksetup.sh $out/

    mkdir -vp $out/edk2-platforms
    cp -av ${edk2-platforms}/* $out/edk2-platforms/
    mkdir -vp $out/edk2-non-osi
    cp -av ${edk2-non-osi}/* $out/edk2-non-osi/
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Intel EFI development kit";
    homepage = "https://sourceforge.net/projects/edk2/";
    license = licenses.bsd2;
    platforms = [ "x86_64-linux" "i686-linux" "aarch64-linux" "x86_64-darwin" ];
  };

  passthru = {
    mkDerivation = projectDscPath: attrs: buildStdenv.mkDerivation ({
      inherit (edk2) src;

      buildInputs = [ bc pythonEnv ] ++ attrs.buildInputs or [];

      prePatch = ''
        rm -rf BaseTools
        ln -sv ${edk2}/BaseTools BaseTools
        ln -sv ${edk2}/edk2-platforms edk2-platforms
        ln -sv ${edk2}/edk2-non-osi edk2-non-osi
      '';

      configurePhase = ''
        runHook preConfigure
        export WORKSPACE="$PWD"
        export PACKAGES_PATH=$WORKSPACE:$WORKSPACE/edk2-platforms:$WORKSPACE/edk2-non-osi
        . ${edk2}/edksetup.sh BaseTools
        runHook postConfigure
      '';

      buildPhase = ''
        runHook preBuild
        build -a ${targetArch} -b RELEASE -t ${buildType} -p ${projectDscPath} -n $NIX_BUILD_CORES $buildFlags
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mv -v Build/*/* $out
        runHook postInstall
      '';
    } // removeAttrs attrs [ "buildInputs" ]);
  };
};

in

edk2
