{ stdenv, python3Packages, mopidy }:

python3Packages.buildPythonApplication rec {
  pname = "Mopidy-Mopify";
  version = "1.7.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-gdXm7nKvZ01uu2hIRIDmmJWgnI2evUo8yC6txWnZAwY=";
  };

  propagatedBuildInputs = with python3Packages; [ mopidy configobj ];

  # no tests implemented
  doCheck = false;

  meta = with stdenv.lib; {
    homepage = "https://github.com/dirkgroenen/mopidy-mopify";
    description = "A mopidy webclient based on the Spotify webbased interface";
    license = licenses.gpl3;
    maintainers = [ maintainers.Gonzih ];
  };
}
