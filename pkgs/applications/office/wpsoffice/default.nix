{ stdenv, fetchurl
, libX11, glib, xorg, fontconfig, freetype
, zlib, libpng12, libICE, libXrender, cups
, lzma
, fetchFromGitHub
, nss
, alsaLib
, pango
, cairo
, dbus
, atk
, gtk2
, gdk_pixbuf
, nspr
, rpmextract
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

  version = "11.1.0.8722";
in stdenv.mkDerivation rec{
  pname = "wpsoffice";
  inherit version;

  src = fetchurl {
    name = "${pname}-${version}.rpm";
    url = "http://kdl.cc.ksosoft.com/wps-community/download/8722/wps-office-11.1.0.8722-1.x86_64.rpm";
    sha1 = if bits == "x86_64" then
      "sha1:bhdcil6rkpngp6msmhc95f1wabj0gh87" else
      throw "no x86 version at http://wps-community.org/downloads";
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
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXfixes
    xorg.libXi
    xorg.libXtst
    xorg.libXrandr
    xorg.libXScrnSaver
    xorg.libxcb
    lzma
    fontconfig
    zlib
    freetype
    libICE
    cups
    libXrender
    nss
    stdenv.cc.cc.lib
    alsaLib
    pango
    cairo
    dbus
    atk
    gtk2
    nspr
    gdk_pixbuf
  ];

  dontPatchELF = true;

  # wpsoffice uses `/build` in its own build system making nix things there
  # references to nix own build directory
  noAuditTmpdir = true;

  buildInputs = [ rpmextract ];

  unpackPhase = ''
   :
  '';

  installPhase = ''
    mkdir $out
    (cd $out ; rpmextract $src; mv usr/* .; rmdir usr)

    prefix=$out/opt/kingsoft/wps-office

    for i in wps wpp et; do
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --force-rpath --set-rpath "$prefix/office6:$libPath" \
        $prefix/office6/$i

      substituteInPlace $out/bin/$i \
        --replace /opt/kingsoft/wps-office $prefix
      chmod +x $out/bin/$i

      substituteInPlace $out/share/applications/wps-office-$i.desktop \
        --replace /usr/bin $out/bin
    done

    # China fonts
    mkdir -p $prefix/resource/fonts/wps-office $out/etc/fonts/conf.d
    #ln -s $prefix/fonts/* $prefix/resource/fonts/wps-office
    ln -s ${ttf-wps-fonts}/*.ttf $prefix/resource/fonts/wps-office/
    #ln -s $prefix/fontconfig/*.conf $out/etc/fonts/conf.d
  '';
}
