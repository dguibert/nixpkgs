{ buildPythonPackage, fetchurl, stdenv, isPy27
, nose, pillow, prettytable, pyyaml, dateutil, gdata
, requests, mechanize, feedparser, lxml, gnupg, pyqt5
, libyaml, simplejson, cssselect, futures, pdfminer
, termcolor, google_api_python_client, html2text
, unidecode
}:

buildPythonPackage rec {
  pname = "weboob";
  version = "1.5";
  disabled = ! isPy27;

  src = fetchurl {
    url = "https://git.weboob.org/weboob/weboob/-/archive/1.5/weboob-1.5.tar.gz";
    sha256 = "sha256:0l6q5nm5g0zn6gmf809059kddrbds27wgygxsfkqja9blks5vq7z";
  };

  postPatch = ''
    # Disable doctests that require networking:
    sed -i -n -e '/^ *def \+pagination *(.*: *$/ {
      p; n; p; /"""\|'\'\'\'''/!b

      :loop
      n; /^ *\(>>>\|\.\.\.\)/ { h; bloop }
      x; /^ *\(>>>\|\.\.\.\)/bloop; x
      p; /"""\|'\'\'\'''/b
      bloop
    }; p' weboob/browser/browsers.py weboob/browser/pages.py
  '';

  setupPyBuildFlags = ["--qt" "--xdg"];

  checkInputs = [ nose ];

  nativeBuildInputs = [ pyqt5 ];

  propagatedBuildInputs = [ pillow prettytable pyyaml dateutil
    gdata requests mechanize feedparser lxml gnupg pyqt5 libyaml
    simplejson cssselect futures pdfminer termcolor
    google_api_python_client html2text unidecode ];

  checkPhase = ''
    nosetests
  '';

  meta = {
    homepage = http://weboob.org;
    description = "Collection of applications and APIs to interact with websites without requiring the user to open a browser";
    license = stdenv.lib.licenses.agpl3;
  };
}

