{ stdenv, fetchFromGitHub, cmake, flex, bison, qt4, boost, mesa, freeglut }:

stdenv.mkDerivation {
  name = "pajeng-1.0-213-gb00a47f";

  src = fetchFromGitHub {
    owner  = "schnorr";
    repo   = "pajeng";
    rev    = "b00a47f67a5745a879c0a5c4fdb08d147db919c1";
    sha256 = "0bgriasc6ibhh0xjgbwvzgn7xgrz71ydz83b3c8y423x02aq1i7w";
  };

  buildInputs = [ cmake flex bison qt4 boost mesa freeglut ];

  cmakeFlags = [
    "-DPAJENG=ON"
    "-DPAJE_UTILS_LIBRARY=ON"
  ];

  meta = {
    homePage = "https://github.com/schnorr/pajeng";
    description = "Paje Next Generation - Visualization Tool";
  };
}
