{ lib
, fetchPypi
, buildPythonPackage
, pytestCheckHook
, requests
, six
}:

buildPythonPackage rec {
  pname = "requests-ftp";
  version = "0.3.1";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-dQTOtcuopcATXtc4WWggp4xfK+ktebKflrqZsYPYBXo=";
  };

  propagatedBuildInputs = [
    requests
    six
  ];

  doCheck = false; # no tests

  pythonImportsCheck = [
    "requests_ftp"
  ];

  meta = with lib; {
    description = "Transport adapter for fetching ftp:// URLs with the requests python library";
    homepage = "https://github.com/Lukasa/requests-ftp";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
