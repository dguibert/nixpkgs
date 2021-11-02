{ lib, python3Packages, mopidy, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "Mopidy-Iris";
  version = "3.60.0";

  src = fetchFromGitHub {
    owner = "jaedb";
    repo = "Iris";
    rev = version;
    sha256 = "1189j6i1aymi3kpa7vbxcc73cvpr01gygb3p185d6yaycfpc51hn";
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

  meta = with lib; {
    homepage = "https://github.com/jaedb/Iris";
    description = "A fully-functional Mopidy web client encompassing Spotify and many other backends";
    license = licenses.asl20;
    maintainers = [ maintainers.rvolosatovs ];
  };
}
