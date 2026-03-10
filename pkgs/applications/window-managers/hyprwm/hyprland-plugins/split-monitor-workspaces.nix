{
  lib,
  mkHyprlandPlugin,
  hyprland,
  fetchFromGitHub,
  pango,
  cairo,
  meson,
  ninja,
  unstableGitUpdater
}:

mkHyprlandPlugin hyprland {
  pluginName = "split-monitor-worksapces";
  version = "0.1-unstable-2024-12-04";

  src = fetchFromGitHub {
    owner = "Duckonaut";
    repo = "split-monitor-workspaces";
    rev = "131bc5bd02d7f558a66d1a6c4d0013d8545823e0"; # 0.45.2
    hash = "sha256-T9NTy1oGLv4FGHXK501OS6bSDfvAsyIGuoiJBAo+3IU=";
  };
  
  buildInputs = [
    meson
    ninja
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    homepage = "https://github.com/Duckonaut/split-monitor-workspaces";
    description = "A small Hyprland plugin to provide awesome-like workspace behavior";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
  };
}
