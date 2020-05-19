{ stdenv, lib, fetchurl, python3Packages, mopidy }:

python3Packages.buildPythonApplication rec {
  pname = "mopidy-beets";
  version = "4.0.0";

  src = fetchurl {
    url = "https://github.com/mopidy/mopidy-beets/archive/v4.0.0.tar.gz";
    sha256 = "sha256-y/TktE7OGuAB3Rk44AGuBIL4K48eXeE4NO4yxbD043w=";
  };

  propagatedBuildInputs = [
    mopidy
  ];

  doCheck = false;

  meta = with lib; {
    homepage = https://www.mopidy.com/;
    description = "Mopidy extension for playing music from a Beets collection";
    license = licenses.asl20;
    maintainers = [ maintainers.jgillich ];
    hydraPlatforms = [];
  };
}
