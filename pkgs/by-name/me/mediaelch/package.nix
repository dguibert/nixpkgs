{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,

  cmake,

  curl,
  ffmpeg,
  libmediainfo,
  libzen,
  libsForQt5,
  qt6Packages,

  qtVersion ? 6,
}:

let
  qt' = if qtVersion == 5 then libsForQt5 else qt6Packages;

in
stdenv.mkDerivation (finalAttrs: {
  pname = "mediaelch";
  version = "2.12.0-unstable-2026-06-18";

  src = fetchFromGitHub {
    owner = "Komet";
    repo = "MediaElch";
    rev = "f97abde6f13322f53de5e756c430c4b6b9571dc2";
    hash = "sha256-k1FN7A0dcygbWxZJhrvNAD2kFNOYAh4KCAACDKaaXpM=";
    fetchSubmodules = true;
  };

  patches = [
  ];

  nativeBuildInputs = [
    cmake
    qt'.qttools
    qt'.wrapQtAppsHook
  ];

  buildInputs = [
    curl
    ffmpeg
    libmediainfo
    libzen
    qt'.qtbase
    qt'.qtdeclarative
    qt'.qtmultimedia
    qt'.qtsvg
    qt'.qtwayland
    qt'.quazip
  ]
  ++ lib.optionals (qtVersion == 6) [
    qt'.qt5compat
  ];

  cmakeFlags = [
    (lib.cmakeBool "DISABLE_UPDATER" true)
    (lib.cmakeBool "ENABLE_TESTS" finalAttrs.finalPackage.doCheck or false)
    (lib.cmakeBool "MEDIAELCH_FORCE_QT${toString qtVersion}" true)
    (lib.cmakeBool "USE_EXTERN_QUAZIP" true)
  ];

  # libmediainfo.so.0 is loaded dynamically
  qtWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${libmediainfo}/lib"
  ];

  env = {
    HOME = "/tmp"; # for the font cache
    LANG = "C.UTF-8";
    QT_QPA_PLATFORM = "offscreen"; # the tests require a UI
    QT_QPA_PLATFORM_PLUGIN_PATH = "${qt'.qtbase}/${qt'.qtbase.qtPluginPrefix}/platforms";
  };

  doCheck = true;

  checkTarget = "unit_test"; # the other tests require network connectivity

  meta = {
    homepage = "https://mediaelch.de/mediaelch/";
    description = "Media Manager for Kodi";
    mainProgram = "MediaElch";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ stunkymonkey ];
    platforms = lib.platforms.linux;
  };
})
