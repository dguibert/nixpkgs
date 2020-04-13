{ stdenv, fetchurl, python3Packages, mopidy }:

python3Packages.buildPythonApplication rec {
  pname = "mopidy-jellyfin";
  version = "0.7.1";

  src = fetchurl {
    url = "https://github.com/jellyfin/mopidy-jellyfin/archive/v${version}.tar.gz";
    sha256 = "sha256-MhpaZ60Vy3pds271n3b7rX2gi6hdiwLDtT6Osf68DWQ=";
  };

  propagatedBuildInputs = [
    mopidy
  ] ++ (with python3Packages; [
    websocket_client
    unidecode
  ]);

  doCheck = false;

  meta = with lib; {
    homepage = https://www.mopidy.com/;
    description = "Mopidy extension for playing music from Jellyfin";
    license = licenses.asl20;
    maintainers = [ ];
    hydraPlatforms = [];
  };
}
