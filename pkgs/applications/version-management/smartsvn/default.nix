{ stdenv, fetchurl, lib, makeWrapper
, jre
, gtk2, glib
, libXtst
, which
, serf
}:

stdenv.mkDerivation rec {
  name = "smartsvn-${version}";
  version = "9_3_1";

  src = fetchurl {
    url = "https://www.syntevo.com/downloads/smartsvn/smartsvn-linux-${version}.tar.gz";
    sha256 = "159sbgyprbi0sp0agwrh21b5qyvbkd0gzj66xpac87g809sxgmjg";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ jre ];

  buildCommand = let
    pkg_path = "$out/${name}";
    bin_path = "$out/bin";
    install_freedesktop_items = ./install_freedesktop_items.sh;
    runtime_paths = lib.makeBinPath [
      jre
      #git mercurial subversion # the paths are requested in configuration
      which
    ];
    runtime_lib_paths = lib.makeLibraryPath [
      gtk2 glib
      libXtst
      serf
    ];
  in ''
    tar xvzf $src
    mkdir -pv $out
    mkdir -pv ${pkg_path}
    # unpacking should have produced a dir named 'smartsvn'
    cp -a smartsvn/* ${pkg_path}
    # prevent using packaged jre
    rm -r ${pkg_path}/jre
    mkdir -pv ${bin_path}
    jre=${jre.home}
    makeWrapper ${pkg_path}/bin/smartsvn.sh ${bin_path}/smartsvn \
      --prefix PATH : ${runtime_paths} \
      --prefix LD_LIBRARY_PATH : ${runtime_lib_paths} \
      --prefix JRE_HOME : ${jre} \
      --prefix JAVA_HOME : ${jre} \
      --prefix SMARTGITHG_JAVA_HOME : ${jre}
    sed -i '/ --login/d' ${pkg_path}/bin/smartsvn.sh
    patchShebangs $out

    ${install_freedesktop_items} "${pkg_path}/bin" "$out"
  '';

  meta = with stdenv.lib; {
    description = "GUI for Subversion";
    homepage = https://www.smartsvn.com;
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
