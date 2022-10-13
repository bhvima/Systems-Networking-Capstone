# Systems-Networking-Capstone

## Setting up OpenWhisk on Ubuntu server

```bash
# Clone openwhisk
git clone https://github.com/apache/openwhisk.git openwhisk

# Change current directory to openwhisk
cd openwhisk
```

Build all the Docker images using Gradle
```
./gradlew distDocker
```

To deploy OpenWhisk locally using Ansible
```bash
export OW_DB=CouchDB
export OW_DB_USERNAME=whisk_admin
export OW_DB_PASSWORD=some_passw0rd
export OW_DB_PROTOCOL=http
export OW_DB_HOST=172.17.0.1
export OW_DB_PORT=5984

ansible-playbook -i environments/local setup.yml
ansible-playbook -i environments/local couchdb.yml
ansible-playbook -i environments/local initdb.yml
ansible-playbook -i environments/local wipe.yml
ansible-playbook -i environments/local openwhisk.yml
```
