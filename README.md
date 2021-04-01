# FreeQC

FreeQC calculates Euler's number, contrast-to-noise ratio values and total number
of holes in the surface on Freesurfer output and creates a csv with subject and
session labels for easy tabulation.

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
First, you must obtain a [Freesurfer license](https://surfer.nmr.mgh.harvard.edu/fswiki/License).

Here is an example from one of Ellyn's runs:
```
docker run -it -e SUBCOL="bblid" -e SUBNAME="sub-10410" -e SESNAME="ses-FNDM11" \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/freesurfer/sub-10410/ses-FNDM11:/input/data \
  -v /Users/butellyn/Documents/license.txt:/opt/freesurfer/license.txt \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/freeqc/sub-10410/ses-FNDM11:/output \
  pennbbl/freeqc:0.0.13
```

- Line 1: Define environmental variables needed for output csvs.
- Line 2: Bind Freesurfer output directory (`/Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/freesurfer/sub-10410/ses-FNDM11`)
to the input directory in the container (`/input/data`).
- Line 3: Bind the Freesurfer license (`/Users/butellyn/Documents/license.txt`)
to the container (`/input/license/license.txt`).
- Line 4: Bind the directory where you want your FreeQC output to end up
(`/Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/freeqc/sub-10410/ses-FNDM11`)
to the `/output` directory in the container.
- Line 5: Specify the Docker image and version. Run `docker images` to see if you
have the correct version pulled.

Substitute your own values for the environment variables, and files/directories to bind.

## Singularity
### Setting up
You must [install Singularity](https://singularity.lbl.gov/docs-installation) to use the FreeQC
Singularity image.

After Singularity is installed, pull the FreeQC image by running the following command:
`singularity pull docker://pennbbl/freeqc:0.0.12`.

Note that Singularity does not work on Macs, and will almost surely have to be
installed by a system administrator on your institution's computing cluster.

### Running FreeQC
First, you must obtain a [Freesurfer license](https://surfer.nmr.mgh.harvard.edu/fswiki/License).

Here is an example from one of Ellyn's runs:
```
SINGULARITYENV_SUBCOL=bblid SINGULARITYENV_SUBNAME=sub-10410 SINGULARITYENV_SESNAME=ses-FNDM11 singularity run --writable-tmpfs --cleanenv \
  -B /project/ExtraLong/data/freesurferCrossSectional/freesurfer/sub-10410/ses-FNDM11:/input/data \
  -B /project/ExtraLong/data/license.txt:/opt/freesurfer/license.txt \
  -B /project/ExtraLong/data/freesurferCrossSectional/freeqc/sub-10410/ses-FNDM11:/output \
  /project/ExtraLong/images/freeqc_0.0.13.sif
```

- Line 1: Define environmental variables needed for output csvs (SUBCOL, SUBNAME, SESNAME).
- Line 2: Bind Freesurfer output directory (`/project/ExtraLong/data/freesurferCrossSectional/freesurfer/sub-10410/ses-FNDM11`)
to the input directory in the container (`/input/data`).
- Line 3: Bind the Freesurfer license (`/project/ExtraLong/data/license.txt`)
into the container (`/opt/freesurfer/license.txt`).
- Line 4: Bind the directory where you want your FreeQC output to end up
(`/project/ExtraLong/data/freesurferCrossSectional/freeqc/sub-10410/ses-FNDM11`)
to the `/output` directory in the container.
- Line 5: Specify the Singularity image file.

Substitute your own values for the environment variables, and files/directories to bind.

## Example Scripts
See [this script](https://github.com/PennBBL/ExtraLong/blob/master/scripts/process/QualityAssessment/submitFreeqc.py)
for an example of building individual launch scripts for each session of Freesurfer output.

See [this script](https://github.com/PennBBL/ExtraLong/blob/master/scripts/process/QualityAssessment/combineFreeqcOutput.py)
for an example of how to tabulate results. Note that this script was written for
FreeQC v0.0.9, which had a bug that resulted in the subject column name being
'/scripts/idcols.py' opposed to the specified value, 'bblid'. If you are using
FreeQC v0.0.12, this error has been corrected and therefore you will not need
this line in your tabulation script.

## Notes
1. This pipeline has only been tested on a couple versions of Freesurfer. If the
structure of the output directories is different than the versions it was tested
on, FreeQC will fail.
2. For details on how FreeQC was utilized for the ExtraLong project (all
longitudinal T1w data in the BBL), see [this wiki](https://github.com/PennBBL/ExtraLong/wiki).
3. Future directions: Input variables should be passed directly to the container,
opposed to as environment variables. Set home directory in Dockerfile.
