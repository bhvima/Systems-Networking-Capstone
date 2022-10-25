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

git clone https://github.com/apache/openwhisk.git openwhisk
cd openwhisk

sudo ./gradlew distDocker

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

docker run -d -p 9095:9095 -e "KAFKA_HOSTS=172.17.0.1:9093" whisk/user-events

