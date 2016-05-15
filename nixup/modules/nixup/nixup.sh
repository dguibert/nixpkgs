#! @shell@

if [ -x "@shell@" ]; then export SHELL="@shell@"; fi;

set -e

showSyntax() {
    echo "Nixuser does not have a help, yet. Please help to improve it!"
    exit 1
}


# Add a sensible default value for <nixup-config> to NIX_PATH.
if [[ $NIX_PATH != *"nixup-config"* ]]; then
  export NIX_PATH=$NIX_PATH:nixup-config=$XDG_CONFIG_HOME/nixup/profile.nix
fi


# Parse the command line.
origArgs=("$@")
extraBuildFlags=()
action=
buildNix=1
rollback=
upgrade=
profile=/nix/var/nix/profiles/nixup/$(whoami)/default


while [ "$#" -gt 0 ]; do
    i="$1"; shift 1
    case "$i" in
      --help)
        showSyntax
        ;;
      switch|login|build|dry-run|edit)
        action="$i"
        ;;
      --rollback)
        rollback=1
        ;;
      --upgrade)
        upgrade=1
        ;;
      --show-trace|--no-build-hook|--keep-failed|-K|--keep-going|-k|--verbose|-v|-vv|-vvv|-vvvv|-vvvvv|--fallback|--repair|--no-build-output|-Q)
        extraBuildFlags+=("$i")
        ;;
      --max-jobs|-j|--cores|-I)
        j="$1"; shift 1
        extraBuildFlags+=("$i" "$j")
        ;;
      --option)
        j="$1"; shift 1
        k="$1"; shift 1
        extraBuildFlags+=("$i" "$j" "$k")
        ;;
      --profile-name|-p)
        if [ -z "$1" ]; then
            echo "$0: ‘--profile-name’ requires an argument"
            exit 1
        fi
        if [ "$1" != default ]; then
            profile="/nix/var/nix/profiles/nixup/$(whoami)/$1"
        fi
        shift 1
        ;;
      *)
        echo "$0: unknown option \`$i'"
        exit 1
        ;;
    esac
done

if [ -z "$action" ]; then showSyntax; fi


if [ "$action" = edit ]; then
    if [ -n "$EDITOR" ]; then
        $EDITOR $XDG_CONFIG_HOME/nixup/profile.nix
    else
        echo "ERROR: \$EDITOR environment variable not set!"
    fi
    exit 0
fi

# Only run shell scripts from the Nixpkgs tree if the action is
# "switch", or "dry-run". With other actions (such as "build"), the
# user may reasonably expect that no code from the Nixpkgs tree is
# executed, so it's safe to run nixos-rebuild against a potentially
# untrusted tree.
canRun=
if [ "$action" = switch -o "$action" = test ]; then
    canRun=1
fi


# If ‘--upgrade’ is given, run ‘nix-channel --update nixup’.
if [ -n "$upgrade" -a -z "$_NIXOS_REBUILD_REEXEC" ]; then
    nix-channel --update nixup
fi

# Make sure that we use the Nix package we depend on, not something
# else from the PATH for nix-{env,instantiate,build}.  This is
# important, because NixOS defaults the architecture of the rebuilt
# system to the architecture of the nix-* binaries used.  So if on an
# amd64 system the user has an i686 Nix package in her PATH, then we
# would silently downgrade the whole system to be i686 NixOS on the
# next reboot.
if [ -z "$_NIXOS_REBUILD_REEXEC" ]; then
    export PATH=@nix@/bin:$PATH
fi

# Re-execute nixos-rebuild from the Nixpkgs tree.
if [ -z "$_NIXOS_REBUILD_REEXEC" -a -n "$canRun" ]; then
    if p=$(nix-instantiate --find-file nixpkgs/nixup/modules/nixup/nixup.sh "${extraBuildFlags[@]}"); then
        export _NIXOS_REBUILD_REEXEC=1
        exec $SHELL -e $p "${origArgs[@]}"
        exit 1
    fi
fi


tmpDir=$(mktemp -t -d nixup.XXXXXX)
trap 'rm -rf "$tmpDir"' EXIT


