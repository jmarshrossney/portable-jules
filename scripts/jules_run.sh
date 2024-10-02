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

# NOTE: prefer running within namelist dir since relative paths are more important
# than flexibility with working dir. 
# See https://jules-lsm.github.io/latest/building-and-running/running-jules.html

# Hack to get absolute path
namelist_abspath=$(cd "$1"; pwd)
echo "Namelist path is $namelist_abspath"

curr_dir=$(pwd)
cd $namelist_abspath

# Extract output dir (hard-coded into output.nml)
output_dir=$(grep "output_dir" output.nml | sed -E "s/output_dir='([^']*)'.*/\1/")

# TODO: potentially prevent overwrite of data if output_dir already exists

# Create output_dir if it doesn't exist already
mkdir -p -v $output_dir

jules.exe 

cd $curr_dir
