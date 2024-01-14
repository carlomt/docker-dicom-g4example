ARG BASE_IMAGE=carlomt/geant4:11.2.0-dcmtk
               
FROM $BASE_IMAGE AS builder

LABEL maintainer.name="Carlo Mancini Terracciano"
LABEL maintainer.email="carlo.mancini.terracciano@roma1.infn.it"

ENV LANG=C.UTF-8
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace

RUN cd /workspace && \
    curl https://gitlab.cern.ch/geant4/geant4/-/archive/geant4-`/opt/geant4/bin/geant4-config --version | awk -F '.' '{print $1"."$2}'`-release/geant4-master.tar.gz?path=examples/extended/medical/DICOM \
    --output DICOM.tar.gz && \
    tar xf DICOM.tar.gz --strip-components 4 && \
    mkdir DICOM-install && \
    mkdir DICOM-build && \
    cd DICOM-build && \
    cmake \
    -G Ninja \
    -DDICOM_USE_DCMTK=ON \
 #   -DCMAKE_INSTALL_PREFIX=../DICOM-install \
    ../DICOM && \
    ninja 

#######################################################################

FROM $BASE_IMAGE

ENV LANG=C.UTF-8
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# COPY --from=builder /workspace/DICOM-install /workspace/DICOM-install
COPY --from=builder /workspace/DICOM-build /workspace/DICOM-build

# ENV LD_LIBRARY_PATH=/workspace/DICOM-install/lib/:$LD_LIBRARY_PAT

WORKDIR /workspace/DICOM-build

CMD ["./DICOM run.mac"]