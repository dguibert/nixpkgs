{ lib
, stdenv
, fetchurl
, fetchpatch
, getopt
, libcap
, gnused
, nixosTests
}:

stdenv.mkDerivation rec {
  version = "1.28";
  pname = "fakeroot";

  src = fetchurl {
    url = "http://http.debian.net/debian/pool/main/f/fakeroot/fakeroot_${version}.orig.tar.gz";
    sha256 = "sha256-VtQF42/2hfg4eb4I/dZUJVq5qjhjK0YFqY6JatY5kMI=";
  };

  patches = lib.optionals stdenv.isLinux [
    ./einval.patch
    (fetchpatch {
      name = "also-wrap-stat-library-call.patch";
      url = "https://sources.debian.org/data/main/f/fakeroot/1.28-1/debian/patches/also-wrap-stat-library-call.patch";
      sha256 = "0sfwy3iwxi2jd9bl847w4j2bf8pii1yi5j6lww7awazy51zjf1s9";
    })
  ];

  buildInputs = [ getopt gnused ]
    ++ lib.optional (!stdenv.isDarwin) libcap
    ;

  postUnpack = ''
    sed -i -e "s@getopt@$(type -p getopt)@g" -e "s@sed@$(type -p sed)@g" ${pname}-${version}/scripts/fakeroot.in
  '';

  passthru = {
    tests = {
      # A lightweight *unit* test that exercises fakeroot and fakechroot together:
      nixos-etc = nixosTests.etc.test-etc-fakeroot;
    };
  };

  meta = {
    homepage = "https://salsa.debian.org/clint/fakeroot";
    description = "Give a fake root environment through LD_PRELOAD";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [viric];
    platforms = lib.platforms.unix;
  };
}
