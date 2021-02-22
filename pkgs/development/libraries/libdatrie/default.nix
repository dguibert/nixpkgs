{ lib, stdenv, fetchFromGitHub, makeWrapper
, autoreconfHook, autoconf-archive
, installShellFiles, libiconv }:

stdenv.mkDerivation rec {

  pname = "libdatrie";
  version = "0.2.13";

  src = fetchFromGitHub {
    owner = "tlwg";
    repo = "libdatrie";
    rev = "refs/tags/v0.2.13";
    sha256 = "sha256-Dafv9fnlc0kIf5gcoUW0zdM6O7kxK4hqsfkEJ5Bbfwc=";
  };

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    installShellFiles
  ];

  buildInputs = lib.optional stdenv.isDarwin libiconv;

  preAutoreconf = let
    reports = "https://github.com/tlwg/libdatrie/issues";
  in
  ''
    sed -i -e "/AC_INIT/,+3d" configure.ac
    sed -i "5iAC_INIT(${pname},${version},[${reports}])" configure.ac
  '';

  postInstall = ''
    installManPage man/trietool.1
  '';

  meta = with lib; {
    homepage = "https://linux.thai.net/~thep/datrie/datrie.html";
    description = "This is an implementation of double-array structure for representing trie";
    license = licenses.lgpl21Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ SuperSandro2000 ];
  };
}
