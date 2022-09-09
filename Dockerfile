ARG BASE_IMAGE=carlomt/geant4:11.0.2-dcmtk

FROM $BASE_IMAGE AS builder

ENV LANG=C.UTF-8
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace

RUN cd /workspace && \
    wget https://gitlab.cern.ch/geant4/geant4/-/archive/master/geant4-master.tar.gz?path=examples/extended/medical/DICOM -O dicom.tar.gz && \
    tar xf dicom.tar.gz --strip-components 4 && \
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

CMD ["./DICOM"]