import hudson.model.JDK
import jenkins.model.Jenkins

Jenkins.getInstance().getJDKs().add(new JDK("jdk8", "/usr/lib/jvm/java-8-openjdk-amd64"))
