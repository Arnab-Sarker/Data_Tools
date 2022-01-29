#!/bin/bash

# usage: setup_jobs.sh name data_dir

# exit when any command fails if being run in subshell
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -e
  EXIT=exit
else
  EXIT=return
fi

name="$1"
data_dir="$(readlink -m "$2")"

start_dir="$(pwd)"
if [ -z "$DATATOOLS" ]; then
  cd "$(dirname "${BASH_SOURCE[0]}")"
  cd ..
  echo "DATATOOLS environment variable not set, assuming parent directory of this setup script"
  export DATATOOLS="$(pwd)"
fi
if [ "$(git status --porcelain --untracked-files=no)" ]; then
  echo "DataTools git repository not clean, commit or stash changes first so that version can be traced"
  cd "$start_dir"
  $EXIT 1
fi

mkdir -p "$data_dir/$name"
git describe --always --long --tags --dirty > "$data_dir/$name/DataTools-git-describe"

export G4WORKDIR="$data_dir/$name/WCSim/build_$(date +"%F_%H-%M-%S")"
mkdir -p "$G4WORKDIR"
if [ ! -w "$G4WORKDIR" ]; then
  echo "$G4WORKDIR is not writeable. Trying to overwrite previous run? Delete or make directory writable before running this script if you really want to do that."
  cd "$start_dir"
  $EXIT 1
fi

if [ -z "$WCSIMDIR" ]; then
  echo "WCSIMDIR not set, need location of WCSim"
  cd "$start_dir"
  $EXIT 1
fi

cd "$WCSIMDIR"
if [ "$(git status --porcelain --untracked-files=no)" ]; then
  echo "WCSim git repository not clean, commit or stash changes first so that version can be traced"
  cd "$start_dir"
  $EXIT 1
fi

if [ -z "$ROOTSYS" ]; then
  echo "ROOTSYS not set, need location of ROOT"
  cd "$start_dir"
  $EXIT 1
fi

if [ -z "$G4INSTALL" ]; then
  echo "G4INSTALL not set, need location of GEANT4"
  cd "$start_dir"
  $EXIT 1
fi

sourceme="${data_dir}/${name}/sourceme_$(date +"%F_%H-%M-%S").sh"
echo "Creating source file $sourceme"
echo "#!/bin/bash" > "$sourceme"
echo "module load StdEnv/2016" >> "$sourceme"
echo "module load gcc/6.4.0" >> "$sourceme"
echo "module load python/3.6.3" >> "$sourceme"
echo "module load scipy-stack" >> "$sourceme"
echo "source \"${ROOTSYS}/bin/thisroot.sh\"" >> "$sourceme"
echo "source \"${G4INSTALL}/geant4make.sh\"" >> "$sourceme"
echo "export G4WORKDIR=\"${G4WORKDIR}\"" >> "$sourceme"
echo "export DATATOOLS=\"${DATATOOLS}\"" >> "$sourceme"
echo 'export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+"$LD_LIBRARY_PATH:"}${G4LIB}/${G4SYSTEM}' >> "$sourceme"
echo 'export PYTHONPATH=${PYTHONPATH:+"$PYTHONPATH:"}$DATATOOLS' >> "$sourceme"
source "$sourceme"
ln -sf "$sourceme" "${data_dir}/${name}/sourceme.sh"

echo "Compiling WCSim, source $PWD, destination $G4WORKDIR"
cd "$G4WORKDIR"
cmake "$WCSIMDIR"
make
cd "$WCSIMDIR"
git describe --always --long --tags --dirty > "$G4WORKDIR/WCSim-git-describe"
echo 'export WCSIMDIR="${G4WORKDIR}"' >> "$sourceme"
echo "export FITQUN_ROOT=\"$data_dir/$name/fiTQun/build\"" >> "$sourceme"
echo 'export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${WCSIMDIR}"' >> "$sourceme"
export WCSIMDIR="${G4WORKDIR}"

if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
# script has been sourced
  echo "Finished setting up. Environment set up to run jobs now, or in new shell source the following file then run jobs:"
else
  echo "Finished setting up. Source the following file then run jobs:"
fi
echo "source ${sourceme}"
echo "run_WCSim_job.sh ${name} ${data_dir} [options]"

cd "$start_dir"
