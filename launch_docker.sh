docker run -it --entrypoint=/bin/bash -e SUBCOL="bblid" -e SUBNAME="sub-100088" -e SESNAME="ses-CONTE1"\
    -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/freesurfer/sub-100088/ses-CONTE1:/input/data \
    -v /Users/butellyn/Documents/license.txt:/input/license/license.txt \
    -v /Users/butellyn/Documents/freeqc/output:/output \
    pennbbl/freeqc:0.0.2
