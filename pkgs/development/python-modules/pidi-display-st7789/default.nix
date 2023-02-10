{ lib
, buildPythonPackage
, fetchFromGitHub
, pidi-display-pil
}:

buildPythonPackage rec {
  pname = "pidi-display-st7789";
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
    pidi-display-pil
  ];

  #doCheck = false; # RuntimeError: This module can only be run on a Raspberry Pi!

  meta = with lib; {
    description = "PiDi Display Plugin for the ST7789 240x240 LCD";
    homepage = "https://github.com/pimoroni/pidi-plugins";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
