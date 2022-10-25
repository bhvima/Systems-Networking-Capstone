# Systems-Networking-Capstone

What is OpenWhisk?

Apache OpenWhisk is an open source, distributed, serverless platform that executes functions in the form of actions by 
managing the creation and usage of Docker containers where the actions are executed.

Who are we?

The developers here are a group of seniors at Virginia Tech in the Systems and Networking Capstone known as ‘Team C’. We 
all took this capstone looking to work on a project that would allow us to both utilize information that we know and learn 
new information. Across the board there is not much experience in the realm of Function as a Service (FaaS) or utilizing 
serverless platforms, so there is much more towards the realm of learning than doing what we know.

What is our project?

Initially, our project looked to collect or create a variety of OpenWhisk actions so that we could analyze the metrics
produced. From there, we were looking to possibly optimize some aspect of OpenWhisk that was otherwise lacking, or create
a different version of OpenWhisk that would be better depending on the circumstances. However, we found that gathering the 
metric data was more difficult than expected. The documentation provided for OpenWhisk was limited at best, and contradictory 
at worst. The overall setup of the technology wasn’t straightforward, and obtaining the metric data was even more difficult. 
With the semester progressing, and these problems not changing, we decided to shift the focus of our project to developing 
an easier method of gathering these metrics.

What have we accomplished?

Spending a lot of time learning the various components of OpenWhisk and how the different systems work with each other, 
we were able to simplify the process of gathering metric data. Following the README on this page should provide a 
streamlined method to configure and run all necessary containers so that you’ll be able to see the metric data. We are 
looking to describe the process that OpenWhisk takes to create and send these metrics, so anyone else can take on our 
initial project with the startup being a little easier. This description will take place in a different document.

Introduction:

OpenWhisk is one of many Apache technologies, and as you would expect, it requires multiple other Apache technologies to be used. We will briefly describe some of the technologies to the best of our understanding, so that others do not have to come into this technology as blind as we were.

CouchDB:

A database software developed by Apache that is used by OpenWhisk to store the output of actions run by the user. Anything during the process that was sent to the console is also sent to CouchDB for storage. In addition, some data regarding how the action was run is also sent such as the overall time that it took to run or whether or not the container it was run in was cold started. The data stored within this system can be found by either querying the OpenWhisk API under the apigateway container, or by using the activation command provided by the WSK CLI. The metrics we were searching for were a little more descriptive than these, so we needed to continue digging to find them.

ZooKeeper:

Before discussing the real meat of how OpenWhisk metrics are used in Kafka, we have to mention Kafka’s backbone ZooKeeper. 
Apache ZooKeeper is primarily used to manage coordination between distributed systems. From our understanding, ZooKeeper 
manages the complexities that come with distributed systems.

Kafka:

Apache Kafka is a distributed event streaming platform. The distributed portion is managed by the aforementioned ZooKeeper. 
The “event” streaming here is our focus. The events being moved around by Kafka are those metrics that we’ve been searching 
for. Very simply, the inner workings of Kafka break software down into either producers or consumers. Producers are 
technologies that look to create and send events to Kafka. Consumers are technologies that Kafka sends the events to for 
whatever they are to be used for. Essentially, Kafka is a messaging service, except there are trillions of messages sent 
per day, and the messages sent are full of data regarding the inner workings of the system. When it comes to OpenWhisk, 
the event producer is OpenWhisk. Metric data is generated when running actions, and those metrics are packaged into events 
that are eventually sent to Kafka. So what is the Kafka consumer in this case? Well that’s where it gets funky because 
where the producer for OpenWhisk is OpenWhisk, the consumer for OpenWhisk is also OpenWhisk. OpenWhisk also takes back 
in the events that it itself sent to Kafka. So what’s the point? Other software can be connected to Kafka as additional 
consumers, but we will just focus on OpenWhisk as the consumer for this project.


So what actually happens?

As mentioned above, OpenWhisk is both an event producer and event consumer. The reason that it is an event consumer, 
is that people can spin up third party software to connect to the location that OpenWhisk consumes the events. OpenWhisk 
itself doesn’t have a method to view these metrics, but they recommend other tools that you can use to do the job. 
They also have those connections built in their software, so after you configure what you need, the connection will 
be established and now you have your metric data. So why is our semester-long project on something that seems so 
simple? Well the issue here is that using the technologies to view the metrics are not as simple as I described.

