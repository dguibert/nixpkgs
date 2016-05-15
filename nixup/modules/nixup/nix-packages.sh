#! @shell@

CONFIG_FILE=$XDG_CONFIG_HOME/nixup/packages.nix
PACKAGE_NAME=$package

ACTION=

while [ "$#" -gt 0 ]; do
    i="$1"; shift 1
    case "$i" in
      install|remove)
        ACTION="$i"
        PACKAGE_NAME="$1"; shift 1
        ;;
      *)
        echo "$0: unknown option \`$i'"
        exit 1
        ;;
    esac
done

if [ "$ACTION" = "remove" ]; then
    if [ -e $CONFIG_FILE ]; then
        @gnused@/bin/sed -n "/^$PACKAGE_NAME\$/q 1" $CONFIG_FILE
        if [ $? == 1 ]; then
            echo "Removing $PACKAGE_NAME..."
            @gnused@/bin/sed -i "/^$PACKAGE_NAME\$/d" $CONFIG_FILE
            @gnused@/bin/sed -i '/^[[:space:]]*$/d' $CONFIG_FILE
            @nixup@/bin/nixup switch
        else
            echo "ERROR: $PACKAGE_NAME is not installed!"
            exit 1
        fi
    else
        echo "ERROR: $PACKAGE_NAME is not installed!"
        exit 1
    fi
fi


if [ "$ACTION" = "install" ]; then
    isAvailable=$(@nix@/bin/nix-instantiate --eval -E "builtins.hasAttr \"$PACKAGE_NAME\" (import <nixpkgs> {})")
    if [ "$isAvailable" == "false" ]; then
        echo "ERROR: Package is not available."
        exit 1
    fi
    if [ -e $CONFIG_FILE ]; then
        @gnused@/bin/sed -n "/^$PACKAGE_NAME\$/q 1" $CONFIG_FILE
        if [ $? == 0 ]; then
            echo "Installing $PACKAGE_NAME..."
            echo "$PACKAGE_NAME" >> $CONFIG_FILE
            @gnused@/bin/sed -i '/^[[:space:]]*$/d' $CONFIG_FILE
            @nixup@/bin/nixup switch
        else
            echo "WARNING: $PACKAGE_NAME is already installed!"
            exit 1
        fi
    else
        @coreutils@/bin/mkdir -p $(dirname $CONFIG_FILE)
        echo "Installing $PACKAGE_NAME..."
        echo "$PACKAGE_NAME" > $CONFIG_FILE
        @nixup@/bin/nixup switch
    fi
fi
