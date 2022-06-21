#!/bin/bash
#SBATCH --account=rpp-blairt2k
#SBATCH --time=3-0:0:0
#SBATCH --mem-per-cpu=8000
#SBATCH --output=%x-%a.out
#SBATCH --error=%x-%a.err
#SBATCH --cpus-per-task=1

# sets up environment and runs np_to_hit_array_hdf5.py, see that file for info on arguments, that all get passed through from this script

ulimit -c 0

source /home/arnabs/scratch/Data_Tools/cedar_scripts/sourceme.sh

virtualenv --no-download $SLURM_TMPDIR/env
source $SLURM_TMPDIR/env/bin/activate
pip install --no-index --upgrade pip
pip install --no-index h5py

cd /home/arnabs/scratch/Data_Tools/root_utils

# initially save to SLURM_TMPDIR for speed
#args=("$@")
#for i in "${!args[@]}"; do
#  if [[ ${args[$i]} == "-o" ]]; then
#    outfile="${args[$i+1]}"
#    tmpfile="${SLURM_TMPDIR}/$(basename $outfile)"
#    args[$i+1]="$tmpfile"
#    break
#  fi
#done

echo "python np_to_digihit_array_hdf5.py $@"
python np_to_digihit_array_hdf5.py "$@"

#echo "cp $tmpfile $outfile"
#cp "$tmpfile" "$outfile"
