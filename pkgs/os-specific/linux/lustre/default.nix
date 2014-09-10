{ stdenv, fetchgit, kernel
, zfs, spl
, readline, perl
, autoconf, automake, libtool
, libuuid, zlib
}:

stdenv.mkDerivation {
  name = "lustre-2.6.52-${kernel.version}";

  src = fetchgit {
    url = "git://git.whamcloud.com/fs/lustre-release.git";
    rev = "refs/tags/v2_6_52";
    sha256 = "98be1be7f90575f969507055188bcebfde360c2057b5610527cea8dff15fc1b4";
    leaveDotGit = true;
  };

  buildInputs = [ autoconf automake libtool readline zfs spl perl libuuid zlib ];

  preConfigure = ''
    sed -i -e 's@usr/include@include@g' config/lustre-build-zfs.m4
    sed -i -e 's@/usr/sbin/l_getidentity@$out/sbin/l_getidentity@' lustre/mdt/mdt_internal.h

    chmod +x autogen.sh
    ./autogen.sh
  '';

  installFlags = "rootsbindir=$(out)/sbin sysconfdir=$(out)/etc modulenetdir=$(out)/lib/modules/${kernel.modDirVersion} modulefsdir=$(out)/lib/modules/${kernel.modDirVersion}";

  configureFlags = [
    "--disable-ldiskfs"
    "--without-ldiskfsprogs"

    "--enable-client"

    "--enable-server"
#    "--disable-modules" server require modules
    "--with-linux=${kernel.dev}/lib/modules/${kernel.modDirVersion}/source"
    "--with-linux-obj=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"

    "--with-spl=${spl.dev}/${spl.version}"
    "--with-zfs=${zfs.dev}/${zfs.version}"
    "--with-zfs-devel=${zfs}"

  ];

  meta = {
    description = "parallel distributed file system";
    longDescription = ''
      '';
    homepage = http://lustre.opensfs.org/;
    license = stdenv.lib.licenses.cddl;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ guibert ];
  };
}
