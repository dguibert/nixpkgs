{ stdenv, fetchurl
, libX11, glib, xorg, fontconfig, freetype
, zlib, libpng12, libICE, libXrender, cups
, lzma
, fetchFromGitHub
}:

let
  ttf-wps-fonts = fetchFromGitHub {
    owner = "iamdh4";
    repo = "ttf-wps-fonts";
    rev = "master";
    sha256 = "1bwn54mx0zh8yigf5f16wypwfmnp88hx6mjxh8wckaipf49525d1";
  };

  bits = if stdenv.hostPlatform.system == "x86_64-linux" then "x86_64"
         else "x86";

  version = "10.1.0.6757";
in stdenv.mkDerivation rec{
  name = "wpsoffice-${version}";

  src = fetchurl {
    url = "http://kdl.cc.ksosoft.com/wps-community/download/6757/wps-office_10.1.0.6757_x86_64.tar.xz";
    #sha1 = if bits == "x86_64" then
    #  "03a781599dfcf001fc3bcf1d49699bd1a44aaceb" else
    #  "";
    sha256 = "0zk2shi3ciyjnmwvixkmj2qnivkg9a86mnvn83sj9idhlgjx7002";
  };

  meta = {
    description = "Office program originally named Kingsoft Office";
    homepage = http://wps-community.org/;
    platforms = [ "i686-linux" "x86_64-linux" ];
    hydraPlatforms = [];
    license = stdenv.lib.licenses.unfreeRedistributable;
  };

  libPath = stdenv.lib.makeLibraryPath [
    libX11
    libpng12
    glib
    xorg.libSM
    xorg.libXext
    xorg.libxcb
    lzma
    fontconfig
    zlib
    freetype
    libICE
    cups
    libXrender
  ];

  dontPatchELF = true;

  # wpsoffice uses `/build` in its own build system making nix things there
  # references to nix own build directory
  noAuditTmpdir = true;

  installPhase = ''
    set -x
    prefix=$out/opt/kingsoft/wps-office
    mkdir -p $prefix
    cp -r . $prefix

    # Avoid forbidden reference error due use of patchelf
    rm -r $PWD

    mkdir $out/bin
    for i in wps wpp et; do
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --force-rpath --set-rpath "$prefix/office6:$libPath" \
        $prefix/office6/$i

      substitute $prefix/$i $out/bin/$i \
        --replace /opt/kingsoft/wps-office $prefix
      chmod +x $out/bin/$i

      substituteInPlace $prefix/resource/applications/wps-office-$i.desktop \
        --replace /usr/bin $out/bin
    done

    # China fonts
    mkdir -p $prefix/resource/fonts/wps-office $out/etc/fonts/conf.d
    #ln -s $prefix/fonts/* $prefix/resource/fonts/wps-office
    ln -s ${ttf-wps-fonts}/*.ttf $prefix/resource/fonts/wps-office/
    #ln -s $prefix/fontconfig/*.conf $out/etc/fonts/conf.d

    ln -s $prefix/resource $out/share
    set +x
  '';
}
