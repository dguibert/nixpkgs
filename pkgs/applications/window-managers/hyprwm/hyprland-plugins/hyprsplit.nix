{
  lib,
  meson,
  fetchFromGitHub,
  ninja,
  mkHyprlandPlugin,
  nix-update-script,
  fetchpatch
}:
mkHyprlandPlugin (finalAttrs: {
  pluginName = "hyprsplit";
  version = "0.53.3";

  src = fetchFromGitHub {
    owner = "shezdy";
    repo = "hyprsplit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TckWMPtJ5EHPnK11iJagiJoCaSJITAWl2kxk4mop+H8=";
  };
  
  patches = [
    (fetchpatch {
        url = "https://github.com/shezdy/hyprsplit/commit/a83c66201832f93ece9622f46015995734d41b73.patch";
        hash = "sha256-SXDGTR5H3Qi3tOCV9EHc+L948JZ6jRMenpNsAVwG7RQ=";
      })
    (fetchpatch {
        url = "https://github.com/shezdy/hyprsplit/commit/1001864436452cc785e1a3ecdcaf68e27fadbafb.patch";
        hash = "sha256-QKCS4L3e6Hfr/CgzvTOtcIDLTRbl4T02E1NWx6Oxbqw=";
      })
    (fetchpatch {
      name = "hyprsplit-issue-74.patch";
      url = "https://github.com/shezdy/hyprsplit/commit/1d8ab25e03a68e136a5534c25890da2e5b25488b.patch";
      hash = "sha256-xIIpyhAErhfQtkETbvOtgLC9d7udUyrwrs87lDd/iB4=";
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/shezdy/hyprsplit";
    description = "Hyprland plugin for awesome / dwm like workspaces";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [
      aacebedo
    ];
  };
})
