{ stdenv, lib, fetchFromGitHub, autoreconfHook, pkg-config, fuse3 }:

stdenv.mkDerivation rec {
  pname = "fuse-migratefs";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "stanford-rc";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-H2NYxInPTSidcXgrhC6pwkjyR7e0aaGF4LU+XXDshUE=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ];

  buildInputs = [ fuse3 ];

  meta = with lib; {
    description = "A filesystem overlay for transparent, distributed migration of active data across separate storage systems";
    longDescription = "FUSE-based filesystem overlay designed to semalessly migrate data from one filesystem to another";
    license = licenses.gpl3;
    platforms = platforms.linux;
    inherit (src.meta) homepage;
  };
}
