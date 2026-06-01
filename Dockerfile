# Dockerfile for binder

FROM ghcr.io/sagemath/sage-binder-env:10.3

USER root

# ---------------------------
# User setup (Binder standard)
# ---------------------------
ARG NB_USER=alice
ARG NB_UID=1000

ENV NB_USER=${NB_USER}
ENV NB_UID=${NB_UID}
ENV HOME=/home/${NB_USER}

RUN adduser --disabled-password --gecos "Default user" --uid ${NB_UID} ${NB_USER}

# ---------------------------
# System dependencies
# ---------------------------
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# ---------------------------
# Notebook files
# ---------------------------
COPY notebooks/ ${HOME}/
RUN chown -R ${NB_USER}:${NB_USER} ${HOME}

# ---------------------------
# IMPORTANT: remove broken python kernel (optional)
# ---------------------------
RUN jupyter kernelspec remove python3 -f || true

# ---------------------------
# FIX: register Sage kernel properly (NO ipykernel install)
# ---------------------------
RUN mkdir -p /usr/local/share/jupyter/kernels && \
    ln -s /sage/venv/share/jupyter/kernels/sagemath \
          /usr/local/share/jupyter/kernels/sagemath

# ---------------------------
# Switch to user
# ---------------------------
USER ${NB_USER}
WORKDIR ${HOME}

# ---------------------------
# Python packages inside Sage env
# ---------------------------
RUN /sage/sage --pip install git+https://github.com/QuiverTools/QuiverTools.git
RUN /sage/sage --pip install git+https://github.com/QuiverCombinatoricsTools/QuiverCombinatoricsTools.git
RUN /sage/sage --pip install dot2tex graphviz