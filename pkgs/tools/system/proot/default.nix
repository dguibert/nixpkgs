{ lib, stdenv, fetchFromGitHub
, talloc, docutils, swig, python, coreutils, enablePython ? true }:

stdenv.mkDerivation {
  pname = "proot";
  version = "20200301";

  src = fetchFromGitHub {
    repo = "proot";
    owner = "termux";
    rev = "0782d176818ed9865a2148605561eae6e1be9352";
    sha256 = "sha256-ISNK9Wjo4MDndeQpE5dC1ILap89k6uuPyaWm6U3abcI=";
  };
  #src = fetchFromGitHub {
  #  repo = "proot";
  #  owner = "proot-me";
  #  rev = "e35d15834b71822c36e0080cfe4c8cc722f211d2";
  #  sha256 = "sha256-zP6A/50sorglsu+r4sG4uii0SG14OvQViqJIe7bN/7I=";
  #};

  postPatch = ''
    substituteInPlace src/GNUmakefile \
      --replace /bin/echo ${coreutils}/bin/echo
    # our cross machinery defines $CC and co just right
    sed -i /CROSS_COMPILE/d src/GNUmakefile
  '';

  buildInputs = [ talloc ] ++ lib.optional enablePython python;
  nativeBuildInputs = [ docutils ] ++ lib.optional enablePython swig;

  enableParallelBuilding = true;

  makeFlags = [ "-C src" ];

  postBuild = ''
    make -C doc proot/man.1
  '';

  installFlags = [ "PREFIX=${placeholder "out"}" ];

  postInstall = ''
    install -Dm644 doc/proot/man.1 $out/share/man/man1/proot.1
  '';

  meta = with lib; {
    homepage = "https://proot-me.github.io";
    description = "User-space implementation of chroot, mount --bind and binfmt_misc";
    platforms = platforms.linux;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ianwookim makefu veprbl dtzWill ];
  };
}
