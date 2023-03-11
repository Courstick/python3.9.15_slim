#!/bin/bash
FROM ubuntu:20.04
MAINTAINER courstick@gmail.com

# set timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

WORKDIR /setup
ADD files/apt.sources.list /setup/apt.sources.list
RUN mkdir /root/.pip
ADD files/pip.conf /root/.pip/pip.conf

RUN DEBIAN_FRONTEND=noninteractive mv /setup/apt.sources.list /etc/apt/sources.list && \
    apt-get update && \
    apt-get install --no-install-recommends -y dialog apt-utils && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get install --no-install-recommends -y vim wget && \
    apt-get install --no-install-recommends -y libssl-dev gcc && \
    apt-get install --no-install-recommends -y curl && \
    apt-get install --no-install-recommends -y make

ADD files/Python-3.9.15.tgz /setup
WORKDIR /setup/Python-3.9.15
RUN ./configure && \
    make -j 4 && \
    make altinstall

# set default python version
RUN update-alternatives --install /usr/bin/python python /usr/local/bin/python3.9 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip3.9 1

RUN rm -rf Python-3.9.15.tgz Python-3.9.15

RUN apt-get install --no-install-recommends -y python3-pip libmysqlclient-dev python3-dev && \
    rm -rf /var/lib/apt/lists/*

ADD files/requirements.txt /setup/requirements.txt
RUN pip install --upgrade pip
RUN pip install -r /setup/requirements.txt
RUN pip install setuptools==67.6.0
RUN pip install supervisor
RUN pip install uwsgi==2.0.21

RUN mkdir /srv/project
RUN mkdir /srv/logs

WORKDIR /srv/project

CMD ["bash"]
