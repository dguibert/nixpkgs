{ lib
, stdenv
, buildPackages
, targetPackages
}:

rec {
  # These environment variables must be set when using `cargo-c` and
  # several other tools which do not deal well with cross
  # compilation.  The symptom of the problem they fix is errors due
  # to buildPlatform CFLAGS being passed to the
  # hostPlatform-targeted compiler -- for example, `-m64` being
  # passed on a build=x86_64/host=aarch64 compilation.
  envVars = let

    # As a workaround for https://github.com/rust-lang/rust/issues/89626 use lld on pkgsStatic aarch64
    shouldUseLLD = platform: platform.isAarch64 && platform.isStatic && !stdenv.isDarwin;

    ccForBuild = "${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}cc";
    cxxForBuild = "${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}c++";
    linkerForBuild = ccForBuild;

    ccForHost = "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc";
    cxxForHost = "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}c++";
    linkerForHost = if shouldUseLLD stdenv.targetPlatform
      && !stdenv.cc.bintools.isLLVM
      then "${buildPackages.lld}/bin/ld.lld"
      else ccForHost;

    # Unfortunately we must use the dangerous `targetPackages` here
    # because hooks are artificially phase-shifted one slot earlier
    # (they go in nativeBuildInputs, so the hostPlatform looks like
    # a targetPlatform to them).
    ccForTarget = "${targetPackages.stdenv.cc}/bin/${targetPackages.stdenv.cc.targetPrefix}cc";
    cxxForTarget = "${targetPackages.stdenv.cc}/bin/${targetPackages.stdenv.cc.targetPrefix}c++";
    linkerForTarget = if shouldUseLLD targetPackages.stdenv.targetPlatform
      && !targetPackages.stdenv.cc.bintools.isLLVM # whether stdenv's linker is lld already
      then "${buildPackages.lld}/bin/ld.lld"
      else ccForTarget;

    rustBuildPlatform = stdenv.buildPlatform.rust.rustcTarget;
    rustBuildPlatformSpec = stdenv.buildPlatform.rust.rustcTargetSpec;
    rustHostPlatform = stdenv.hostPlatform.rust.rustcTarget;
    rustHostPlatformSpec = stdenv.hostPlatform.rust.rustcTargetSpec;
    rustTargetPlatform = stdenv.targetPlatform.rust.rustcTarget;
    rustTargetPlatformSpec = stdenv.targetPlatform.rust.rustcTargetSpec;
  in {
    inherit
      ccForBuild  cxxForBuild  linkerForBuild  rustBuildPlatform   rustBuildPlatformSpec
      ccForHost   cxxForHost   linkerForHost   rustHostPlatform    rustHostPlatformSpec
      ccForTarget cxxForTarget linkerForTarget rustTargetPlatform  rustTargetPlatformSpec;

    # Prefix this onto a command invocation in order to set the
    # variables needed by cargo.
    #
    setEnv = ''
    env \
    ''
    # Due to a bug in how splicing and targetPackages works, in
    # situations where targetPackages is irrelevant
    # targetPackages.stdenv.cc is often simply wrong.  We must omit
    # the following lines when rustTargetPlatform collides with
    # rustHostPlatform.
    + lib.optionalString (rustTargetPlatform != rustHostPlatform) ''
      "CC_${stdenv.targetPlatform.rust.cargoEnvVarTarget}=${ccForTarget}" \
      "CXX_${stdenv.targetPlatform.rust.cargoEnvVarTarget}=${cxxForTarget}" \
      "CARGO_TARGET_${stdenv.targetPlatform.rust.cargoEnvVarTarget}_LINKER=${linkerForTarget}" \
    '' + ''
      "CC_${stdenv.hostPlatform.rust.cargoEnvVarTarget}=${ccForHost}" \
      "CXX_${stdenv.hostPlatform.rust.cargoEnvVarTarget}=${cxxForHost}" \
      "CARGO_TARGET_${stdenv.hostPlatform.rust.cargoEnvVarTarget}_LINKER=${linkerForHost}" \
    '' + ''
      "CC_${stdenv.buildPlatform.rust.cargoEnvVarTarget}=${ccForBuild}" \
      "CXX_${stdenv.buildPlatform.rust.cargoEnvVarTarget}=${cxxForBuild}" \
      "CARGO_TARGET_${stdenv.buildPlatform.rust.cargoEnvVarTarget}_LINKER=${linkerForBuild}" \
      "CARGO_BUILD_TARGET=${rustBuildPlatform}" \
      "HOST_CC=${buildPackages.stdenv.cc}/bin/cc" \
      "HOST_CXX=${buildPackages.stdenv.cc}/bin/c++" \
    '';
  };
} // lib.mapAttrs (old: new: platform:
  # TODO: enable warning after 23.05 is EOL.
  # lib.warn "`rust.${old} platform` is deprecated. Use `platform.rust.${new}` instead."
    lib.getAttrFromPath new platform.rust)
{
  toTargetArch = [ "platform" "arch" ];
  toTargetOs = [ "platform" "os" ];
  toTargetFamily = [ "platform" "target-family" ];
  toTargetVendor = [ "platform" "vendor" ];
  toRustTarget = [ "rustcTarget" ];
  toRustTargetSpec = [ "rustcTargetSpec" ];
  toRustTargetSpecShort = [ "cargoShortTarget" ];
  toRustTargetForUseInEnvVars = [ "cargoEnvVarTarget" ];
  IsNoStdTarget = [ "isNoStdTarget" ];
}
