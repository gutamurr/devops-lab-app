## 📃 Pet-project to understand how Docker, Jenkins and CI/CD pipelines work.  
#### Run Jenkins container:
```bash
docker run -d -p 8000:8080 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --name jenkins \
  jenkins/jenkins:latest
```
_We've mounted the Docker host's Docker socket to allow Jenkins to run Docker commands and start containers on the host machine._  
⚠️ Mounting `/var/run/docker.sock` gives Jenkins root-level control over the Docker host and should only be used in trusted environments.


#### Access Jenkins
Open:  
`http://localhost:8000`

Get the initial admin password:  
`docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword`

### Install Docker tool 

************************************************

### Troubleshooting
### 1. Permission issues when running Docker commands

If Jenkins cannot execute Docker commands (e.g. `permission denied` when accessing `/var/run/docker.sock`), this is usually caused by a mismatch between the container user and the Docker socket group on the host.

A common fix is to run Jenkins with the correct group ID (typically `1001`):

```bash
docker run -d -p 8000:8080 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --group-add 1001 \
  --name jenkins \
  jenkins/jenkins:latest
```

### 2. Docker API version mismatch (deprecated API / environment error)
#### If you see errors like:
`client version X is too old, minimum supported API version is Y`  
this is caused by a mismatch between the Docker client inside the Jenkins container and the Docker Engine on the host.

**Fix it by explicitly setting a compatible Docker API version in the environment:**
```bash
docker run -d -p 8000:8080 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e DOCKER_API_VERSION=1.43 \
  --name jenkins \
  jenkins/jenkins:latest
```
**OR in your Jenkins pipeline**

```pipeline
environment {
        DOCKER_API_VERSION = 'version'
    }
```

You can find the supported API version on the host with:
`docker version`
