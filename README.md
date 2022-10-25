# Systems-Networking-Capstone

## Prerequisite

This setup was created to run on Ubuntu 20.04

```bash
sudo apt install python3-pip
sudo pip install ansible==4.1.0
sudo pip install jinja2==3.0.1
sudo pip install docker==4.1.0
sudo apt install git
sudo apt install default-jre
sudo apt install -y containerd
sudo apt install -y docker.io
sudo apt install npm
sudo apt install net-tools
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


