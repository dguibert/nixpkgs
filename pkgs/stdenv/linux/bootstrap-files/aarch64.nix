{
  busybox = import <nix/fetchurl.nix> {
    url = "http://tarballs.nixos.org/stdenv-linux/aarch64/571cbf3d1db477058303cef8754fb85a14e90eb7/busybox";
    sha256 = "sha256-4EN2vLvXUkelZZR2eKaAQA5kCEuHNvRZN6dcohxVY+c=";
    executable = true;
  };
  bootstrapTools = import <nix/fetchurl.nix> {
    url = "http://tarballs.nixos.org/stdenv-linux/aarch64/571cbf3d1db477058303cef8754fb85a14e90eb7/bootstrap-tools.tar.xz";
    sha256 = "17sv9pqwz6p8zqnfbsqcql5zx3wh156qdfrfqrgi5079i29b2rjl";
  };
}
