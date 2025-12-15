{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  pythonOlder,
  scikit-build-core,
  setuptools,
  setuptools-scm,
  cmake,
  ninja,
  numpy,
  casacore,
  wcslib,
  cfitsio,
  openblas,
  boost,
}:

buildPythonPackage rec {
  pname = "python-casacore";
  version = "3.7.1";
  pyproject = true;

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "casacore";
    repo = "python-casacore";
    tag = "v${version}";
    hash = "sha256-6okcy0DBqkyEWDvJ8GDKaN1odrZzqZROjSdJDPFzgao=";
  };

  build-system = [
    scikit-build-core
    setuptools
    setuptools-scm
    cmake
    ninja
  ];

  dependencies = [
    wcslib
    cfitsio
    openblas
    boost
    casacore
    numpy
  ];
  
  dontUseCmakeConfigure = true;
  dontUseCmakeBuild = true;
  dontUseCmakeInstall = true;

  meta = {
    description = "Python bindings for casacore, a library used in radio astronomy";
    homepage = "http://casacore.github.io/python-casacore";
    changelog = "https://github.com/casacore/python-casacore/releases/tag/${src.tag}";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [
    ];
  };
}
