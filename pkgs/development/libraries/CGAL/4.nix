{ lib, stdenv, fetchFromGitHub, fetchpatch, cmake, boost, gmp, mpfr }:

stdenv.mkDerivation rec {
  version = "5.5.2";
  pname = "cgal";

  src = fetchFromGitHub {
    owner = "CGAL";
    repo = "releases";
    rev = "CGAL-${version}";
    sha256 = "sha256-olMPT/8Q0bf+rooJoNc0k8NrO//O7z0yqBoP8KX39yQ=";
  };

  patches = [
    ./cgal_path.patch

    # Pull upstream fix for c++17 (gcc-12):
    #  https://github.com/CGAL/cgal/pull/6109
    (fetchpatch {
      name = "gcc-12-prereq.patch";
      url = "https://github.com/CGAL/cgal/commit/4581f1b7a8e97d1a136830e64b77cdae3546c4bf.patch";
      relative = "CGAL_Core"; # Upstream slightly reordered directory structure since.
      sha256 = "sha256-4+7mzGSBwAv5RHBQPAecPPKNN/LQBgvYq5mq+fHAteo=";
    })
    (fetchpatch {
      name = "gcc-12.patch";
      url = "https://github.com/CGAL/cgal/commit/6680a6e6f994b2c5b9f068eb3014d12ee1134d53.patch";
      relative = "CGAL_Core"; # Upstream slightly reordered directory structure since.
      sha256 = "sha256-8kxJDT47jXI9kQNFI/ARWl9JBNS4AfU57/D0tYlgW0M=";
    })
  ];

  # note: optional component libCGAL_ImageIO would need zlib and opengl;
  #   there are also libCGAL_Qt{3,4} omitted ATM
  buildInputs = [ boost gmp mpfr ];
  nativeBuildInputs = [ cmake ];

  doCheck = false;

  meta = with lib; {
    description = "Computational Geometry Algorithms Library";
    homepage = "http://cgal.org";
    license = with licenses; [ gpl3Plus lgpl3Plus];
    platforms = platforms.all;
    maintainers = [ maintainers.raskin ];
  };
}
