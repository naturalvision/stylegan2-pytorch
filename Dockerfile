#
# docker build --build-arg uid=$UID --build-arg user=$LOGNAME -t stylegan2-pytorch-$LOGNAME .
# docker run --gpus all -u $UID:$UID -v $PWD:$PWD -w $PWD -t -i stylegan2-pytorch-$LOGNAME
#
# python generate.py --ckpt /app/data/stylegan2-ffhq-config-f.pt --pics 10
#

FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04
ENV DEBIAN_FRONTEND=noninteractive

RUN set -ex \
    && apt update -q \
    && apt install -qy apt-utils \
    && apt install -qy python3-dev python3-venv python3-pip python3-wheel \
                       curl \
    && apt clean

RUN set -ex \
    && python3 -m pip install -U pip \
    && python3 -m pip install \
        -f https://download.pytorch.org/whl/torch_stable.html \
        torch==1.6.0+cu101 \
        torchvision==0.7.0+cu101

RUN set -ex \
    && python3 -m pip install \
        joblib==0.16.0 \
        ninja==1.10.0.post2 \
        matplotlib==3.3.2 \
        scikit-learn==0.23.2 \
        scipy==1.5.2 \
        tqdm==4.49.0

# Download weights
WORKDIR /app/data

COPY ./download_weights.sh .

RUN set -ex \
    && bash download_weights.sh

ENV DATADIR=/app/data

# Add user (override with --build-arg)
ARG uid=1000
ARG user=dockeruser

RUN set -ex \
    && groupadd -g $uid $user \
    && useradd -g $uid -u $uid -l -m $user

# Create venv
USER $user
WORKDIR /home/$user

RUN set -ex \
    && python3 -m venv --system-site-packages venv \
    && echo "source ~/venv/bin/activate" >> .bashrc

CMD ["/bin/bash"]
