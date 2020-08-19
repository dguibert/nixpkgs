{ stdenv, lib, fetchFromGitHub, autoreconfHook, pkg-config, fuse3 }:

stdenv.mkDerivation rec {
  pname = "fuse-migratefs";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "stanford-rc";
    repo = pname;
    #rev = "v${version}"; v0.6.3 not yet publish
    rev = "97a1720a566a6f789248e60020217d03d35c5d22";
    sha256 = "sha256-LtCBhqRsy0imGTh91qthhH76QBDOlqQSr7GXPrtE9vA=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ];

  buildInputs = [ fuse3 ];

  postInstall = ''
    ln -sv $out/bin/migratefs $out/bin/mount.migratefs
    ln -sv $out/bin/migratefs $out/bin/mount.fuse.migratefs
  '';

  meta = with lib; {
    description = "A filesystem overlay for transparent, distributed migration of active data across separate storage systems";
    longDescription = "FUSE-based filesystem overlay designed to semalessly migrate data from one filesystem to another";
    license = licenses.gpl3;
    platforms = platforms.linux;
    inherit (src.meta) homepage;
  };
}
