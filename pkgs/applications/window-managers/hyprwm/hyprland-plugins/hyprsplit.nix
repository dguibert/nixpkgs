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
  version = "0.54.3";

  src = fetchFromGitHub {
    owner = "shezdy";
    repo = "hyprsplit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0/b9n3NvXiA2NGz2Bt/h8TLyBc+twJiHriHyI8JovdI=";
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
      mrdev023
    ];
  };
})
