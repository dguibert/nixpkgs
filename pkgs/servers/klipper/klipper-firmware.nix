{ stdenv
, lib
, pkg-config
, pkgsCross
, bintools-unwrapped
, libffi
, libusb1
, wxGTK32
, python3
, gcc-arm-embedded
, klipper
, avrdude
, stm32flash
, mcu ? "mcu"
, firmwareConfig ? ./simulator.cfg
, fetchpatch
}: stdenv.mkDerivation rec {
  name = "klipper-firmware-${mcu}-${version}";
  version = klipper.version;
  src = klipper.src;

  nativeBuildInputs = [
    python3
    pkgsCross.avr.stdenv.cc
    gcc-arm-embedded
    bintools-unwrapped
    libffi
    libusb1
    avrdude
    stm32flash
    pkg-config
    wxGTK32 # Required for bossac
  ];

  patches = [
    (fetchpatch {
      url = "https://github.com/Laikulo/klipper/commit/ecf4266cc71f52045460c4021fdd7b971f119562.patch";
      sha256 = "sha256-0m4fVfGqL7IOCzhD6InM/G9pVv1vGvhz/2PeBrC3Z6U=";
    })
  ];

  preBuild = "cp ${firmwareConfig} ./.config";

  postPatch = ''
    patchShebangs .
  '';

  makeFlags = [
    "V=1"
    "KCONFIG_CONFIG=${firmwareConfig}"
    "WXVERSION=3.2"
  ];

  installPhase = ''
    mkdir -p $out
    cp ./.config $out/config
    cp out/klipper.bin $out/ || true
    cp out/klipper.elf $out/ || true
  '';

  dontFixup = true;

  meta = with lib; {
    inherit (klipper.meta) homepage license;
    description = "Firmware part of Klipper";
    maintainers = with maintainers; [ vtuan10 ];
    platforms = platforms.linux;
  };
}
