{ stdenv, fetchurl, pkgconfig, krb5, gssglue }:

stdenv.mkDerivation {
  name = "rpcsecgss-0.19";

  src = fetchurl {
    url = "http://www.citi.umich.edu/projects/nfsv4/linux/librpcsecgss/librpcsecgss-0.19.tar.gz";
    sha256 = "1g9sj7xc2vgw4n4qw9ad2sy4d299cn8svambx24lrsz5cxmvibqc";
  };

  buildInputs = [ pkgconfig krb5 gssglue ];
}
