{ lib, buildPackages, fetchurl, perl, buildLinux, modDirVersionArg ? null, ... } @ args:

with lib;

buildLinux (args // rec {
  version = "5.11-rc7";
  extraMeta.branch = "5.11";

  # modDirVersion needs to be x.y.z, will always add .0
  modDirVersion = if (modDirVersionArg == null) then builtins.replaceStrings ["-"] [".0-"] version else modDirVersionArg;

  src = fetchurl {
    url = "https://git.kernel.org/torvalds/t/linux-${version}.tar.gz";
    sha256 = "sha256-Ybk7n3JRI3+lWT61DRtYRXUsKGXMqyi9s4oY/a/PJyA=";
  };

  # Should the testing kernels ever be built on Hydra?
  extraMeta.hydraPlatforms = [];

} // (args.argsOverride or {}))
