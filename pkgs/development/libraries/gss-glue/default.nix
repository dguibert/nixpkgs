{ stdenv, fetchurl }:

stdenv.mkDerivation {
  name = "gssglue-0.4";

  src = fetchurl {
    url = "http://www.citi.umich.edu/projects/nfsv4/linux/libgssglue/libgssglue-0.4.tar.gz";
    sha256 = "0fh475kxzlabwz30wz3bf7i8kfqiqzhfahayx3jj79rba1sily9z";
  };
}
