#!/bin/bash

#############################################################
#################### PARSE CMD LINE ARGS ####################
#############################################################
VERSION=0.0.13

usage () {
    cat <<- HELP_MESSAGE

      usage:  $0 [--help] [--version] [--column <SUBJECT COLUMN>]
              --subject <SUBJECT LABEL> --session <SESSION LABEL>

      -h  | --help     Print this message and exit.
      -v  | --version  Print version and exit.
      -c  | --column   Name of subject column for output csv files.
      -sj | --subject  Subject label.
      -sn | --session  Session label.

HELP_MESSAGE
}

# Display usage message if no args are given
if [[ $# -eq 0 ]] ; then
  usage
  exit 1
fi

# Parse cmd line options
#PARAMS=""
while (( "$#" )); do
  case "$1" in
    -h | --help)
        usage
        exit 0
      ;;
    -v | --version)
        echo $VERSION
        exit 0
      ;;
    -c | --column)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        subCol=$2
        shift 2
      else
        echo "$0: Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -sj | --subject)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        subName=$2
        shift 2
      else
        echo "$0: Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -sn | --session)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        sesName=$2
        shift 2
      else
        echo "$0: Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -*|--*=) # unsupported flags
      echo "$0: Error: Unsupported flag $1" >&2
      exit 1
      ;;
    #*) # parse positional arguments
    #  PARAMS="$PARAMS $1"
    #  shift
    #  ;;
  esac
done

# set positional arguments in their proper place
#eval set -- "$PARAMS"

# Check if required args were given, 
if [[ -z "$subName" ]]; then
  echo "$0: Error: Missing required argument: --subject <SUBJECT LABEL>" >&2
  exit 1
elif [[ -z "$sesName" ]]; then
  echo "$0: Error: Missing required argument: --session <SESSION LABEL>" >&2
  exit 1
elif [[ -z "$subCol" ]]; then
  subCol=bblid
fi

#############################################################
###################### PROCESSING STEPS #####################
#############################################################


## KZ: Commenting out the following lines... 
## ...just mount license directly to /opt/freesurfer/license.txt
#license=`find /input/license/ -name 'license.txt'`
#cp ${license} ${FREESURFER_HOME}

export SUBJECTS_DIR=${FREESURFER_HOME}/subjects
FUNCTIONALS_DIR=${FREESURFER_HOME}/sessions
source ${FREESURFER_HOME}/FreeSurferEnv.sh

#export FS_LICENSE=${license} #Try this here - not tried yet... works in shell, but not in run

####### fMRIPrep outputs that pass QA #######
InDir=/input/data
OutDir=/output

bblid=`echo ${subName} | cut -d "-" -f 2`
seslabel=`echo ${sesName} | cut -d "-" -f 2`
surfDir=${InDir}/surf ### MIGHT HAVE TO GIT RID OF DIRS BETWEEN INPUT AND FREESURFER
mriDir=${InDir}/mri

# ----- CNR ----- #
mri_cnr ${surfDir} ${mriDir}/orig.mgz > ${OutDir}/cnr.txt
total=`grep "total CNR" ${OutDir}/cnr.txt | cut -f 4 -d " "`
cnr=`grep "gray/white CNR" ${OutDir}/cnr.txt`
cnr_graycsf_lh=`echo $cnr | cut -d "," -f 2 | cut -d "=" -f 2 | cut -d " " -f 2`
cnr_graycsf_rh=`echo $cnr | cut -d "," -f 3 | cut -d "=" -f 2 | cut -d " " -f 2`
cnr_graywhite_lh=`echo $cnr | cut -d "," -f 1 | cut -d "=" -f 2 | cut -d " " -f 2`
cnr_graywhite_rh=`echo $cnr | cut -d "," -f 2 | cut -d "=" -f 3 | cut -d " " -f 2`

# ---- Euler ---- #
script -c "mris_euler_number ${surfDir}/lh.orig.nofix" ${OutDir}/out_lh.txt
holes_lh=`cat ${OutDir}/out_lh.txt | grep "euler" | cut -d ">" -f 2 | cut -d "h" -f 1 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
euler_lh=`cat ${OutDir}/out_lh.txt | grep "euler" | cut -d "=" -f 4 | cut -d " " -f 2`

script -c "${FREESURFER_HOME}/bin/mris_euler_number ${surfDir}/rh.orig.nofix" ${OutDir}/out_rh.txt
holes_rh=`cat ${OutDir}/out_rh.txt | grep "euler" | cut -d ">" -f 2 | cut -d "h" -f 1 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
euler_rh=`cat ${OutDir}/out_rh.txt | grep "euler" | cut -d "=" -f 4 | cut -d " " -f 2`

holes_total=`expr $holes_lh + $holes_rh`
euler_total=`expr $euler_lh + $euler_rh`

# ----- CSV ----- #
echo "${subCol},seslabel,cnr_graycsf_lh,cnr_graycsf_rh,cnr_graywhite_lh,cnr_graywhite_rh,holes_lh,holes_rh,holes_total,euler_lh,euler_rh,euler_total" > ${OutDir}/${subName}_${sesName}_quality.csv
echo "${bblid},${seslabel},${cnr_graycsf_lh},${cnr_graycsf_rh},${cnr_graywhite_lh},${cnr_graywhite_rh},${holes_lh},${holes_rh},${holes_total},${euler_lh},${euler_rh},${euler_total}" >> ${OutDir}/${subName}_${sesName}_quality.csv

# Remove unnecessary files
rm ${OutDir}/cnr.txt
rm ${OutDir}/out_lh.txt
rm ${OutDir}/out_rh.txt

# Quantify regional values
bash /scripts/stats2table_bash.sh ${subName} ${sesName}

# Put in bblid and seslabel columns
python /scripts/idcols.py ${subCol}
