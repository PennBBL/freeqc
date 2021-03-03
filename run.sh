#!/bin/bash

#############################################################
##################### PROCESSING STEPS #####################
#############################################################

license=`find /input/license/ -name 'license.txt'`
#export FS_LICENSE=${license} #Messes up many freesurfer paths when put here
#chmod +x ${FREESURFER_HOME} #Useless
#mount -o remount,rw #Don't have the right privileges
cp ${license} ${FREESURFER_HOME}
export SUBJECTS_DIR=${FREESURFER_HOME}/subjects
FUNCTIONALS_DIR=${FREESURFER_HOME}/sessions
source ${FREESURFER_HOME}/FreeSurferEnv.sh

#export FS_LICENSE=${license} #Try this here - not tried yet... works in shell, but not in run

####### fMRIPrep outputs that pass QA #######
InDir=/input/data
OutDir=/output

bblid=`echo ${SUBNAME} | cut -d "-" -f 2`
seslabel=`echo ${SESNAME} | cut -d "-" -f 2`
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
echo "${SUBCOL},seslabel,cnr_graycsf_lh,cnr_graycsf_rh,cnr_graywhite_lh,cnr_graywhite_rh,holes_lh,holes_rh,holes_total,euler_lh,euler_rh,euler_total" > ${OutDir}/${SUBNAME}_${SESNAME}_quality.csv
echo "${bblid},${seslabel},${cnr_graycsf_lh},${cnr_graycsf_rh},${cnr_graywhite_lh},${cnr_graywhite_rh},${holes_lh},${holes_rh},${holes_total},${euler_lh},${euler_rh},${euler_total}" >> ${OutDir}/${SUBNAME}_${SESNAME}_quality.csv

# Remove unnecessary files
rm ${OutDir}/cnr.txt
rm ${OutDir}/out_lh.txt
rm ${OutDir}/out_rh.txt

# Quantify regional values
bash /scripts/stats2table_bash.sh ${SUBNAME} ${SESNAME}

# Put in bblid and seslabel columns
python /scripts/idcols.py ${SUBCOL}