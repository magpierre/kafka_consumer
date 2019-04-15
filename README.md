## kafka-consumer

Kafka consumer is a sample go application that reads data from MapR Event Store For Apache Kafka and echos it to the output.
It utilizes the MapR Client, and librdkafka.

In order to build the project, please download:

- mapr-client-6.1.0.20180926230239.GA-1.amd64.deb
- mapr-librdkafka_0.11.3.201803231414_all.deb
- libssl1.0.0_1.0.1t-1+deb8u11_amd64.deb

[MapR Packages](http://package.mapr.com/releases/v6.1.0/ubuntu/)
[SSL Library](https://packages.debian.org/jessie/amd64/libssl1.0.0/download)
And put them in a folder called libs under the root of the project

Please edit the Dockerfile to point the mapr-client to a cluster near you.

Building the project 
project is built using:
`docker build -t kafka-consumer .`

`docker run -it kafka-consumer -topic /tmp/teststream:inputdata`