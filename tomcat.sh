# Assigning a variable for tomcat download link
TOMURL="https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.37/bin/apache-tomcat-8.5.37.tar.gz"

# Install the dependencies
yum install java-1.8.0-openjdk -y
yum install git maven wget -y

# Switch to /temp directory 
cd /tmp/

# Download tomcat from the url link as tomcatbin.tar.gz
wget $TOMURL -O tomcatbin.tar.gz

# Assigning a variable to extract the tar.gz
# x-extract = is always required as the first argument when extracting an archive
# v-verbose = verbosely list files processed in background
# z-gzip = filter the archive through gzip
# f-file = option to specify the archive file for extracting
EXTOUT=`tar xvzf tomcatbin.tar.gz`

# Capturing the output of the extraction and taking the first line (which is the top level directory) and assign it to variable TOMDIR 
TOMDIR=`echo $EXTOUT | cut -d '/' -f1`

# Creating a user tomcat with nologin acccess
useradd --shell /sbin/nologin tomcat

# Copy the extracted (top-level)directory to /usr/local/tomcat8 path
# a-copy files recursively and preserve ownership of files when files are copied which is root in this case
# v-verbose
# z-gzip files
# h-human-readable format
rsync -avzh /tmp/$TOMDIR/ /usr/local/tomcat8/

# Change the user & group ownership of tomcat8 directory from root to tomcat  
chown -R tomcat.tomcat /usr/local/tomcat8

# Remove the default systemd setup of tomcat
rm -rf /etc/systemd/system/tomcat.service

# Setup systemd for tomcat to use systemctl commands for the tomcat service
cat <<EOT>> /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat
After=network.target

[Service]

User=tomcat
Group=tomcat

WorkingDirectory=/usr/local/tomcat8

#Environment=JRE_HOME=/usr/lib/jvm/jre
Environment=JAVA_HOME=/usr/lib/jvm/jre

Environment=CATALINA_PID=/var/tomcat/%i/run/tomcat.pid
Environment=CATALINA_HOME=/usr/local/tomcat8
Environment=CATALINE_BASE=/usr/local/tomcat8

ExecStart=/usr/local/tomcat8/bin/catalina.sh run
ExecStop=/usr/local/tomcat8/bin/shutdown.sh


RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target

EOT

# Start and Enable Tomcat service
systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat

# Clone the Project from Github to Buid and Deploy it to Tomcat server
git clone -b <branch-name> <repository-link>
cd <into-project-directory>

########################################################################################################################################
# NOTE: Before Building the Artifact. Update the Configuration file in <project-directory-here>/src/main/resources/applications.properties  
# This Configuration file will be used by the application to connect to the various backend servers									                   	
# Futher Do Build & Deploy																											                                                       
########################################################################################################################################
cat <<EOT>> <project-directory-here>/src/main/resources/applications.properties
#JDBC Configutation for Database Connection
jdbc.driverClassName=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://<mysql-ip-here>:3306/accounts?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull
jdbc.username=<mysql-user-name-here>
jdbc.password=<mysql-user-password-here>

#Memcached Configuration For Active and StandBy Host
#For Active Host
memcached.active.host=<memcached-ip-here>
memcached.active.port=11211
#For StandBy Host
memcached.standBy.host=<memcached-standBy-ip-here>
memcached.standBy.port=11211

#RabbitMq Configuration
rabbitmq.address=<rabbitmq-ip-here>
rabbitmq.port=5672
rabbitmq.username=<rabbitmq-user-name-here>
rabbitmq.password=<rabbitmq-user-password-here>

#Elasticsearch Configuration
elasticsearch.host =<elasticsearch-ip-here>
elasticsearch.port =9300
elasticsearch.cluster=<cluster-here>
elasticsearch.node=<node-here>

EOT

# Build Artifact using Maven
mvn install

# Deploy Artifcat to Tomcat server
# Stop tomcat server
systemctl stop tomcat

# Wait-time for next command
sleep 60

# Deleting the default web application of tomcat
rm -rf /usr/local/tomcat8/webapps/ROOT*

# Copying Artifact to tomcat server
cp target/<ARTIFACT.war> /usr/local/tomcat8/webapps/ROOT.war

# Start tomcat server
systemctl start tomcat

# Wait-time for next command
sleep 120

# For Vagrant Stack deployment copy the applications.properties in vagrant directory and then use below command
cp /vagrant/application.properties /usr/local/tomcat8/webapps/ROOT/WEB-INF/classes/application.properties

# Restart tomcat server
systemctl restart tomcat



