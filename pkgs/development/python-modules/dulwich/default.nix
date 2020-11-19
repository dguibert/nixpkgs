{ stdenv, buildPythonPackage, fetchPypi
, urllib3, certifi
, gevent, geventhttpclient, mock, fastimport
, git, glibcLocales }:

buildPythonPackage rec {
  version = "0.20.14";
  pname = "dulwich";

  src = fetchPypi {
    inherit pname version;
    sha256 = "21d6ee82708f7c67ce3fdcaf1f1407e524f7f4f7411a410a972faa2176baec0d";
  };

  LC_ALL = "en_US.UTF-8";

  propagatedBuildInputs = [ urllib3 certifi ];

  # Only test dependencies
  checkInputs = [ git glibcLocales gevent geventhttpclient mock fastimport ];

  #   test_finder (dulwich.tests.test_greenthreads.TestGreenThreadsMissingObjectFinder) ... /nix/store/bpjmywpnw8bvwlbmzbg6gyvj2a2k1b3l-setuptools-check-hook/nix-support/setup-hook: line 4:   289 Segmentation fault      (core dumped) /nix/store/18656kvqazm74bj7k3mdkwmdlqfyf581-python3-3.8.6/bin/python3.8 nix_run_setup test
  doCheck = false; #!stdenv.isDarwin;

  meta = with stdenv.lib; {
    description = "Simple Python implementation of the Git file formats and protocols";
    homepage = "https://samba.org/~jelmer/dulwich/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ koral ];
  };
}
