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
, git
, pkgconfig
, rdma-core
, libfabric
}:

stdenv.mkDerivation {
  name = "openucx-1.6.0";

  src = fetchFromGitHub {
    owner = "openucx";
    repo = "ucx";
    rev = "v1.6.0";
    sha256 = "sha256:1bvsgjp8mzxd5j47g8714jfrzvcwl2g621fjj8wmrvkyw3m11gkz";
    leaveDotGit=true;
  };
  buildInputs = [ autoconf automake libtool doxygen perl git pkgconfig ];
  nativeBuildInputs = [ numactl binutils libbfd libiberty zlib rdma-core libfabric ];
  preConfigure = "./autogen.sh";

  configureFlags = [
    "--with-verbs=${libfabric}"  #(=DIR)      Build OpenFabrics support, adding DIR/include,
                    ## DIR/lib, and DIR/lib64 to the search path for
                    ## headers and libraries
    "--with-rc"       ## Compile with IB Reliable Connection support
    "--with-ud"       ## Compile with IB Unreliable Datagram support
    "--with-dc"       ## Compile with IB Dynamic Connection support
    "--with-mlx5-dv"  ## Compile with mlx5 Direct Verbs support. Direct Verbs
                      ## (DV) support provides additional acceleration
                      ## capabilities that are not available in a regular
                      ## mode.
    "--with-ib-hw-tm" # Compile with IB Tag Matching support
    "--with-dm" #       Compile with Device Memory support
    #"--with-cm" #       Compile with IB Connection Manager support ## checking for ib_cm_send_req in -libcm... no
    "--with-rdmacm=${rdma-core}" #     Enable the use of RDMACM (default is guess).
  ## --with-knem=(DIR)       Enable the use of KNEM (default is guess).
  ## --with-xpmem=(DIR)      Enable the use of XPMEM (default is guess).
  ];

  meta = with stdenv.lib; {
    description = "A communication library implementing a high-performance messaging layer for MPI, PGAS, and RPC frameworks.";
    homepage = http://www.openucx.org;
  };
}
