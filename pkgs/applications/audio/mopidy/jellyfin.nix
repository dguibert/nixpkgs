{ stdenv, fetchFromGitHub, python3Packages, mopidy }:

python3Packages.buildPythonApplication rec {
  pname = "mopidy-jellyfin";
  version = "v0.7.1-5-gf939247";

  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "mopidy-jellyfin";
    rev = "f939247d85ef5a1c5d976ea782a30f35a3c7d0b0";
    sha256 = "sha256-c3Pm67/54AYjdz/fi3rrop5b4lNHbRvn/ADVk3uHzbY=";
  };

  propagatedBuildInputs = [
    mopidy
  ] ++ (with python3Packages; [
    websocket_client
    unidecode
  ]);

  doCheck = false;

  meta = with stdenv.lib; {
    homepage = https://www.mopidy.com/;
    description = "Mopidy extension for playing music from Jellyfin";
    license = licenses.asl20;
    maintainers = [ ];
    hydraPlatforms = [];
  };
}
