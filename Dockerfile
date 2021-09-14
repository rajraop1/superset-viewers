#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
FROM python:3.6-jessie

RUN useradd --user-group --create-home --no-log-init --shell /bin/bash superset

# Configure environment
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update -y

# Install dependencies to fix `curl https support error` and `elaying package configuration warning`
RUN apt-get install -y apt-transport-https apt-utils

# Install superset dependencies
# https://superset.incubator.apache.org/installation.html#os-dependencies
RUN apt-get install -y build-essential libssl-dev \
    libffi-dev python3-dev libsasl2-dev libldap2-dev libxi-dev

# Install nodejs for custom build
# https://superset.incubator.apache.org/installation.html#making-your-own-build
# https://nodejs.org/en/download/package-manager/
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y --force-yes nodejs

RUN mkdir -p /home/superset
RUN chown superset /home/superset

WORKDIR /home/superset
ARG VERSION

#RUN svn co https://dist.apache.org/repos/dist/dev/incubator/superset/$VERSION ./
#RUN tar -xvf *.tar.gz
#WORKDIR apache-superset-incubating-$VERSION

RUN mkdir superset
COPY . superset
WORKDIR superset


RUN cd superset/assets \
    && npm ci \
    && npm run build \
    && rm -rf node_modules

RUN ls
RUN ls requirements.txt
RUN ls requirements-dev.txt


#WORKDIR /home/superset/apache-superset-incubating-$VERSION
RUN pip install --upgrade setuptools==57 pip \
    && pip install -r requirements.txt -r requirements-dev.txt \
    && pip install -e . \
    && rm -rf /root/.cache/pip

RUN fabmanager babel-compile --target superset/translations

RUN pip install -e . \
    && rm -rf /root/.cache/pip

ENV PATH=/home/superset/superset/bin:$PATH \
    PYTHONPATH=/home/superset/superset/:$PYTHONPATH
COPY from_tarball_entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
