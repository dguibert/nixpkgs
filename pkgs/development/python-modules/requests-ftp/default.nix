{ lib, fetchPypi, buildPythonPackage, requests }:

buildPythonPackage rec {
  pname   = "requests-ftp";
  version = "0.3.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-dQTOtcuopcATXtc4WWggp4xfK+ktebKflrqZsYPYBXo=";
  };

  propagatedBuildInputs = [ requests ];

  #checkInputs = [ pytestCheckHook ];

  meta = {
    homepage = "https://github.com/Lukasa/requests-ftp";
    description = "Transport adapter for fetching ftp:// URLs with the requests python library";
    license = lib.licenses.asl20;
  };

}
