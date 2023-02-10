{ lib
, buildPythonPackage
, fetchFromGitHub
, pidi-display-pil
}:

buildPythonPackage rec {
  pname = "fonts";
  version = "unstable-2018-10-04";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "pimoroni";
    repo = "fonts-python";
    rev = "3abfa4bed335ba8ff234d1790233febc8d85090d";
    hash = "sha256-RHzf9PmYf0xAKuytxOwUtVxhEVgDFzPrkMPGK3eLY8g=";
  };

  sourceRoot = "source/${pname}";

  meta = with lib; {
    description = "Python framework for distributing and managing fonts";
    homepage = "https://github.com/pimoroni/fonts-python/tree/master/fonts";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
