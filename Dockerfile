FROM tschaffter/cxx-ci:1.0.0-beta.5

LABEL maintainer="thomas.schaffter@gmail.com"

# Install ESP-IDF prerequisites
RUN apt-get update -qq -y && apt-get install -qq -y \
    flex \
    bison \
    gperf \
    python \
    python-pip \
    python-setuptools \
    python-serial \
    python-click \
    python-cryptography \
    python-future \
    python-pyparsing \
    python-pyelftools \
    ccache \
    libffi-dev \
    libssl-dev \
    libusb-1.0 \
    && apt-get -y autoclean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt-get/lists/*

# Install ESP-IDF
# To build the image for a branch or a tag of IDF, pass --build-arg IDF_CLONE_BRANCH_OR_TAG=name.
# To build the image with a specific commit ID of IDF, pass --build-arg IDF_CHECKOUT_REF=commit-id.
# It is possibe to combine both, e.g.:
#   IDF_CLONE_BRANCH_OR_TAG=release/vX.Y
#   IDF_CHECKOUT_REF=<some commit on release/vX.Y branch>.
ARG IDF_CLONE_URL=https://github.com/espressif/esp-idf.git
ARG IDF_CLONE_BRANCH_OR_TAG=release/v4.1
ARG IDF_CHECKOUT_REF=

ENV IDF_PATH=/opt/esp/idf
ENV IDF_TOOLS_PATH=/opt/esp

RUN echo IDF_CHECKOUT_REF=$IDF_CHECKOUT_REF IDF_CLONE_BRANCH_OR_TAG=$IDF_CLONE_BRANCH_OR_TAG && \
    git clone --recursive \
        ${IDF_CLONE_BRANCH_OR_TAG:+-b $IDF_CLONE_BRANCH_OR_TAG} \
        $IDF_CLONE_URL $IDF_PATH && \
    if [ -n "$IDF_CHECKOUT_REF" ]; then \
        cd $IDF_PATH && \
        git checkout $IDF_CHECKOUT_REF && \
        git submodule update --init --recursive; \
    fi

RUN cd $IDF_PATH \
    && ./install.sh