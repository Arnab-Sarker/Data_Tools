#!/bin/bash
module load StdEnv/2016
module load gcc/6.4.0
module load python/3.6.3
module load scipy-stack

source /home/arnabs/scratch/Root/root/install/bin/thisroot.sh
source /home/arnabs/scratch/Geant4/geant4.10.01.p03/install/share/Geant4-10.1.3/geant4make/geant4make.sh

export G4WORKDIR=/home/arnabs/scratch/WCTE_wcsim/WCTE_WCSim/exe
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+"$LD_LIBRARY_PATH:"}${G4LIB}/${G4SYSTEM}
export WCSIMDIR=/home/arnabs/scratch/WCTE_wcsim/WCTE_WCSim
export DATATOOLS="$(cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"
export PYTHONPATH=$DATATOOLS:$PYTHONPATH
