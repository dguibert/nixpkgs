{ lib
, buildPythonPackage
, fetchFromGitHub
, fonts
, font-roboto
, pillow
}:

buildPythonPackage rec {
  pname = "pidi-display-pil";
  version = "unstable-2022-02-09";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "pimoroni";
    repo = "pidi-plugins";
    rev = "38d1fcb02b7c5833ae4738ac3a8246dbe53cfa3b";
    hash = "sha256-u92Q8F/CWBSYLBYyHsVYmNPjJe+qWS/Ge1S/mOCoLXs=";
  };

  sourceRoot = "source/${pname}";

  propagatedBuildInputs = [
    fonts
    font-roboto
    pillow
  ];

  doCheck = false; # No module named 'tests'

  meta = with lib; {
    description = "PiDi Display Plugin for PIL-based image output";
    homepage = "https://github.com/pimoroni/pidi-plugins";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