# If the Nix daemon is running, then use it.  This allows us to use
# the latest Nix from Nixpkgs (below) for expression evaluation, while
# still using the old Nix (via the daemon) for actual store access.
if systemctl show nix-daemon.socket nix-daemon.service | grep -q ActiveState=active; then
    export NIX_REMOTE=${NIX_REMOTE:-daemon}
fi


# First build Nix, since NixOS may require a newer version than the
# current one.
if [ -n "$rollback" -o "$action" = dry-run ]; then
    buildNix=
fi

if [ -n "$buildNix" ]; then
    echo "building Nix..." >&2
    if ! nix-build '<nixpkgs/nixup>' -A config.nix.package -o $tmpDir/nix "${extraBuildFlags[@]}" > /dev/null; then
        if ! nix-build '<nixpkgs/nixos>' -A config.nix.package -o $tmpDir/nix "${extraBuildFlags[@]}" > /dev/null; then
            if ! nix-build '<nixpkgs/nixos>' -A nixFallback -o $tmpDir/nix "${extraBuildFlags[@]}" > /dev/null; then
                if ! nix-build '<nixpkgs>' -A nix -o $tmpDir/nix "${extraBuildFlags[@]}" > /dev/null; then
                    machine="$(uname -m)"
                    if [ "$machine" = x86_64 ]; then
                        nixStorePath=/nix/store/d34q3q2zj9nriq4ifhn3dnnngqvinjb3-nix-1.7
                    elif [[ "$machine" =~ i.86 ]]; then
                        nixStorePath=/nix/store/qlah0darpcn6sf3lr2226rl04l1gn4xz-nix-1.7
                    else
                        echo "$0: unsupported platform"
                        exit 1
                    fi
                    if ! nix-store -r $nixStorePath --add-root $tmpDir/nix --indirect \
                        --option extra-binary-caches http://cache.nixos.org/; then
                        echo "warning: don't know how to get latest Nix" >&2
                    fi
                    # Older version of nix-store -r don't support --add-root.
                    [ -e $tmpDir/nix ] || ln -sf $nixStorePath $tmpDir/nix
                fi
            fi
        fi
    fi
    PATH=$tmpDir/nix/bin:$PATH
fi


if [ "$action" = dry-run ]; then
    extraBuildFlags+=(--dry-run)
fi


# Either upgrade the configuration in the nixup user profile (for "switch"),
# or build it and create a symlink "result" in the current directory (for
# "build").
if [ -z "$rollback" ]; then
    echo "building the user configuration..." >&2
    if [ "$action" = switch -o "$action" = login ]; then
        nix-env "${extraBuildFlags[@]}" -p "$profile" -f '<nixpkgs/nixup>' --set -A profile
        pathToConfig="$profile"
    elif [ "$action" = build -o "$action" = dry-run ]; then
        nix-build '<nixpkgs/nixup>' -A profile -k "${extraBuildFlags[@]}" > /dev/null
        pathToConfig=./result
    else
        showSyntax
    fi
else # [ -n "$rollback" ]
    if [ "$action" = switch -o "$action" = login ]; then
        nix-env --rollback -p "$profile"
        pathToConfig="$profile"
    elif [ "$action" = build ]; then
        systemNumber=$(
            nix-env -p "$profile" --list-generations |
            sed -n '/current/ {g; p;}; s/ *\([0-9]*\).*/\1/; h'
        )
        ln -sT "$profile"-${systemNumber}-link ./result
        pathToConfig=./result
    else
        showSyntax
    fi
fi


# Activate new profile immediately for "switch"
if [ "$action" = switch ]; then
    # Disable removal of old profile within activation script
    export NIXUP_ACTIVATE_NO_CLEANUP="true"
    if ! $pathToConfig/activate; then
        echo "warning: error(s) occured while activating the new configuration" >&2
        exit 1
    fi
    if ! $pathToConfig/bin/switch-systemd-services "$action"; then
        echo "warning: error(s) occured while switching to the new configuration" >&2
        exit 1
    fi
    # Remove old profile that was not removed in activation script
    rm -f $XDG_RUNTIME_DIR/nixup/old-active-profile
fi


