ARG BASE_IMAGE=debian:trixie-slim
FROM ${BASE_IMAGE}

COPY lib /opt/onnxruntime/lib
COPY include /opt/onnxruntime/include
COPY MANIFEST.json /opt/onnxruntime/

ENV LD_LIBRARY_PATH=/opt/onnxruntime/lib:${LD_LIBRARY_PATH}
