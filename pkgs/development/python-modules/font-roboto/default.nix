{ lib
, buildPythonPackage
, fetchFromGitHub
}:

buildPythonPackage rec {
  pname = "font-roboto";
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
    description = "Neo-grotesque sans-serif font family designed by Google for the Android mobile OS";
    homepage = "https://github.com/pimoroni/fonts-python/tree/master/font-roboto";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
