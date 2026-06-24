FROM jenkins/jenkins:lts

USER root

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

RUN apt-get update && apt-get install -y docker.io curl && \
    mkdir -p /usr/libexec/docker/cli-plugins && \
    curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-linux-x86_64" \
      -o /usr/libexec/docker/cli-plugins/docker-compose && \
    chmod +x /usr/libexec/docker/cli-plugins/docker-compose && \
    rm -rf /var/lib/apt/lists/*

RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

COPY casc/ /usr/share/jenkins/ref/casc/

ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

USER jenkins