# Portable JULES

<!-- [![Built with Devbox](https://www.jetify.com/img/devbox/shield_galaxy.svg)](https://www.jetify.com/devbox/docs/contributor-quickstart/) -->
[![Built with Devbox](https://www.jetify.com/img/devbox/shield_moon.svg)](https://www.jetify.com/devbox/docs/contributor-quickstart/)

The [Joint UK Land Environment Simulator](https://jules.jchmr.org/) is a [land surface model](https://en.wikipedia.org/wiki/Land_surface_models_(climate)) that has been developed over the last 20 years by a community of UK researchers coordinated by the [Met Office](https://www.metoffice.gov.uk/) and the [Centre for Ecology Hydrology](https://www.ceh.ac.uk/).


Existing [documentation](https://jules-lsm.github.io/) and [tutorials](https://jules.jchmr.org/scratch) for JULES tends to assume that the user intends to run the model on one of a small number of supported HPC systems - usually [JASMIN](https://jasmin.ac.uk/) (NERC) or [Cray](https://www.metoffice.gov.uk/about-us/who-we-are/innovation/supercomputer) (Met Office) - using a particular suite of configuration and workflow management tools ([Rose](https://github.com/metomi/rose) and [Cylc](https://github.com/cylc)).


This repository contains tools that simplify the process of setting up and running JULES on a standard personal computer running a Unix-based OS or on cloud-based services such as [DataLabs](https://datalab.datalabs.ceh.ac.uk/)., without extraneous tools and without making assumptions about the computing environment.


The following approaches are supported, or planned to be supported:

| Method | `sudo` required during setup | `sudo` required to run | Status |
| --- | --- | --- | --- |
| Portable installation using Nix/Devbox | No (but more tricky without) | No | Done |
| Installation using other package managers | Yes | No | Done |
| Docker container | Yes | Yes | Done |
| udocker-compatible container | Yes | No | Done |
| Singularity/Apptainer container | Yes | No | Planned |


> [!IMPORTANT]
> JULES is sadly not open source (see the [license](https://jules-lsm.github.io/access_req/JULES_Licence.pdf)). You will need to request access to the JULES source code by filling out [this form](https://jules-lsm.github.io/access_req/JULES_access.html). You should then be provided with a Met Office Science Repository Service (MOSRS) username and password.


## Getting Started

Clone the repository and navigate to the repository root directory:

```sh
git clone https://github.com/jmarshrossney/portable-jules.git
cd portable-jules
```

Next, create a file called `.env` in the root of the repository containing the following lines:

```env
# file .env
MOSRS_USERNAME="<your MOSRS username>"
MOSRS_PASSWORD="<your MOSRS password>"
```

Replace `<your MOSRS username>` and `<your MOSRS password>` with, you guessed it, your MOSRS username and password.


## Portable installation using Nix/Devbox

The wonderful thing about Nix (and hence Devbox) is that package management is isolated from the host system (this is called  [hermeticity](https://zero-to-nix.com/concepts/hermeticity/)), and therefore agnostic towards your choice of Unix/Linux distribution.

The following steps should run on any reasonable Unix-based system with root privileges. If you do not have root privileges, go to [this subsection](#installation-without-root-privileges).


### Installation

The following steps assume you are executing commands in a bash shell with `curl` (and `git`) already installed. Please execute each of them individually rather than copy-pasting the whole thing.

```bash
# Install Devbox and Nix
curl -fsSL https://get.jetify.com/devbox | bash

# Download packages
devbox install

# Test that everything has worked
devbox run hello

# Download and build JULES
# NOTE: this step requires MOSRS credentials
devbox run --env-file .env setup

# Confirm that jules.exe exists in $PATH
# (should return /path/to/portable-jules/_build/build/bin/jules.exe)
devbox run which jules.exe

# Run the Loobos example
devbox run loobos
```

Note that all `devbox` commands should be run in the repository root.



### Basic usage

The simplest way to run a JULES simulation using `portable-jules` is to run the following in any subdirectory of the `portable-jules` repository root,

```bash
devbox run jules path/to/namelist_dir
```

Under the hood, this will `cd` to `namelist_dir` and run `jules.exe > stdout.log 2> stderr.log`.
(See `jules.sh` for further details.)

One can also specify an alternative working directory using the `-d` flag,

```bash
devbox run jules -d path/to/run_dir path/to/namelist_dir
```

> [!TIP]
> All relative paths specified in the namelist (`.nml`) files are relative to the working directory, _not_ the namelist file itself.


### Parallel simulations

It is possible to fire off several JULES runs at once using [GNU Parallel](https://www.gnu.org/software/parallel/) by providing multiple namelist directories,

```bash
# Specify individual namelist directories...
devbox run jules path/to/namelists_1 path/to/namelists_2 ...

# ...or use a wildcard
devbox run jules path/to/dir_of_namelist_dirs/*
```

This is useful for running large ensembles of 1+1 dimensional 'point' simulations, which includes gridded simulations that are completely decoupled in the spatial dimensions.


### In other projects

To execute the `devbox run jules` command from a different directory, one can specify the devbox config explicitly, as in

```bash
devbox run -c path/to/portable-jules/devbox.json jules -d $(pwd) $(pwd)/path/to/namelist_dir
```

Note that the command (`jules -d ...`) will actually be run from the directory where `devbox.json` lives. This is a feature/limitation of devbox (see e.g. [this issue](https://github.com/jetify-com/devbox/issues/2559)). Hence, you will need to be careful with provide paths to the run and namelist directories.


### Installation without root privileges

This amounts to installing Nix and Devbox in user namespace instead of the default locations. The subsequent `devbox` commands should work just the same.

#### Installing Nix

By default Nix stores packages in `/nix`, which typically requires root privileges to write to. However, in principle one can choose a different location in user space.

The most up to date instructions for doing this can be found on the [NixOS wiki](https://nixos.wiki/wiki/Nix_Installation_Guide#Installing_without_root_permissions). Currently, the easiest option seems to be to use the (sadly unmaintained) [nix-user-chroot](https://github.com/nix-community/nix-user-chroot) installer. This can be installed via `cargo`, which can be easily installed by following [these instructions](https://doc.rust-lang.org/cargo/getting-started/installation.html).

The `nix-user-chroot` instructions tell you to run `unshare --user --pid echo YES` to check if your system has user namespaces enabled, which is required for this approach to work. However, I recommend instead running

```sh
unshare --user --pid --mount echo "YES"
```

which also checks for the ability to create _bind mounts_. 

I mention this because it is not currently possible to create bind mounts on DataLabs (of interest to UKCEH folk), which means this approach does not work.

#### Devbox

Installing Devbox without root privileges is also unfortunately a bit of a hassle (see [this issue](https://github.com/jetify-com/devbox/issues/2165)).

First, download the devbox install script using

```sh
curl --silent --show-error --fail --location --output ./devbox_install "https://get.jetify.com/devbox"
```

Next edit it to do the following:

- Change `/usr/local/bin` to a location in user space, e.g. `/$HOME/.local/bin`
- Remove the `(command -v sudo || true)` part from the beginning of the relevant line.

Finally, run the script

```sh
chmod u+x ./devbox_install
./devbox_install
```


## Installation using other package managers

Of course, Devbox/Nix is just one (very convenient) option for installing the necessary libraries. You are free to use your preferred package manager to do so.

You may want to refer to `devbox.json` to see what packages are required, and then look up their names in the other package manager. For example, on Ubuntu I would do the following:

```sh
sudo apt update
sudo apt install --yes \
	coreutils \
	curl \
	diffutils \
	git \
	gfortran \
	glibc-source \
	make \
	libnetcdf-dev \
	libnetcdff-dev \
	parallel \
	perl \
	subversion
```

You will need to set some environment variables before running the setup script. For a 'basic' installation these will be:


- `FCM_ROOT` : location to download FCM
- `JULES_ROOT` : location to download JULES
- `JULES_BUILD_DIR` : location for JULES build
- `JULES_NETCDF` : flag for whether to use netcdf or not (this should be set to `netcdf`)
- `JULES_NETCDF_PATH` : path to a location containing containing the netcdf include directory (the file `netcdf.mod` should be found in `$JULES_NETCDF_PATH/include`.)

See the [JULES documentation](https://jules-lsm.github.io/latest/building-and-running/fcm.html#environment-variables-used-when-building-jules-using-fcm-make) for a full list of environment variables.

Finally, you should be able to run the setup and run scripts in the usual way:

```bash
# Make executable
chmod +x setup.sh jules.sh  

# CAUTION! Your MOSRS credentials are now accessible as environment variables!
# Consider passing them as command line arguments instead
source .env

# Download and build
./setup.sh

# Run jules
./jules.sh -d /path/to/run_dir /path/to/namelists_dir
```

You might consider passing your MOSRS credentials as command-line arguments to `setup.sh` instead of sourcing the `.env` file.

```bash
./setup.sh -u <username> -p '<password>'
```

Note the use of single quotation marks, which ensures the password is treated as a literal string, so any illegal characters don't mess things up.


## Docker container

> [!IMPORTANT]
> The [JULES license](https://jules-lsm.github.io/access_req/JULES_Licence.pdf) (Sec. 4.1.2) prohibits distribution of JULES source code. This means it is not permitted to share container images, e.g. by uploading them to Dockerhub. Unfortunately, if you want to run dockerised JULES you have to build the container yourself, using your own MOSRS credentials.


### Building the container

As part of the process of building a container image, the JULES source code needs to be downloaded, which requires MOSRS credentials. We cannot simply copy `.env` into the container since that would mean anyone could spin up the container and inspect it. We need to expose the contents of `.env` during the build in a secure way.

This solution is to use a [_secret mount_](https://docs.docker.com/build/building/secrets/). In the following example, we mount `.env` during the build:

```sh
docker build --secret id=.env -t jules:vn7.9 .
```

The contents of `.env` are then accessible using: `RUN --mount=type=secret,id=.env,target=/devbox/.env` (the `WORKDIR` is `/devbox` at this point).


### Running the container

JULES still needs to load the namelists and inputs, and we did not include these in the container itself. To run the container you need to link the run directory and the namelists directory to the container filesystem. You can mount the run directory (assuming the namelists directory is below it) to an _unused_ location in the container filesystem (`/devbox/run` in this example).

```sh
cd examples/loobos
docker run -v "$(pwd)":/devbox/run jules:vn7.9 -d run run/config
```

It will speed things up if the directory being linked is not too large, i.e. if the run directory (`examples/loobos` above) only contains the necessary inputs and namelists, and not a bunch of other stuff. 


## uDocker-compliant container

udocker somewhat advertises itself as a drop-in replacement for docker that does not require root privileges. In practice it seems to have quite a few quirks.

1. Build a container image as usual, but using a different dockerfile (`Dockerfile.u`)

```sh
docker build --secret id=.env -f Dockerfile.u -t jules .
```

> [!TIP]
> Funnily enough, this container will not run with Docker, since the workdir is `/` instead of `/root` as it is when run with udocker.
> I do not know why this is. To run it with docker, use `--workdir=/root`.

2. Save the image to a tar.gz

```sh
docker save jules | gzip > jules.tar.gz
```

3. Load into udocker - create an image called `jules`

```sh
uv run udocker load -i jules.tar.gz jules
```
NOTE: this can 'silently' fail. The output should look something like this:

```sh
❯ uv run udocker load -i devbox-root-user.tar.gz devbox-root-user
Info: adding layer: sha256:0b99a6bf584d36ef5ed44ae402f1e6318a822dd0559786a02e0aca6b83807402
...
Info: adding layer: sha256:95a2005e07300a41ffbbb0aa02d8974f8f0c0331285db444288cc15da96d8613
['jules:latest']
```

and not this:

```sh
❯ uv run udocker load -i minimal.tar.gz minimal
Info: adding layer: sha256:f92d940c8ae8f16b5dbf079a4e21fefb5a1b4913ca076370e558dd0ebdba98ac
...
Info: adding layer: sha256:5f70bf18a086007016e948b04aed3b82103a36bea41755b6cddfaf10ace3c6ef
[]
```

4. Create a container (you can run the image directly but it will create a container each time which is a waste of time and resources)

```sh
uv run udocker create --name=jules jules
```

5. Run, while mounting the directories in a very specific way.

```sh
❯ uv run udocker run -v=$(pwd)/examples/loobos:/root/run jules -d /root/run /root/run/config
```

Note that the working directory at run time will be `/root/`. You should bind the run directory to a new location in the container (e.g. `/root/run`) and then pass the absolute paths in the container as arguments, `-d RUN_DIR NAMELISTS_DIR`.

It's pretty messy and very brittle, but just getting this to work at all took a LONG time.


## Singularity/Apptainer container

To do.


## Specifying the JULES version

By default, `./setup.sh` or `devbox run setup` will download the most recent revision of JULES (i.e. `HEAD`). However, one can specify a revision by passing an optional argument with the `-r` flag, as in `./setup.sh -r <rev>` or `devbox run setup -r <rev>`, or by setting the environment variables `JULES_REVISION`.

The following (copied from [here](https://code.metoffice.gov.uk/trac/jules/browser/main)) maps named versions of JULES to revision identifiers. To download version 7.8, for example, one would do `./setup.sh -r 29791` or `devbox run setup -r 29791`.

```
vn3.1 = 11
vn3.2 = 27
vn3.3 = 52
vn3.4 = 65
vn3.4.1 = 67
vn4.0 = 101
vn4.1 = 131
vn4.2 = 793
vn4.3 = 1511
vn4.3.1 = 1709
vn4.3.2 = 1978
vn4.4 = 2461
vn4.5 = 3197
vn4.6 = 4285
vn4.7 = 5320
vn4.8 = 6925
vn4.9 = 8484
vn5.0 = 9522
vn5.1 = 10836
vn5.2 = 12251
vn5.3 = 13249
vn5.4 = 14197
vn5.5 = 15100
vn5.6 = 15927
vn5.7 = 16960
vn5.8 = 17881
vn5.9 = 18812
vn6.0 = 19395
vn6.1 = 20512
vn6.2 = 21512
vn6.3 = 22411
vn7.0 = 23518
vn7.1 = 24383
vn7.2 = 25256
vn7.3 = 25896
vn7.4 = 26897
vn7.5 = 28091
vn7.6 = 28692
vn7.7 = 29181
vn7.8 = 29791
vn7.8.1 = 29986
vn7.9 = 30414
```

