{ PyGithub, annexremote, appdirs, boto, buildPythonPackage, chardet, fasteners
, fetchPypi, humanize, iso8601, jsmin, keyring, keyrings-alt, lib, msgpack
, patool, requests, simplejson, tqdm, whoosh, wrapt, setuptools
, requests-ftp
, fetchFromGitHub
}:

buildPythonPackage rec {
  pname = "datalad";
  version = "0.14.7";

  src = fetchFromGitHub {
    owner = "datalad";
    repo = "datalad";
    rev = "refs/tags/${version}";
    sha256 = "sha256-xCJDpzgZrTFcC8uDqT4P9+nLjkd/gB0QqB4hw7Ja0g8=";
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
    boto
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
  ];

  # TODO FIXME
  doCheck = false;

  preConfigure = ''
    # ERROR: Could not find a version that satisfies the requirement distro; python_version >= "3.8" (from datalad==0.13.4) (from versions: none)
    # ERROR: No matching distribution found for distro; python_version >= "3.8" (from datalad==0.13.4)
    sed -i -e "s@'distro; python_version@#'distro; python_version@" setup.py
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
