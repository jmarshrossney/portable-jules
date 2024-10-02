# Check inside devbox shell
if [[ ! $DEVBOX_SHELL_ENABLED -eq 1 ]]; then
    echo "Value of \$DEVBOX_SHELL_ENABLED is: $DEVBOX_SHELL_ENABLED"
    echo "This script must be run inside a devbox shell"
    exit 1
fi
echo "continuing..."

if [ ! -d $1 ]; then
    echo "Provide an existing namelist directory"
    exit 1
fi

# Hack to get absolute path
namelist_abspath=$(cd "$1"; pwd)
echo "Namelist path is $namelist_abspath"

# NOTE: output_dir is hard-coded into output.nml, so the following doesn't work
#
#timestamp=$(date +'%Y-%m-%d_%H%M%S')
#output_dir=$JULES_EXEC_DIR/$timestamp
#mkdir -p -v $output_dir

jules.exe $namelist_abspath
