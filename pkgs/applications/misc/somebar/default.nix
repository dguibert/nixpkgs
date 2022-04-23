{ stdenv, fetchFromSourcehut
, meson, ninja, cmake, wayland
, pkg-config
, cairo, pango
, wayland-protocols
, patches ? []
}:

stdenv.mkDerivation {
  pname = "somebar";
  version = "unstable-2022-04-21";

  src = fetchFromSourcehut {
    owner = "~raphi";
    repo = "somebar";
    rev = "85b7b6290aff2c121dc6ced132f3e3d13ebb3ec6";
    sha256 = "sha256-2gp+NO8vJ5c56NyMuGFfSjN232F09dFVExRzC5nkWvI=";
  };

  buildInputs = [
    meson ninja cmake wayland
    pkg-config
    cairo pango
    wayland-protocols
  ];

  preConfigure = ''
    cp -v src/config.def.hpp src/config.hpp
  '';
}
