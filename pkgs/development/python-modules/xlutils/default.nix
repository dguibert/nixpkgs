{ buildPythonPackage
, fetchPypi
, nose
, lib
, xlrd
, xlwt
, mock, testfixtures, manuel
}:

buildPythonPackage rec {
  pname = "xlutils";
  version = "2.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "7e0e2c233bd185fecf5e2bd3f4e9469ca4a3bd87da64c82cfe5b2af27e7f9e54";
  };

  buildInputs = [ xlrd xlwt ];

  doCheck = false;
  checkInputs = [ nose mock testfixtures manuel ];
  checkPhase = ''
    nosetests -v
  '';

  meta = {
    description = "Utilities for working with Excel files that require both xlrd and xlwt";
    homepage = "https://github.com/python-excel/xlutils";
    license = with lib.licenses; [ bsdOriginal bsd3 lgpl21 ];
  };
}
