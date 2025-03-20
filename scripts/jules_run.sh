# Check inside devbox shell
if [[ ! $DEVBOX_SHELL_ENABLED -eq 1 ]]; then
    echo "Value of \$DEVBOX_SHELL_ENABLED is: $DEVBOX_SHELL_ENABLED"
    echo "This script must be run inside a devbox shell"
    exit 1
fi

# NOTE: prefer running within namelist dir since relative paths are more important
# than flexibility with working dir. 
# See https://jules-lsm.github.io/latest/building-and-running/running-jules.html

run_jules() {
    local curr_dir=$(pwd)
    local namelist_dir="$1"

    if [ ! -d $1 ]; then
        echo "Provide an existing namelist directory (given $1)"
        exit 1
    fi

    # Hack to get absolute path
    namelist_abspath=$(cd "$1"; pwd)
    cd $namelist_abspath

    # Extract output dir (hard-coded into output.nml)
    # NOTE: no attempt to check if relative or absolute
    output_dir=$(grep "output_dir" output.nml | sed -E "s/output_dir\s*=\s*'([^']*)'.*/\1/")

    # Create output_dir if it doesn't exist already
    mkdir -p -v $output_dir

    # Run jules, logging outputs to file
    jules.exe > stdout.log 2>stderr.log

    # Return to original dir
    cd $curr_dir
}

export -f run_jules


if [ "$#" -eq 1 ]; then
    echo "Running Jules with namelist $1"
    run_jules $1

elif [ "$#" -gt 1 ]; then
    echo "Running Jules in parallel"
    parallel run_jules ::: "$@"

else
    echo "Provide at least one (existing) namelist directory"
    exit 1
fi

