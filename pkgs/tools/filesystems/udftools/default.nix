{ stdenv, fetchFromGitHub, ncurses, readline, autoreconfHook, pkgconfig, udev }:

stdenv.mkDerivation rec {
  pname = "udftools";
  version = "2.1";
  src = fetchFromGitHub {
    owner = "pali";
    repo = "udftools";
    rev = version;
    sha256 = "sha256:1p08h1syfjhgl35mcahmnff49gc8r69sh4nvr0xm5ii6ckhzz010";
  };

  buildInputs = [ ncurses readline ];
  nativeBuildInputs = [ autoreconfHook pkgconfig udev ];

  hardeningDisable = [ "fortify" ];

#  NIX_CFLAGS_COMPILE = "-std=gnu99";

  preConfigure = ''
    sed -e '1i#include <limits.h>' -i cdrwtool/cdrwtool.c -i pktsetup/pktsetup.c
    sed -e 's@[(]char[*][)]spm [+]=@spm = ((char*) spm) + @' -i wrudf/wrudf.c
    sed -e '38i#include <string.h>' -i wrudf/wrudf-cdrw.c
    sed -e '12i#include <string.h>' -i wrudf/wrudf-cdr.c
    sed -e '37i#include <stdlib.h>' -i wrudf/ide-pc.c

    sed -e "s@\$(DESTDIR)/lib/udev/rules.d@$out/lib/udev/rules.d@" -i pktsetup/Makefile.am
  '';

  postFixup = ''
    sed -i -e "s@/usr/sbin/pktsetup@$out/sbin/pktsetup@" $out/lib/udev/rules.d/80-pktsetup.rules
  '';

  makeFlags = [
    "UDEVDIR=\${out}/lib/udev"
  ];

  meta = with stdenv.lib; {
    description = "UDF tools";
    maintainers = with maintainers; [ raskin ];
    platforms = platforms.linux;
    license = licenses.gpl2Plus;
  };
}
