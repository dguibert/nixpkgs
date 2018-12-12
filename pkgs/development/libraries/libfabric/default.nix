{ stdenv
, fetchFromGitHub
, autoconf ,automake
, libtool
}:

stdenv.mkDerivation {
  name = "libfabric-1.6.2";

  src = fetchFromGitHub {
    owner = "ofiwg";
    repo = "libfabric";
    rev = "v1.6.2";
    sha256 = "0c2hjcdi13dd1wxwkn2gdmyjisyfgsdckrqga9wjfnfd60lz1rgv";
  };
  buildInputs = [ autoconf automake libtool ];
  preConfigure = "./autogen.sh";
  meta = with stdenv.lib; {
    description = "A framework focused on exporting fabric communication services to applications";
    homepage = http://libfabric.org/;
    license = licenses.bsd3;
  };
}
