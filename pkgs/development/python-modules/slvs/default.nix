{ lib
, buildPythonPackage
, python
, fetchFromGitHub
, cmake
, ninja
, scikit-build
, pytest
, setuptools
, pcre
, swig
}:

buildPythonPackage rec {
  pname = "slvs";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "realthunder";
    repo = "slvs_py";
    rev = "c94979b0204a63f26683c45ede1136a2a99cb365";
    sha256 = "sha256-bOdTmSMAA0QIRlcIQHkrnDH2jGjGJqs2i5Xaxu2STMU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ setuptools cmake ninja scikit-build pcre swig ];

  dontUseCmakeConfigure = true;

  doCheck = false;
  # I'm not modifying the checkPhase nor adding a pytestCheckHook because the pytest is called
  # within the cmake test phase
  checkInputs = [ pytest ];

  meta = with lib; {
    description = "Python Binding of SOLVESPACE Constraint Solver";
    homepage = "https://github.com/realthunder/slvs_py";
    license = licenses.lgpl3Only;
    maintainers = with maintainers; [ ];
  };
}
