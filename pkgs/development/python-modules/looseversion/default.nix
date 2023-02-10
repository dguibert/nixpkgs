{ lib
, buildPythonPackage
, fetchFromGitHub
, flit-core
}:

buildPythonPackage rec {
  pname = "looseversion";
  version = "1.0.3";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "effigies";
    repo = pname;
    rev = "${version}";
    hash = "sha256-Ys1YjubMNxBiNlyAQ0vV566FFQdGq3uBEl7otmdQgPk=";
  };

  propagatedBuildInputs = [
    flit-core
  ];

  #doCheck = false;

  meta = with lib; {
    description = "Version numbering for anarchists and software realists";
    homepage = "https://github.com/effigies/looseversion";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
