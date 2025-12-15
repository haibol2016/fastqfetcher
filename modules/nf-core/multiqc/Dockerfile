# Dockerfile for MultiQC with procps
# 
# This container includes:
# - MultiQC 1.29 (via bioconda)
# - procps (ps command) for process monitoring
#
# Uses micromamba base image for multi-platform support (AMD64, ARM64)

FROM mambaorg/micromamba:1.5.8-jammy

# Set maintainer label
LABEL maintainer="haiboLiu"
LABEL description="MultiQC 1.29 with procps for process monitoring"
LABEL version="1.29"

# Install MultiQC and procps via micromamba
RUN micromamba install -y -n base -c bioconda -c conda-forge \
    multiqc=1.29 \
    procps-ng && \
    micromamba clean -afy

# Set PATH to include conda bin (micromamba uses /opt/conda by default)
ENV PATH="/opt/conda/bin:${PATH}"

# Set working directory
WORKDIR /data

# Default command
CMD ["/bin/bash"]

