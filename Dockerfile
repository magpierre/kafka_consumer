#
#
#   Copyright 2019 MapR Technologies
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#

FROM golang:1.11 as builder
RUN apt-get update -y && apt-get install -y syslinux openjdk-8-jdk net-tools git
COPY libs/. .
RUN apt-get install ./mapr-librdkafka_0.11.3.201803231414_all.deb
RUN apt-get install ./mapr-client-6.1.0.20180926230239.GA-1.amd64.deb
RUN apt-get install ./libssl1.0.0_1.0.1t-1+deb8u11_amd64.deb
RUN mkdir -p /go/src/github.com/confluentinc
WORKDIR /go/src/github.com/confluentinc
RUN git clone --single-branch --branch 0.11.0.x https://github.com/confluentinc/confluent-kafka-go.git
RUN go get gopkg.in/alecthomas/kingpin.v2
RUN mkdir -p /go/src/github.com/magpierre/kafka-consumer
WORKDIR /go/src/github.com/magpierre/kafka-consumer
COPY . .
ENV PKG_CONFIG_PATH=/go/src/github.com/magpierre/kafka-consumer
ENV LD_LIBRARY_PATH=/usr/lib64:/opt/mapr/lib:/usr/local/lib64:/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu
RUN CGO_ENABLED=1 GOOS=linux go build -a -installsuffix cgo -o /go/bin/kafka-consumer .

FROM ubuntu:16.04
WORKDIR /root/
COPY libs/. .
RUN apt-get update -y && apt-get install -y syslinux openjdk-8-jdk net-tools
RUN apt-get clean
RUN apt-get install -y ./mapr-librdkafka_0.11.3.201803231414_all.deb
RUN apt-get install -y ./mapr-client-6.1.0.20180926230239.GA-1.amd64.deb 
RUN groupadd -g 2000 mapr \
&& useradd -m -u 2000 -g mapr mapr
ENV LD_LIBRARY_PATH=/usr/lib64:/opt/mapr/lib:/usr/local/lib64:/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu
RUN /opt/mapr/server/configure.sh -N maprdemo.mapr.io -c -C 10.0.0.11:7222
RUN rm  -f ./mapr-librdkafka_0.11.3.201803231414_all.deb
RUN rm  -f ./mapr-client-6.1.0.20180926230239.GA-1.amd64.deb
RUN rm  -f ./libssl1.0.0_1.0.1t-1+deb8u11_amd64.deb
# Copy the Pre-built binary file from the previous stage
COPY --from=builder /go/bin/kafka-consumer .
# Run the executable
ENTRYPOINT ["./kafka-consumer"]
CMD [ "-h" ]