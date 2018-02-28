FROM debian:jessie
LABEL maintainer="Khwunchai Jaengsawang <khwunchai.j@ku.th>"

RUN apt-get update \
    && apt-get install -y locales \
    && dpkg-reconfigure -f noninteractive locales \
    && locale-gen C.UTF-8 \
    && /usr/sbin/update-locale LANG=C.UTF-8 \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set locales
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    python3 \
    python3-setuptools \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && easy_install3 pip py4j \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# See http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
ENV PYTHONHASHSEED 0
ENV PYTHONIOENCODING UTF-8
ENV PIP_DISABLE_PIP_VERSION_CHECK 1

# Install JAVA
ARG JAVA_MAJOR_VERSION=8
ARG JAVA_UPDATE_VERSION=131
ARG JAVA_BUILD_NUMBER=11
ENV JAVA_HOME /usr/jdk1.${JAVA_MAJOR_VERSION}.0_${JAVA_UPDATE_VERSION}

ENV PATH $PATH:$JAVA_HOME/bin
RUN curl -sL --retry 3 --insecure \
  --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
  "http://download.oracle.com/otn-pub/java/jdk/${JAVA_MAJOR_VERSION}u${JAVA_UPDATE_VERSION}-b${JAVA_BUILD_NUMBER}/d54c1d3a095b4ff2b6607d096fa80163/server-jre-${JAVA_MAJOR_VERSION}u${JAVA_UPDATE_VERSION}-linux-x64.tar.gz" \
  | gunzip \
  | tar x -C /usr/ \
  && ln -s $JAVA_HOME /usr/java \
  && rm -rf $JAVA_HOME/man

# Install Zeppelin
ARG HDP_STACK_VERSION=2.6.4.0
RUN echo "deb http://public-repo-1.hortonworks.com/HDP/debian7/2.x/updates/${HDP_STACK_VERSION}/ HDP main" \
    > /etc/apt/sources.list.d/hdp.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv B9733A7A07513CAD

RUN apt-get update && apt-get install -y -f \
    libpostgresql-jdbc-java \
    libmysql-java \
    zeppelin \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV ZEPPELIN_HOME=/usr/hdp/current/zeppelin-server
WORKDIR ${ZEPPELIN_HOME}
COPY entrypoint.sh .
EXPOSE 9995
RUN chmod +x ./entrypoint.sh
CMD ./entrypoint.sh
