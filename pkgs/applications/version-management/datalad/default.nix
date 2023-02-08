{ lib, stdenv, fetchFromGitHub, installShellFiles, python3, git }:

python3.pkgs.buildPythonApplication rec {
  pname = "datalad";
  version = "0.18.1";

  src = fetchFromGitHub {
    owner = "datalad";
    repo = pname;
    rev = version;
    hash = "sha256-xqxeT5iRkbkGv1HvsNkO0GKqHtQOkcYuSKjLdqH7ooU=";
  };

  nativeBuildInputs = [ installShellFiles git ];

  postUnpack = ''
    sed -i -e "s@'chardet>=3.0.4, <5.0.0'@'chardet'@" $sourceRoot/setup.py
  '';

  propagatedBuildInputs = with python3.pkgs; [
    # core
    platformdirs
    chardet
    iso8601
    humanize
    fasteners
    packaging
    patool
    tqdm
    annexremote
    looseversion

    # downloaders-extra
    requests-ftp

    # downloaders
    boto
    keyrings-alt
    keyring
    msgpack
    requests

    # publish
    python-gitlab

    # misc
    argcomplete
    pyperclip
    python-dateutil

    # metadata
    simplejson
    whoosh

    # metadata-extra
    pyyaml
    mutagen
    exifread
    python-xmp-toolkit
    pillow

    # duecredit
    duecredit

    # python>=3.8
    distro
  ] ++ lib.optionals stdenv.hostPlatform.isWindows [ colorama ]
    ++ lib.optionals (python3.pythonOlder "3.10") [ importlib-metadata ];

  postInstall = ''
    installShellCompletion --cmd datalad \
         --bash <($out/bin/datalad shell-completion) \
         --zsh  <($out/bin/datalad shell-completion)
  '';

  # no tests
  doCheck = false;

  meta = with lib; {
    description = "Keep code, data, containers under control with git and git-annex";
    homepage = "https://www.datalad.org";
    license = licenses.mit;
    maintainers = with maintainers; [ renesat ];
  };
}
