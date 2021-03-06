# FreeQC

FreeQC calculates Euler's number, contrast-to-noise ratio values and total number
of holes in the surface on Freesurfer output and creates a csv with subject and
session labels for easy tabulation.

## Usage
    usage:  [--help] [--version] [--column <SUBJECT COLUMN>]
              --subject <SUBJECT LABEL> --session <SESSION LABEL>

      -h  | --help     Print this message and exit.
      -v  | --version  Print version and exit.
      -c  | --column   Name of subject column for output csv files.
      -sj | --subject  Subject label.
      -sn | --session  Session label.

## Docker
### Setting up
You must [install Docker](https://docs.docker.com/get-docker/) to use the FreeQC
Docker image.

After Docker is installed, pull the FreeQC image by running the following command:
`docker pull pennbbl/freeqc:0.0.14`.

Typically, Docker is used on local machines and not clusters because it requires
root access. If you want to run the container on a cluster, follow the Singularity
instructions.

### Running FreeQC
First, you must obtain a [Freesurfer license](https://surfer.nmr.mgh.harvard.edu/fswiki/License).

Here is an example from one of Ellyn's runs:
```
docker run -it \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/freesurfer/sub-10410/ses-FNDM11:/input/data \
  -v /Users/butellyn/Documents/license.txt:/opt/freesurfer/license.txt \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/freeqc/sub-10410/ses-FNDM11:/output \
  pennbbl/freeqc:0.0.14 --subject sub-10410 --session ses-FNDM11 --column bblid
```

- Line 2: Bind Freesurfer output directory (`/Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/freesurfer/sub-10410/ses-FNDM11`)
to the input directory in the container (`/input/data`).
- Line 3: Bind the Freesurfer license (`/Users/butellyn/Documents/license.txt`)
to the container (`/opt/freesurfer/license.txt`).
- Line 4: Bind the directory where you want your FreeQC output to end up
(`/Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/freeqc/sub-10410/ses-FNDM11`)
to the `/output` directory in the container.
- Line 5: Specify the Docker image and version (run `docker images` to see if you
have the correct version pulled), and specify subject label, session label, and (optional) subject column name.

Substitute your own values for the arguments and files/directories to bind.

## Singularity
### Setting up
You must [install Singularity](https://singularity.lbl.gov/docs-installation) to use the FreeQC
Singularity image.

After Singularity is installed, pull the FreeQC image by running the following command:
`singularity pull docker://pennbbl/freeqc:0.0.14`.

Note that Singularity does not work on Macs, and will almost surely have to be
installed by a system administrator on your institution's computing cluster.

### Running FreeQC
First, you must obtain a [Freesurfer license](https://surfer.nmr.mgh.harvard.edu/fswiki/License).

Here is an example from one of Ellyn's runs:
```
singularity run --writable-tmpfs --cleanenv \
  -B /project/ExtraLong/data/freesurferCrossSectional/freesurfer/sub-10410/ses-FNDM11:/input/data \
  -B /project/ExtraLong/data/license.txt:/opt/freesurfer/license.txt \
  -B /project/ExtraLong/data/freesurferCrossSectional/freeqc/sub-10410/ses-FNDM11:/output \
  /project/ExtraLong/images/freeqc_0.0.14.sif --subject sub-10410 --session ses-FNDM11 --column bblid
```

- Line 2: Bind Freesurfer output directory (`/project/ExtraLong/data/freesurferCrossSectional/freesurfer/sub-10410/ses-FNDM11`)
to the input directory in the container (`/input/data`).
- Line 3: Bind the Freesurfer license (`/project/ExtraLong/data/license.txt`)
into the container (`/opt/freesurfer/license.txt`).
- Line 4: Bind the directory where you want your FreeQC output to end up
(`/project/ExtraLong/data/freesurferCrossSectional/freeqc/sub-10410/ses-FNDM11`)
to the `/output` directory in the container.
- Line 5: Specify the Singularity image file, and specify subject label, session label, and (optional) subject column name.

Substitute your own values for the arguments and files/directories to bind.

## Example Scripts
See [this script](https://github.com/PennBBL/ExtraLong/blob/master/scripts/process/QualityAssessment/submitFreeqc.py)
for an example of building individual launch scripts for each session of Freesurfer output.

See [this script](https://github.com/PennBBL/ExtraLong/blob/master/scripts/process/QualityAssessment/combineFreeqcOutput.py)
for an example of how to tabulate results. Note that this script was written for
FreeQC v0.0.9, which had a bug that resulted in the subject column name being
'/scripts/idcols.py' opposed to the specified value, 'bblid'. If you are using
FreeQC v0.0.12+, this error has been corrected and therefore you will not need
this line in your tabulation script.

## Notes
1. This pipeline has only been tested on a couple versions of Freesurfer. If the
structure of the output directories is different than the versions it was tested
on, FreeQC will fail.
2. For details on how FreeQC was utilized for the ExtraLong project (all
longitudinal T1w data in the BBL), see [this wiki](https://github.com/PennBBL/ExtraLong/wiki).

## Future Directions
1. Set home directory in Dockerfile.
