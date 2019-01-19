FROM jenkins/jenkins:2.150.1

USER root

# Install dependencies
RUN apt-get update \
 && apt-get install -y curl \
 && apt-get install -y openjdk-8-jdk \
 && curl -fsSL https://get.docker.com | sh \
 && apt-get clean \
 && usermod -aG docker jenkins

# Add kubectl
USER root
WORKDIR /usr/local/bin
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x kubectl

# Back to Jenkins home
USER jenkins
WORKDIR $JENKINS_HOME

COPY --chown=jenkins:jenkins *.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/plugins.txt

# Add jobs
#COPY --chown=jenkins:jenkins jobs /var/jenkins_home/jobs
