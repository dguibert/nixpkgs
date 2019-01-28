{ stdenv, fetchFromGitHub, pkgconfig, gfortran, texinfo
, autoreconfHook
, python2

# Select SIMD alignment width (in bytes) for vectorization.
, simdWidth ? 1

# Pad arrays to simdWidth by default?
# Note: Only useful if simdWidth > 1
, enablePadding ? false

# Activate serialization through Boost.Serialize?
, enableSerialization ? true, boost ? null

# Activate test-suite?
# WARNING: Some of the tests require up to 1700MB of memory to compile.
, doCheck ? true

}:

assert enableSerialization -> boost != null;

let
  inherit (stdenv.lib) optional optionals;
in

stdenv.mkDerivation rec {
  name = "blitz++-1.0.1";
  src = fetchFromGitHub {
    owner = "blitzpp";
    repo = "blitz";
    rev = "refs/tags/1.0.1";
    sha256 = "sha256:0nq84vwvvbq7m0my6h835ijfw53bxdp42qjc6kjhk436888qy9rh";
  };

  patches = [ ./blitz-testsuite-stencil-et.patch ];

  nativeBuildInputs = [ pkgconfig autoreconfHook python2 ];
  buildInputs = [ gfortran texinfo ]
    ++ optional (boost != null) boost;

  configureFlags =
    [ "--enable-shared"
      "--enable-fortran"
      "--enable-optimize"
      "--with-pic=yes"
      "--enable-html-docs"
      "--disable-doxygen"
      "--disable-dot"
      "--enable-simd-width=${toString simdWidth}"
    ]
    ++ optional enablePadding "--enable-array-length-padding"
    ++ optional enableSerialization "--enable-serialization"
    ++ optionals (boost != null) [ "--with-boost=${boost.dev}"
                                   "--with-boost-libdir=${boost.out}/lib" ]
    ++ optional stdenv.is64bit "--enable-64bit"
    ;

  enableParallelBuilding = false;

  buildFlags = [ "lib" "info" ];
  installTargets = [ "install" "install-info" ];

  inherit doCheck;
  checkTarget = "check-testsuite check-examples";

  meta = {
    description = "Fast multi-dimensional array library for C++";
    homepage = https://sourceforge.net/projects/blitz/;
    license = stdenv.lib.licenses.lgpl3;
    platforms = stdenv.lib.platforms.linux ++ stdenv.lib.platforms.darwin;
    maintainers = [ stdenv.lib.maintainers.aherrmann ];

    longDescription = ''
      Blitz++ is a C++ class library for scientific computing which provides
      performance on par with Fortran 77/90. It uses template techniques to
      achieve high performance. Blitz++ provides dense arrays and vectors,
      random number generators, and small vectors (useful for representing
      multicomponent or vector fields).
    '';

  };
}
