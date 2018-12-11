{ stdenv
, fetchFromGitHub
, autoconf ,automake
, libtool
, numactl
, binutils
, libbfd
, libiberty
, zlib
, doxygen, perl
}:

stdenv.mkDerivation {
  name = "openucx-1.4.0";

  src = fetchFromGitHub {
    owner = "openucx";
    repo = "ucx";
    rev = "v1.4.0";
    sha256 = "0p126wd8xd7x1fwc78hqmaaykyxyn8kpxd69i549d5c9w2a75j8y";
  };
  buildInputs = [ autoconf automake libtool doxygen perl ];
  nativeBuildInputs = [ numactl binutils libbfd libiberty zlib ];
  preConfigure = "./autogen.sh";
  meta = with stdenv.lib; {
    description = "A communication library implementing a high-performance messaging layer for MPI, PGAS, and RPC frameworks.";
    homepage = http://www.openucx.org;
  };
}
