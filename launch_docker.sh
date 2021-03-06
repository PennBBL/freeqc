docker run -it --entrypoint=/bin/bash -e SUBCOL="bblid" -e SUBNAME="sub-100088" -e SESNAME="ses-CONTE1" \
    -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/freesurfer/sub-100088/ses-CONTE1:/input/data \
    -v /Users/butellyn/Documents/license.txt:/input/license/license.txt \
    -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/freeqc/sub-100088/ses-CONTE1:/output \
    pennbbl/freeqc:0.0.12 /scripts/run.sh

SINGULARITYENV_SUBCOL=bblid SINGULARITYENV_SUBNAME=sub-100088 SINGULARITYENV_SESNAME=ses-CONTE1 \
  singularity run --writable-tmpfs --cleanenv \
  -B /project/ExtraLong/data/freesurferCrossSectional/freesurfer/sub-100088/ses-CONTE1:/input/data \
  -B /project/ExtraLong/data/license.txt:/input/license/license.txt \
  -B /project/ExtraLong/data/freesurferCrossSectional/freeqc/sub-100088/ses-CONTE1:/output \
  /project/ExtraLong/images/freeqc_0.0.9.sif
