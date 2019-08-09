{ stdenv, fetchFromGitHub, autoreconfHook }:

stdenv.mkDerivation rec {
  pname = "libsass";
  version = "3.6.1";

  src = fetchFromGitHub {
    owner = "sass";
    repo = pname;
    rev = version;
    sha256 = "1599j2lbsygy3883x9si7rbad1pkjhl6y72aimaapcv90ga5kxkm";
    # Remove unicode file names which leads to different checksums on HFS+
    # vs. other filesystems because of unicode normalisation.
    postFetch = ''
      unpackDir="$TMPDIR/unpack"
      mkdir "$unpackDir"
      cd "$unpackDir"

      renamed="$TMPDIR/${pname}-${version}.tar.gz"
      mv "$downloadedFile" "$renamed"
      unpackFile "$renamed"
      if [ $(ls "$unpackDir" | wc -l) != 1 ]; then
        echo "error: zip file must contain a single file or directory."
        echo "hint: Pass stripRoot=false; to fetchzip to assume flat list of files."
        exit 1
      fi
      fn=$(cd "$unpackDir" && echo *)
      if [ -f "$unpackDir/$fn" ]; then
        mkdir $out
      fi
      rm -r $unpackDir/$fn/test/e2e/unicode-pwd
      mv "$unpackDir/$fn" "$out"
    '';
  };

  preConfigure = ''
    export LIBSASS_VERSION=${version}
  '';

  nativeBuildInputs = [ autoreconfHook ];

  meta = with stdenv.lib; {
    description = "A C/C++ implementation of a Sass compiler";
    homepage = https://github.com/sass/libsass;
    license = licenses.mit;
    maintainers = with maintainers; [ codyopel offline ];
    platforms = platforms.unix;
  };
}
