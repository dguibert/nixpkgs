{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "spoolman2slicer";
  version = "0.10.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "bofh69";
    repo = "spoolman2slicer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+4LKhk7a2IaY/a+9IGBcGnpALFLSjwIYbWw14GAhgeg=";
  };

  postPatch = ''
    substituteInPlace spoolman2slicer.py create_template_files.py \
      --replace-fail 'VERSION = "0.0.2-3-gdf67a39"' 'VERSION = "${finalAttrs.version}"'
  '';

  pythonRelaxDeps = [
    "requests"
    "websockets"
  ];

  build-system = with python3Packages; [
    setuptools
    wheel
  ];

  dependencies = with python3Packages; [
    appdirs
    jinja2
    requests
    websockets
  ];

  nativeCheckInputs = [ python3Packages.pytestCheckHook ];
  doCheck = true;

  postInstall = ''
    for template_dir in $out/share/spoolman2slicer/templates-*; do
      ln -s "$template_dir" "$out/${python3Packages.python.sitePackages}/$(basename "$template_dir")"
    done
  '';

  meta = {
    description = "Export Spoolman data to filament configuration files for 3D printer slicers";
    homepage = "https://github.com/bofh69/spoolman2slicer";
    license = lib.licenses.gpl3Plus;
    mainProgram = "spoolman2slicer";
    maintainers = with lib.maintainers; [ dguibert ];
  };
})
