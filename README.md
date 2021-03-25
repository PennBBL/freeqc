# FreeQC

FreeQC calculate Euler's number and contrast-to-noise ratio values on Freesurfer
output and outputs results into a csv with subject and session labels for easy
tabulation across subjects/sessions.


## Docker
### Setting up
You must [install Docker](https://docs.docker.com/get-docker/) to use the FreeQC
Docker image.

After Docker is installed, pull the FreeQC image by running the following command:
`docker pull pennbbl/freeqc:0.0.12`.

Typically, Docker is used on local machines and not clusters because it requires
root access. If you want to run the container on a cluster, follow the Singularity
instructions.

### Running FreeQC
```
docker run -it --entrypoint=/bin/bash -e SUBCOL="bblid" -e SUBNAME="sub-10410" -e SESNAME="ses-FNDM11" \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/freesurfer/sub-10410/ses-FNDM11:/input/data \
  -v /Users/butellyn/Documents/license.txt:/input/license/license.txt \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/freeqc/sub-10410/ses-FNDM11:/output \
  pennbbl/freeqc:0.0.12
```

## Singularity
### Setting up
You must [install Singularity](https://singularity.lbl.gov/docs-installation) to use the FreeQC
Singularity image.

After Docker is installed, pull the FreeQC image by running the following command:
`singularity pull docker://pennbbl/freeqc:0.0.12`.

Note that Singularity does not work on Macs, and will almost
surely have to be installed by a system administrator on your institution's cluster.

### Running FreeQC
First, you must obtain a [freesurfer license](https://surfer.nmr.mgh.harvard.edu/fswiki/License).

```
SINGULARITYENV_SUBCOL=bblid SINGULARITYENV_SUBNAME=sub-10410 SINGULARITYENV_SESNAME=ses-FNDM11 \
  singularity run --writable-tmpfs --cleanenv \
  -B /project/ExtraLong/data/freesurferCrossSectional/freesurfer/sub-10410/ses-FNDM11:/input/data \
  -B /project/ExtraLong/data/license.txt:/input/license/license.txt \
  -B /project/ExtraLong/data/freesurferCrossSectional/freeqc/sub-10410/ses-FNDM11:/output \
  /project/ExtraLong/images/freeqc_0.0.12.sif
```

## Example Launch Scripts
See [this script](https://github.com/PennBBL/ExtraLong/blob/master/scripts/process/QualityAssessment/submitFreeqc.py)
for an example of building individual launch scripts for each session of Freesurfer output.

## Notes
1. This pipeline has only been tested on a couple versions of Freesurfer. If the
structure of the output directories is different that the versions it was tested
on, FreeQC will fail.
