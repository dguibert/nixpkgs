{ stdenv, fetchFromGitHub, ncurses, boost }:

stdenv.mkDerivation {
  name = "kakoune-20160113";

  src = fetchFromGitHub {
    repo = "kakoune";
    owner = "mawww";
    rev = "1e8ea9e5bd4b8cadd19bd7995e8075bd2792806d";
    sha256 = "04rj3d95ga0igczdwssis1wnhk22iamkmklzxf8s3wk3776hrci6";
  };

  preConfigure = "cd src";

  installFlags = "PREFIX=$(out)";

  buildInputs = [ boost ncurses ];

  meta = {
    description = "code editor: Vim inspired · Faster as in less keystrokes · Multiple selections · Orthogonal design";
    homePage = "http://kakoune.org/";
  };
}
