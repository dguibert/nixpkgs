{ lib, python3Packages, mopidy }:

python3Packages.buildPythonApplication rec {
  pname = "mopidy-pidi";
  version = "1.0.4";

  src = python3Packages.fetchPypi {
    inherit version;
    pname = "mopidy-pidi";
    sha256 = "sha256-JR1NTtm7kobKtAzQVo/CPN+qNawYEO/TSCp5E3F7wQo=";
  };

  propagatedBuildInputs = with python3Packages; [
    mopidy
    netifaces
    musicbrainzngs
  ];

  buildInputs = [
    python3Packages.pytest
  ];

  pythonImportsCheck = [ "mopidy_pidi.frontend" ];

  meta = with lib; {
    description = "Mopidy extension for displaying song info and album art using pidi display plugins";
    homepage = "https://github.com/pimoroni/mopidy-pidi";
    license = licenses.asl20;
    maintainers = with maintainers; [ hexa ];
  };
}
