{
  clangStdenv,
  lib,
  binutils,
  fetchFromGitHub,
  fetchpatch,
  cmake,
  pkg-config,
  wrapGAppsHook3,
  boost183,
  cereal,
  cgal,
  curl,
  dbus,
  draco,
  eigen_5,
  expat,
  ffmpeg,
  glew,
  glfw,
  glib,
  glib-networking,
  gmp,
  gst_all_1,
  gtest,
  gtk3,
  hicolor-icon-theme,
  libsecret,
  libpng,
  mpfr,
  nlopt,
  opencascade-occt,
  openvdb,
  opencv,
  systemdLibs,
  onetbb,
  webkitgtk_4_1,
  wxwidgets_3_3,
  libx11,
  libnoise,
  withSystemd ? clangStdenv.hostPlatform.isLinux,
  withNvidiaGLWorkaround ? false,
  libdatachannel,
  python312,
  solvespace,
  assimp,
  libsysprof-capture,
  pcre2,
  uv,
}:
let
  wxGTK' =
    (wxwidgets_3_3.override {
      withPrivateFonts = true;
      withWebKit = true;
      withEGL = true;
    }).overrideAttrs
      (old: {
        buildInputs = old.buildInputs ++ [ libsecret ];
        configureFlags = old.configureFlags ++ [
          # Disable noisy debug dialogs
          "--enable-debug=no"
          "--enable-secretstore"
        ];
      });

  solvespace' = solvespace.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "JacobStoren";
      repo = "SolveSpaceLib";
      rev = "4d8704523e4bf212fadf5189f92484244f670fea";
      hash = "sha256-xe6J+cnOUWLo5561CskQlR+3Co8FriCupc8l1lhhocA=";
    };
    postPatch = ''
      cp -v ${orca_src}/deps/SLVS/CMakeLists.txt.in CMakeLists.txt
    '';
  });

  wxinspector = clangStdenv.mkDerivation (finalAttrs: {
    pname = "wxinspector";
    version = "1.0.0";

    src = fetchFromGitHub {
      owner = "Noisyfox";
      repo = "wxInspector";
      tag = "v${finalAttrs.version}";
      hash = "sha256-AQbV2vAGJXatAXwLAxhWVXTdKqxj2v0THexQyKbroJw=";
    };

    nativeBuildInputs = [
      cmake
      pkg-config
      wxGTK'
    ];

    buildInputs = [
      wxGTK'
      gtk3
    ];

    cmakeFlags = [
      (lib.cmakeFeature "CMAKE_CXX_FLAGS" "-DwxDEBUG_LEVEL=0")
      (lib.cmakeBool "CMAKE_POSITION_INDEPENDENT_CODE" true)
    ];

    meta = {
      description = "Widget and layout inspection tool for wxWidgets applications";
      homepage = "https://github.com/Noisyfox/wxInspector";
      license = with lib.licenses; [
        lgpl2Plus
        wxWindowsException31
      ];
      platforms = lib.platforms.linux;
    };
  });

  version = "2.5.0";
  orca_src = fetchFromGitHub {
    owner = "OrcaSlicer";
    repo = "OrcaSlicer";
    tag = "v${version}";
    hash = "sha256-WL3tXUkj/XIltcUSSnHGbOXWWLuYZ/hEeZ6L94w72c0=";
  };

  # Keep OpenVDB on Boost 1.83 to match Orca Slicer's Boost ABI and avoid
  # linking against two different Boost versions.
  openvdb' = openvdb.override {
    boost = boost183;
  };

