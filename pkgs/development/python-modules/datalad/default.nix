{ PyGithub, annexremote, appdirs, boto, buildPythonPackage, chardet, fasteners
, fetchPypi, humanize, iso8601, jsmin, keyring, keyrings-alt, lib, msgpack
, patool, requests, simplejson, tqdm, whoosh, wrapt, setuptools
, requests-ftp, python-gitlab
, fetchFromGitHub
}:

buildPythonPackage rec {
  pname = "datalad";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "datalad";
    repo = "datalad";
    rev = "refs/tags/${version}";
    sha256 = "sha256-h/MGWpsyB6NKlocW6S6Wd2RapKksIvOxM1NolubSP7w=";
  };

  propagatedBuildInputs = [
    appdirs
    chardet
    iso8601
    humanize
    fasteners
    patool
    tqdm
    wrapt
    annexremote
    #boto # downloaders/s3: migrate from boto (2.x) to boto3: https://github.com/datalad/datalad/issues/5597
    keyring
    keyrings-alt
    msgpack
    requests
    jsmin
    PyGithub
    simplejson
    whoosh
    setuptools
    requests-ftp
    python-gitlab
  ];

  # TODO FIXME
  doCheck = false;

  preConfigure = ''
    # ERROR: Could not find a version that satisfies the requirement distro; python_version >= "3.8" (from datalad==0.13.4) (from versions: none)
    # ERROR: No matching distribution found for distro; python_version >= "3.8" (from datalad==0.13.4)
    sed -i -e "s@'distro; python_version@#'distro; python_version@" setup.py

    sed -i -e "s@        'boto',@@" setup.py

  '';

  postFixup = ''
    for f in $out/lib/python*/site-packages/datalad/resources/procedures/*.py; do
      echo "wrapping $f"
      patchPythonScript $f
    done
  '';


  meta = with lib; {
    description = "data distribution geared toward scientific datasets";
  };
}
