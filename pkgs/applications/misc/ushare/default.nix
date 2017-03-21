{ stdenv, fetchurl, libupnp, pkgconfig }:

stdenv.mkDerivation {
  name = "ushare-1.1a";

  src =fetchurl {
    url = "http://ushare.geexbox.org/releases/ushare-1.1a.tar.bz2";
    sha256 = "0rc6wwpcw773g7mgmn21kn7zagx3qqrrxa821xbg9m38k73qb6vv";
  };

  buildInputs = [ libupnp pkgconfig ];

  #configureFlags = "--enable-dlna --with-libdlna-dir=/usr/include/libavformat";

  preConfigure = ''
    sed -i -e 's/sprintf (protocol, mime->mime_protocol);/sprintf (protocol, "%s", mime->mime_protocol);/' src/mime.c
  '';

  patches = [
    (fetchurl {
       url = "https://aur.archlinux.org/cgit/aur.git/plain/upnp-build-fix.patch?h=ushare-mp4";
       sha256 = "1yigwgpyzimz88mnamyxqqc4h0vcbys2ph4i87wbja5zlwfj5sqc";
     })
    (fetchurl {
       url = "https://aur.archlinux.org/cgit/aur.git/plain/mp4-video.patch?h=ushare-mp4";
       sha256 = "15xwy8cngmkadn1qlsf2198yiiydzhfd0l16r5r345586qkshklq";
     })
    (fetchurl {
       url = "https://aur.archlinux.org/cgit/aur.git/plain/segfault.patch?h=ushare-mp4";
       sha256 = "0bn1axpp2k28cs05n0dijcazpn2rxr30pjywxvsdwgpl0kqfqxhp";
     })
    (fetchurl {
       url = "https://aur.archlinux.org/cgit/aur.git/plain/ushare-config.patch?h=ushare-mp4";
       sha256 = "0jia6pyizzaw8kv4qysbscd4r64h5z4lgr665swxihir1xrmihk2";
     })
     ./ushare-fix-building-with-gcc-5.x.patch
  ];

  makeFlags=''INSTALL=install'';

  meta = {
    homePage = "ushare.geexbox.org";
    description = "A free UPnP A/V & DLNA Media Server for Linux";
  };
}