in
# Build with clang even on Linux, because GCC uses absolutely obscene amounts of memory
# on this particular code base (OOM with 32GB memory and --cores 16 on GCC, succeeds
# with --cores 32 on clang).
clangStdenv.mkDerivation (finalAttrs: {
  pname = "orca-slicer";

  inherit version;
  src = orca_src;

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
    wxGTK'
  ];

  buildInputs = [
    binutils
    (boost183.override {
      enableShared = true;
      enableStatic = false;
      extraFeatures = [
        "log"
        "thread"
        "filesystem"
      ];
    })
    boost183.dev
    cereal
    cgal
    curl
    dbus
    draco
    eigen_5
    expat
    ffmpeg
    glew
    glfw
    glib
    glib-networking
    gmp
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad
    (gst_all_1.gst-plugins-good.override { gtkSupport = true; })
    gtk3
    hicolor-icon-theme
    libsecret
    libpng
    mpfr
    nlopt
    opencascade-occt
    openvdb'
    onetbb
    webkitgtk_4_1
    wxGTK'
    libx11
    opencv.cxxdev
    libnoise
    libdatachannel
    python312
    solvespace'
    assimp
    wxinspector
    libsysprof-capture
    pcre2
    uv
  ]
  ++ lib.optionals withSystemd [ systemdLibs ]
  ++ finalAttrs.checkInputs;

  patches = [
    # Fix for webkitgtk linking
    ./patches/0001-not-for-upstream-CMakeLists-Link-against-webkit2gtk-.patch
    # Link opencv_core and opencv_imgproc instead of opencv_world
    ./patches/dont-link-opencv-world-orca.patch
    # The changeset from https://github.com/OrcaSlicer/OrcaSlicer/pull/7650, can be removed when that PR gets merged
    # Allows disabling the update nag screen
    #(fetchpatch {
    #  name = "pr-7650-configurable-update-check.patch";
    #  url = "https://github.com/OrcaSlicer/OrcaSlicer/commit/300df7c99b0a2173f645c8bf40e8758eb5f2c486.patch";
    #  hash = "sha256-hgQeagPhS3aNQoFSq0S+Ch60ygm81uHMIvGopw/AZT8=";
    #})

    # Pick https://github.com/prusa3d/PrusaSlicer/pull/14207 to remove unused and insecure ilmbase dependency
    ./patches/no-ilmbase.patch
  ];

  doCheck = true;
  checkInputs = [ gtest ];

  separateDebugInfo = true;

  env = {
    NLOPT = nlopt;

    NIX_CFLAGS_COMPILE = toString [
      "-Wno-ignored-attributes"
      "-I${opencv.out}/include/opencv4"
      "-Wno-error=incompatible-pointer-types"
      "-Wno-error=format-security"
      "-Wno-uninitialized"
      "-Wno-unused-result"
      "-Wno-deprecated-declarations"
      "-Wno-format-overflow"
      "-DBOOST_ALLOW_DEPRECATED_HEADERS"
      "-DBOOST_MATH_DISABLE_STD_FPCLASSIFY"
      "-DBOOST_MATH_NO_LONG_DOUBLE_MATH_FUNCTIONS"
      "-DBOOST_MATH_DISABLE_FLOAT128"
      "-DBOOST_MATH_NO_QUAD_SUPPORT"
      "-DBOOST_MATH_MAX_FLOAT128_DIGITS=0"
      "-DBOOST_CSTDFLOAT_NO_LIBQUADMATH_SUPPORT"
      "-DBOOST_MATH_DISABLE_FLOAT128_BUILTIN_FPCLASSIFY"
    ];

    NIX_LDFLAGS = toString [
      (lib.optionalString withSystemd "-ludev")
      "-L${boost183}/lib"
      "-lboost_log"
      "-lboost_log_setup"
    ];
  };

  prePatch = ''
    sed -i 's|nlopt_cxx|nlopt|g' cmake/modules/FindNLopt.cmake
    sed -i 's|"libnoise/noise.h"|"noise/noise.h"|' src/libslic3r/PerimeterGenerator.cpp
    sed -i 's|"libnoise/noise.h"|"noise/noise.h"|' src/libslic3r/Feature/FuzzySkin/FuzzySkin.cpp
    sed -i 's|libnoise/module|noise/module|' src/libslic3r/Feature/FuzzySkin/FuzzySkin.cpp
    sed -i 's|e.what()|e.GetMessageString()|g' src/libslic3r/CAD/GeometryEngine.cpp

    sed -i 's|3.12.13|${python312.version}|' CMakeLists.txt
    sed -i 's|orcaslicer_copy_sos|#&|' src/CMakeLists.txt
    # FHS builds use the system Python rather than a bundled runtime, so
    # skip staging the upstream bundled Python runtime into the build tree.
    sed -i '/copy_directory.*CMAKE_PREFIX_PATH.*libpython/s/^/#/' src/CMakeLists.txt
    # The FHS package links against system FFmpeg instead of bundling FFmpeg 6.
    sed -i '/install(FILES .*LIBRARY_FILES.*CMAKE_INSTALL_PREFIX.*bin/s/^/#/' CMakeLists.txt
  ''
  # Fix build with wxWidgets 3.3.4
  # https://github.com/OrcaSlicer/OrcaSlicer/pull/16370
  + ''
    substituteInPlace src/slic3r/GUI/GUI_ObjectTable.cpp \
      --replace-fail "wxGridCellChoiceEditor::OnComboCloseUp(evt)" "wxGridCellChoiceEditor::DismissEditor()"
  '';

  cmakeFlags = [
    (lib.cmakeBool "SLIC3R_STATIC" false)
    (lib.cmakeBool "SLIC3R_FHS" true)
    (lib.cmakeFeature "SLIC3R_GTK" "3")
    (lib.cmakeBool "BBL_RELEASE_TO_PUBLIC" true)
    (lib.cmakeBool "BBL_INTERNAL_TESTING" false)
    (lib.cmakeBool "SLIC3R_BUILD_TESTS" false)
    (lib.cmakeFeature "CMAKE_CXX_FLAGS" "-DGL_SILENCE_DEPRECATION")
    (lib.cmakeFeature "CMAKE_EXE_LINKER_FLAGS" "-Wl,--no-as-needed")
    (lib.cmakeBool "ORCA_VERSION_CHECK_DEFAULT" false)
    (lib.cmakeFeature "LIBNOISE_INCLUDE_DIR" "${libnoise}/include")
    (lib.cmakeFeature "LIBNOISE_LIBRARY_RELEASE" "${libnoise}/lib/libnoise-static.a")
    (lib.cmakeFeature "Python3_EXECUTABLE" (lib.getExe python312))
    (lib.cmakeFeature "ORCA_BUNDLED_UV_EXECUTABLE" (lib.getExe uv))
    "-Wno-dev"
  ];

  # Generate translation files
  postBuild = "( cd .. && ./scripts/run_gettext.sh )";

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "$out/lib:${
        lib.makeLibraryPath [
          glew
        ]
      }"
      --set WEBKIT_DISABLE_COMPOSITING_MODE 1
      ${lib.optionalString withNvidiaGLWorkaround ''
        --set __GLX_VENDOR_LIBRARY_NAME mesa
        --set __EGL_VENDOR_LIBRARY_FILENAMES /run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json
        --set MESA_LOADER_DRIVER_OVERRIDE zink
        --set GALLIUM_DRIVER zink
        --set WEBKIT_DISABLE_DMABUF_RENDERER 1
      ''}
    )
  '';

  postInstall = ''
    rm $out/LICENSE.txt
  '';

  meta = {
    description = "G-code generator for 3D printers (Bambu, Prusa, Voron, VzBot, RatRig, Creality, etc.)";
    homepage = "https://github.com/OrcaSlicer/OrcaSlicer";
    changelog = "https://github.com/OrcaSlicer/OrcaSlicer/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [
      zhaofengli
      ovlach
      pinpox
      liberodark
      zraexy
    ];
    mainProgram = "orca-slicer";
    platforms = lib.platforms.linux;
  };
})
