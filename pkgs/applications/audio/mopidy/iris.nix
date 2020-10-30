{ stdenv, python3Packages, mopidy }:

python3Packages.buildPythonApplication rec {
  pname = "Mopidy-Iris";
  version = "3.53.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-ftLBEcNNA1IwZWj/mC3D6BZTgwFqemiP2zhtFro28Eg=";
  };

  propagatedBuildInputs = [
    mopidy
  ] ++ (with python3Packages; [
    configobj
    requests
    tornado
  ]);

  # no tests implemented
  doCheck = false;

  meta = with stdenv.lib; {
    homepage = "https://github.com/jaedb/Iris";
    description = "A fully-functional Mopidy web client encompassing Spotify and many other backends";
    license = licenses.asl20;
    maintainers = [ maintainers.rvolosatovs ];
  };
}
