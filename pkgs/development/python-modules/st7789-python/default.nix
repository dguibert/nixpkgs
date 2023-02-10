{ lib
, buildPythonPackage
, fetchFromGitHub
, numpy
, spidev
, rpi-gpio
}:

buildPythonPackage rec {
  pname = "st7789-python";
  version = "unstable-2022-01-32";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "pimoroni";
    repo = pname;
    rev = "3e63dc34042c0d12bf2950ed5b88d3a8dc060018";
    hash = "sha256-IakJg58xzl3HLt7Hys4VGx5tfyyM2I6/01yHROTyvEo=";
  };

  sourceRoot = "source/library";

  propagatedBuildInputs = [
    numpy
    spidev
    rpi-gpio
  ];

  doCheck = false; # RuntimeError: This module can only be run on a Raspberry Pi!

  meta = with lib; {
    description = "Python library to control an ST7789 TFT LCD display";
    homepage = "https://github.com/pimoroni/st7789-python";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
