#!/bin/bash
FROM ubuntu:20.04
MAINTAINER courstick@gmail.com

# set timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

WORKDIR /setup
ADD files/apt.sources.list /setup/apt.sources.list
RUN mkdir /root/.pip
ADD files/pip.conf /root/.pip/pip.conf

RUN mv /setup/apt.sources.list /etc/apt/sources.list && \
    apt-get update && \
    apt-get install --no-install-recommends -y apt-utils && \
    apt-get install --no-install-recommends -y vim wget curl && \
    apt-get install --no-install-recommends -y libssl-dev && \
    apt-get install --no-install-recommends -y supervisor && \
    apt-get install --no-install-recommends -y zlib1g-dev && \
    apt-get install --no-install-recommends -y make gcc gobjc++

ADD files/Python-3.9.15.tgz /setup
WORKDIR /setup/Python-3.9.15
RUN ./configure --with-zlib && \
    make -j 4 && \
    make altinstall

# set default python version
RUN update-alternatives --install /usr/bin/python python /usr/local/bin/python3.9 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip3.9 1

RUN rm -f /usr/local/bin/python /usr/local/bin/pip &&\
    ln -s /etc/alternatives/python /usr/local/bin/python &&\
    ln -s /etc/alternatives/pip /usr/local/bin/pip

RUN rm -rf Python-3.9.15.tgz Python-3.9.15

RUN apt-get install --no-install-recommends -y python3-pip libmysqlclient-dev python3-dev
RUN rm -rf /var/lib/apt/lists/*

RUN cp /usr/lib/python3.8/lib-dynload/_sqlite3.cpython-38-x86_64-linux-gnu.so /usr/local/lib/python3.9/lib-dynload/_sqlite3.cpython-39-x86_64-linux-gnu.so

ADD files/requirements.txt /setup/requirements.txt
RUN pip install --upgrade pip
RUN pip install -r /setup/requirements.txt
RUN pip install uwsgi==2.0.21

RUN apt-get remove -y make gobjc++ zlib1g-dev

RUN mkdir /srv/project
RUN mkdir /srv/logs

WORKDIR /srv/project

CMD ["bash"]
