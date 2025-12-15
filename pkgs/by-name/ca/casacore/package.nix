{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gfortran,
  flex,
  bison,
  blas,
  lapack,
  cfitsio,
  wcslib,
  fftw,
  fftwFloat,
  readline,
  gsl,
  python3Packages
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "casacore";
  version = "3.8.0";

  src = fetchFromGitHub {
    owner = "casacore";
    repo = "casacore";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NOxuHMCuHGk9XuWXMwQTN6kOFDI0QuHMgfNRDdlPw44=";
  };

  nativeBuildInputs = [
    cmake
    gfortran
    flex
    bison
  ];

  buildInputs = [
    blas
    lapack
    cfitsio
    wcslib
    fftw
    fftwFloat
    readline
    gsl
    python3Packages.numpy
    python3Packages.boost
  ];

  enableParallelBuilding = true;

  strictDeps = true;

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_SHARED" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "BUILD_PYTHON3" true)
    (lib.cmakeFeature "Python3_EXECUTABLE" "${lib.getExe python3Packages.python}")
  ];

  meta = {
    homepage = "https://casacore.github.io/casacore/";
    changelog = "https://github.com/casacore/casacore/blob/master/CHANGES.md";
    description = "Suite of C++ libraries for radio astronomy data processing";
    maintainers = with lib.maintainers; [ kiranshila ];
    license = lib.licenses.lgpl2Only;
    platforms = lib.platforms.all;
  };
})
