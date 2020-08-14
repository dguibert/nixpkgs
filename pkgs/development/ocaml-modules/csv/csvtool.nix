{ lib, buildDunePackage, ocaml, csv, ocaml_lwt, uutf }:

if !lib.versionAtLeast ocaml.version "4.02"
then throw "csvtool is not available for OCaml ${ocaml.version}"
else

buildDunePackage {
  pname = "csvtool";
  inherit (csv) src version meta;

  propagatedBuildInputs = [ csv ocaml_lwt uutf ];

  doCheck = lib.versionAtLeast ocaml.version "4.03";
}
