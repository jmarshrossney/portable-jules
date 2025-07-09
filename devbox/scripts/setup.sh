# Check script was executed using devbox run or in a devbox shell
if [[ ! $DEVBOX_SHELL_ENABLED -eq 1 ]]; then
    echo "This script must be run inside a devbox shell"
    echo "(The value of \$DEVBOX_SHELL_ENABLED is: $DEVBOX_SHELL_ENABLED)"
    exit 1
fi
# Check that FCM and JULES directories are not in use already
if [ -d "$FCM_ROOT" ]; then
    echo "There is already a directory at $FCM_ROOT"
    exit 1
fi
if [ -d "$JULES_ROOT" ]; then
    echo "There is already a directory at $JULES_ROOT"
    exit 1
fi

# Exit if any subsequent command returns non-zero exit status
set -e

# ------------------------------------------- #
#  Read MOSRS credentials and JULES revision  #
# ------------------------------------------- #

# Attempt to read from env variables, otherwise take default values
REVISION="${JULES_REVISION:-HEAD}"
USERNAME="${MOSRS_USERNAME:-__MISSING__}"
PASSWORD="${MOSRS_PASSWORD:-__MISSING__}"

# Attempt to read from command-line args
while getopts "r:u:p" opt; do
    case $opt in
        r)
            REVISION=$OPTARG
	    ;;
	u)
	    USERNAME=$OPTARG
	    ;;
	p)
	    PASSWORD=$OPTARG
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1
	    ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
	    ;;
    esac
done

# Check that MOSRS credentials have been set
if [ "$USERNAME" = "__MISSING__" ] || [ -z "$PASSWORD" = "__MISSING__" ]; then
    echo "Must provide a username and password!"
    exit 1
fi

# Switch to temporary directory
curr_dir="$PWD"
tmpdir="$DEVBOX_PROJECT_ROOT/_tmp"
mkdir -v "$tmpdir"
cd "$tmpdir"


# ------------------------------------------------------ #
#  Download and extract fcm if it doesn't already exist  #
# ------------------------------------------------------ #

# NOTE: hard-coded most recent version, but releases are *very* infrequent
fcm_version="2021.05.0"
fcm_release="https://github.com/metomi/fcm/archive/refs/tags/${fcm_version}.tar.gz"

echo "Downloading and extracting $fcm_release to $FCM_ROOT"
curl -L $fcm_release | tar -xz

mkdir -p -v "$(dirname $FCM_ROOT)"
mv -v fcm-$fcm_version "$FCM_ROOT"


# -------------------------------------------- #
#  Download JULES if it doesn't already exist  #
# -------------------------------------------- #
echo "Downloading JULES, revision $REVISION"

svn checkout --non-interactive --no-auth-cache  \
    --username "$USERNAME" --password "$PASSWORD" \
    https://code.metoffice.gov.uk/svn/jules/main/trunk --revision "$REVISION" \
    jules

# NOTE: need to add the -fallow-argument-mismatch -w flags so that gfortran doesn't complain
printf '\n# We are forced to suppress a gfortran error about non-standard code\nbuild.prop{fc.flags}[jules/src/io/dump/read_dump_mod.F90] = $fflags_common -fallow-argument-mismatch -w' >> jules/etc/fcm-make/platform/custom.cfg

mkdir -p -v "$(dirname $JULES_ROOT)"
mv -v jules "$JULES_ROOT"


# Return to original directory and delete temporary directory
cd "$curr_dir"
rmdir -v "$tmpdir"


# ------------- #
#  Build JULES  #
# ------------- #
mkdir -p -v "$JULES_BUILD_DIR"
echo "Building JULES"
"$FCM_ROOT/bin/fcm" make -f "$JULES_ROOT/etc/fcm-make/make.cfg" -C "$JULES_BUILD_DIR" --new

echo "Setup completed successfully"
