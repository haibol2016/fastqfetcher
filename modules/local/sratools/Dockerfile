# Dockerfile for SRA Toolkit with pigz and procps
# 
# This container includes:
# - SRA Toolkit (via bioconda)
# - pigz (parallel gzip) for faster compression
# - procps (ps command) for process monitoring
#
# Uses micromamba base image for multi-platform support (AMD64, ARM64)

FROM mambaorg/micromamba:1.5.8-jammy

# Set maintainer label
LABEL maintainer="haiboLiu"
LABEL description="SRA Toolkit with pigz and procps for parallel compression and process monitoring"
LABEL version="3.2.1"

# Install SRA Toolkit, pigz, and procps via micromamba
RUN micromamba install -y -n base -c bioconda -c conda-forge \
    sra-tools=3.2.1 \
    pigz \
    procps-ng && \
    micromamba clean -afy

# Set PATH to include conda bin (micromamba uses /opt/conda by default)
ENV PATH="/opt/conda/bin:${PATH}"

# Verify installations
RUN micromamba run -n base fasterq-dump --version && \
    micromamba run -n base pigz --version && \
    micromamba run -n base ps --version

# Set working directory
WORKDIR /data

# Default command
CMD ["/bin/bash"]
