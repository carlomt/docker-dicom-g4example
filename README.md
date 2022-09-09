# docker-dicom-g4example
Example of a Docker container for the Geant4 DICOM extended example

to run it:

`docker run --volume="<GEANT4_DATASETS_PATH>:/opt/geant4/data:ro" --rm -it carlomt/dicom-g4example`