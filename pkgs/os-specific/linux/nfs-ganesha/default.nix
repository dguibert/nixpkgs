{ stdenv, fetchgit
, cmake, git
, krb5
, bison, flex
, doxygen
, libuuid
}:

stdenv.mkDerivation {
  name = "nfs-ganesha-2.1.0";

  src= fetchgit {
    url = "https://github.com/nfs-ganesha/nfs-ganesha";
    rev = "refs/tags/V2.1.0";
    sha256 = "8f32fe0569d08c237f3566612292277fe52dbff91e6fc6c53a3bbdf6458c31a5";
  };

  cmakeFlags = [
    "-DUSE_FSAL_LUSTRE=OFF"
  ];

  buildInputs = [ cmake krb5 bison flex doxygen libuuid git ];

  preConfigure = "cd src";
}
