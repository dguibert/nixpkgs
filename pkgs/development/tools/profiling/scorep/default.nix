{ stdenv, fetchurl
, which
, openmpi
, mpi ? openmpi
, gfortran
, zlib
}:

stdenv.mkDerivation {
  name = "scorep-2.0.2";

  src = fetchurl {
    url = "http://www.vi-hps.org/upload/packages/scorep/scorep-2.0.2.tar.gz";
    md5 = "8f00e79e1b5b96e511c5ebecd10b2888"; # provided on their website
  };

  buildInputs = [ mpi which gfortran zlib ];
}
