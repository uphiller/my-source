FROM ubuntu:24.10

RUN apt-get update && apt-get install -y curl git

WORKDIR /vendor

RUN curl -OL http://nodejs.org/dist/v0.10.28/node-v0.10.28-linux-x64.tar.gz \
    && tar xvf node-v0.10.28-linux-x64.tar.gz \
    && ln -s node-v0.10.28-linux-x64 /vendor/node
ENV  NODE_HOME=$HOME/vendor/node
ENV  PATH=$NODE_HOME/bin:$PATH


RUN git clone http://github.com/naver/arcus-hubble
WORKDIR /vendor/arcus-hubble
RUN npm install forever
RUN npm install
RUN chmod +x ./start.sh

EXPOSE 8080

CMD ["./start.sh"]