#
# docker build -t stylegan2-pytorch .
# docker run --gpus all -u $UID:$UID -v $PWD:$PWD -w $PWD -t -i stylegan2-pytorch
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
        IPython==7.16.1 \
        lmdb==1.0.0 \
        ninja==1.10.0.post2 \
        scikit-image==0.17.2 \
        scipy==1.5.4 \
        tqdm==4.55.1 \
        wandb==0.10.12

# Download StyleGAN2 weights
WORKDIR /app/data

COPY ./download_weights.sh .

RUN set -ex \
    && bash download_weights.sh

ENV DATADIR=/app/data

# Compile CUDA ops
WORKDIR /tmp/stylegan2-pytorch

COPY . .

RUN set -ex \
    && python3 -m pip install .

# Download additional weights
ENV TORCH_HOME=/app/torch

RUN set -ex \
    && python3 -c 'import lpips; lpips.PerceptualLoss(model="net-lin", net="vgg")' \
    && python3 -c 'import lpips; lpips.PerceptualLoss(model="net-lin", net="alex")' \
    && python3 -c 'import lpips; lpips.PerceptualLoss(model="net-lin", net="squeeze")' \
    && python3 -c 'import inception; inception.fid_inception_v3()' \
    && python3 -c 'import torchvision; torchvision.models.inception_v3(pretrained=True)' \
    && chmod a+r $TORCH_HOME/hub/checkpoints/*

# Make python command available
RUN set -ex \
    && ln -s $(readlink /usr/bin/python3) /usr/bin/python

# Replace default bashrc because we have no users
RUN set -ex \
    && echo '\
[ -z "$PS1" ] && return\n\
shopt -s checkwinsize\n\
PS1="\h:\w\$ "\n\
eval "$(dircolors -b)"\n\
alias ls="ls --color=auto"\n\
alias ll="ls -alF"\n\
alias la="ls -A"\n\
alias l="ls -CF"\n\
alias grep="grep --color=auto"\n\
' > /etc/bash.bashrc

WORKDIR /

CMD ["/bin/bash"]
