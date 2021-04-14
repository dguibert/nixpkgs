{ lib, stdenv, fetchurl, makeWrapper, buildGoModule, git
, asciidoctor, ruby
, breezy ? null, cvs ? null, darcs ? null, fossil ? null
, mercurial ? null, monotone ? null, rcs ? null
, subversion ? null, cvs_fast_export ? null }:

with stdenv; with lib;
buildGoModule rec {
  name = "reposurgeon-${meta.version}";
  meta = {
    description = "A tool for editing version-control repository history";
    version = "4.26";
    license = licenses.bsd3;
    homepage = "http://www.catb.org/esr/reposurgeon/";
    maintainers = with maintainers; [ dfoxfranke ];
    platforms = platforms.all;
  };

  src = fetchurl {
    url = "http://www.catb.org/~esr/reposurgeon/reposurgeon-4.26.tar.xz";
    sha256 = "sha256-FuL5pvIM468hEm6rUBKGW6+WlYv4DPHNnpwpRGzMwlY=";
  };

  vendorSha256 = "sha256-KpdXI2Znhe0iCp0DjSZXzUYDZIz2KBRv1/SpaRTFMAc=";

  subPackages = [ "." ];

  runVend = true;

  nativeBuildInputs = [ asciidoctor ruby ];

  postBuild = ''
    patchShebangs .
    make all HTMLFILES=
  '';
  postInstall = ''
    make install prefix=$out HTMLFILES=
  '';
}