Recommended technologies:

Default build - After cloning OpenWhisk, it may be tempting to just quickly build the project with the make file 
to have every container that you need build on its own. However, further inspection shows that none of the configurations 
that you set will be used since it just uses the defaults for its creation. Realizing this issue, we went with the 
Ansible configuration route to build OpenWhisk so that we could actually utilize the logging configuration that we set.

The Kamon Project (StatsD, Grafana, Graphite) - The Kamon project is the first solution that we tried. It is mentioned 
on the OpenWhisk metrics page, so we figured that it would be a good solution. However, it seemed to often conflict with 
the actual build of OpenWhisk, and the project has not been updated in the past couple of years. After seeing that we 
decided to move on.

Datadog - The way of displaying metrics that Apache themselves utilizes is known as Datadog. The metric database storage 
and visualization tools looked promising, but Datadog itself is commercial. As we didn’t want to spend money, we looked 
elsewhere.

The user-metrics page (Prometheus) - Buried deep within the OpenWhisk files and documentation lies the user-metrics page. 
This page describes how users can write their own metrics to be monitored and sent through Kafka. Here it describes 
linking both Prometheus and Grafana to OpenWhisk to maintain and view the metric data, and this is where we found our 
solution. Connecting Prometheus allowed us to view all of the default metrics that were built into OpenWhisk, and we 
could display them in a user-friendly fashion via a graph.

So what now?

Well now that we have the metrics, we can actually look to go back to that original project of ours where we wanted to 
enhance OpenWhisk to some extent. Next we are going to look into obtaining a couple actions that we either find on GitHub 
somewhere or ones that we create ourselves, and we are going to run them a bunch of times to look for any patterns. We 
are going to be on the lookout for any bottlenecks in performance, and hopefully we are able to find some.

Why not just remove logging?

After all this talk on metrics, both producing and consuming, and with Kafka and ZooKeeper being required to do anything 
with them, why not just remove the logging entirely? Would it improve performance? Yes. Then why not do that? Well Apache 
already thought of this in advance, so they developed “OpenWhisk Lean”, a version of OpenWhisk that includes everything 
other than the software needed for metrics. If you are interested in just using a version of OpenWhisk without metrics, 
then I’m not sure why you read this far, but you could utilize OpenWhisk-Lean to really optimize your performance.

## Prerequisite

This setup was created to run on Ubuntu 20.04

```bash
sudo apt install -y python3-pip
sudo pip install ansible==4.1.0
sudo pip install jinja2==3.0.1
sudo pip install docker==4.1.0
sudo apt install -y git
sudo apt install -y default-jre
sudo apt install -y containerd
sudo apt install -y docker.io
sudo apt install -y npm
sudo apt install -y net-tools
sudo service docker start
```

## Setting up OpenWhisk on Ubuntu server

```bash
# Clone openwhisk
git clone https://github.com/apache/openwhisk.git openwhisk

# Change current directory to openwhisk
cd openwhisk
```

Build all the Docker images using Gradle
```
sudo ./gradlew distDocker
```

To deploy OpenWhisk locally using Ansible
```bash
cd ansible/

export OW_DB=CouchDB
export OW_DB_USERNAME=whisk_admin
export OW_DB_PASSWORD=some_passw0rd
export OW_DB_PROTOCOL=http
export OW_DB_HOST=172.17.0.1
export OW_DB_PORT=5984

sudo ansible-playbook -i environments/local setup.yml
sudo ansible-playbook -i environments/local couchdb.yml
sudo ansible-playbook -i environments/local initdb.yml
sudo ansible-playbook -i environments/local wipe.yml
sudo ansible-playbook -i environments/local openwhisk.yml
```

Start the user-events container
```
docker run -d -p 9095:9095 -e "KAFKA_HOSTS=172.17.0.1:9093" whisk/user-events
```

Create a `prometheus.yml` file with the following: (Change IPADDRESS)
```
global:
  scrape_interval: 10s
  evaluation_interval: 10s

scrape_configs:
  - job_name: 'prometheus-server'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'openwhisk-metrics'
    static_configs:
      - targets: ['IPADDRESS:9095']
```

Start prometheus server with PATH_TO_PROMETHEUS replaces with the absolute path to the prometheus.yml
```
docker run -d -p 9090:9090 -v PATH_TO_PROMETHEUS:/etc/prometheus/prometheus.yml prom/prometheus
```


