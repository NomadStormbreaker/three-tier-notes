# Launch an instance and install Jenkins
# Since we'll be running the pipeline inside Docker agent, we need
# Docker Pipeline agent
# Manage Jenkins - Plugins - Docker Pipeline


# SonarQube
# Manage Jenkins -> Plugins -> SonarQube 
# Install Sonar on the server (create in the VPC), for now we'll do
# on the same Jenkins server
sudo yum install unzip -y
sudo su -
adduser sonarqube
sudo su sonarqube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.4.0.54424.zip
unzip *
chmod -R 755 /home/sonarqube/sonarqube-9.4.0.54424
chown -R sonarqube:sonarqube /home/sonarqube/sonarqube-9.4.0.54424
cd sonarqube-9.4.0.54424/bin/linux-x86-64/
./sonar.sh start
# Open 9000 port in Security group to access Sonar -> ipaddress:9000
# user = admin | password = admin | new = nomad

# For communication between Jenkins and Sonar
# Go to Sonar Server -> Account -> Security -> Generate Token -> Copy it
# Manage Jenkins -> Credentials -> Secret Text -> Paste the token & Create



# Now install Docker, but we already have docker installed on our server
# Restart Jenkins

# Have Dockerhub Credentials in Jenkins
# Username with password, id = dockerhub-creds

