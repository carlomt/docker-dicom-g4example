ARG BASE_IMAGE=carlomt/geant4:11.2.0-dcmtk
               
FROM $BASE_IMAGE AS builder

LABEL maintainer.name="Carlo Mancini Terracciano"
LABEL maintainer.email="carlo.mancini.terracciano@roma1.infn.it"

ENV LANG=C.UTF-8
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime
ENV DEBIAN_FRONTEND=noninteractive

RUN curl https://gitlab.cern.ch/geant4/geant4/-/archive/geant4-`/opt/geant4/bin/geant4-config --version | awk -F '.' '{print $1"."$2}'`-release/geant4-master.tar.gz?path=examples/extended/medical/DICOM \
    --output /tmp/DICOM.tar.gz && \
    tar xf /tmp/DICOM.tar.gz --strip-components 4 -C /tmp && \
    mkdir /tmp/DICOM-build && \
    cd /tmp/DICOM-build && \
    cmake \
    -G Ninja \
    -DDICOM_USE_DCMTK=ON \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    /tmp/DICOM && \
    ninja install

#######################################################################

FROM $BASE_IMAGE

ENV LANG=C.UTF-8
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

COPY --from=builder /tmp/DICOM-build/run.mac /workspace/run.mac
COPY --from=builder /tmp/DICOM-build/1.dcm /workspace/1.dcm
COPY --from=builder /tmp/DICOM-build/2.dcm /workspace/2.dcm
COPY --from=builder /tmp/DICOM-build/3.dcm /workspace/3.dcm
COPY --from=builder /tmp/DICOM-build/Data.dat /workspace/Data.dat
COPY --from=builder /usr/local /usr/local

ENV LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PAT
RUN ln -s /usr/local/bin/DICOM /usr/local/bin/run

WORKDIR /workspace/

CMD ["run run.mac"]