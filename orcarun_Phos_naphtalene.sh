#!/bin/bash
##SBATCH --test-only    # Validate the batch script, job is not submitted.
#SBATCH -J Phos_naphtalene # Job name
#SBATCH -o slurm.o%j    # Name of stdout output file
#SBATCH -e slurm.e%j    # Name of stderr error file
#SBATCH -p normal       # Queue (partition) name
#SBATCH -N 1            # Total # of nodes (must be 1 for serial)
#SBATCH -n 1           # Total # of tasks (should be 1 for serial)
#SBATCH -t 48:00:00     # Run time (hh:mm:ss)
#SBATCH -A CHE22002

# Set some internal variables
JobDir="${SLURM_SUBMIT_DIR}"
JobName="${SLURM_JOB_NAME}"
InpExt="inp"
InpDataExt="xyz hess inp GS.hess TS.hess ES.hess GS TS ES"
OutExt="out"
OutDataExt="prop _property.txt txt gbw cpp uno unoloc uco qro prop opt xyz hess scfp mdcip lastscf scf esdinp tmp esd inp spectrum GS.hess TS.hess ES.hess GS TS ES esdinp.tmp mdciinp.tmp"

# To run job on a nodes local filesystem change ${SCRATCH} to /tmp
ScrBase=${SCRATCH}
ScrDir="${ScrBase}/${SLURM_JOB_NAME}.${SLURM_JOB_ID}"

# Create job scratch directory
mkdir ${ScrDir}

# Prepend ORCA home directory to PATH and LD_LIBRARY_PATH
ORCA_DIR=orca_5_0_2_linux_x86-64_shared_openmpi411
ORCA_HOME=${WORK}/apps/${ORCA_DIR}
export PATH=${ORCA_HOME}:${PATH}
export LD_LIBRARY_PATH=${ORCA_HOME}:${LD_LIBRARY_PATH}

# Prepend Openmpi-4.1.1 bin and lib to PATH and LD_LIBRARY_PATH
OMPI_ROOT=${WORK}/apps/openmpi-4.1.1
export PATH=${OMPI_ROOT}/bin:$PATH
export LD_LIBRARY_PATH=${OMPI_ROOT}/lib:$LD_LIBRARY_PATH

# Set Openmpi MCA parameters
export OMPI_MCA_btl_openib_allow_ib=1

# Copy input/data files to ScrDir
for Ext in ${InpExt} ${InpDataExt} ; do
   if [ -e ${JobDir}/${JobName}.${Ext} ]; then
      /bin/cp -p ${JobDir}/${JobName}.${Ext} ${ScrDir}
   fi
done

# Change to scratch directory
cd ${ScrDir}

# Run ORCA

(/usr/bin/time -p ${ORCA_HOME}/orca ${JobName}.${InpExt} > ${JobName}.${OutExt})

# Copy output/data files to JobDir
for Ext in ${OutExt} ${OutDataExt} ; do
   if [ -e ${ScrDir}/${JobName}.${Ext} ]; then
      /bin/cp -p ${ScrDir}/${JobName}.${Ext} ${JobDir}
   fi
done

# List contents of ScrDir
/bin/du -sh ${ScrDir}
/bin/ls -ltr ${ScrDir}

# Delete ScrDir
/bin/rm -fr ${ScrDir}

exit
