{
  lib,
  meson,
  fetchFromGitHub,
  ninja,
  mkHyprlandPlugin,
  nix-update-script,
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
