##Install OpenJDK
#Update system
sudo apt update

#Install the OpenJDK package
sudo apt install default-jdk

#Create Tomcat User
sudo useradd -r -m -U -d /opt/tomcat -s /bin/false tomcat

##Install Tomcat
#Download the latest binary release(9.0.30) of Tomcat 9 from the Tomcat 9 downloads page
wget http://www-eu.apache.org/dist/tomcat/tomcat-9/v9.0.30/bin/apache-tomcat-9.0.30.tar.gz -P /tmp

#Extract the Tomcat archive and move it to the /opt/tomcat directory
sudo tar xf /tmp/apache-tomcat-9*.tar.gz -C /opt/tomcat

#Create symbolic link called latest that points to the Tomcat installation directory
sudo ln -s /opt/tomcat/apache-tomcat-9.0.30 /opt/tomcat/latest

#Changes the directory ownership to user and group tomcat
sudo chown -RH tomcat: /opt/tomcat/latest

#Make the scripts inside bin directory executable
sudo sh -c 'chmod +x /opt/tomcat/latest/bin/*.sh'

#Create a systemd Unit File to run Tomcat as a service
sudo nano /etc/systemd/system/tomcat.service

#Paste the following configuration /etc/systemd/system/tomcat.service
# [Unit]
# Description=Tomcat 9 servlet container
# After=network.target
# 
# [Service]
# Type=forking
# 
# User=tomcat
# Group=tomcat
# 
# Environment="JAVA_HOME=/usr/lib/jvm/default-java"
# Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom -Djava.awt.headless=true"
# 
# Environment="CATALINA_BASE=/opt/tomcat/latest"
# Environment="CATALINA_HOME=/opt/tomcat/latest"
# Environment="CATALINA_PID=/opt/tomcat/latest/temp/tomcat.pid"
# Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
# 
# ExecStart=/opt/tomcat/latest/bin/startup.sh
# ExecStop=/opt/tomcat/latest/bin/shutdown.sh
# 
# [Install]
# WantedBy=multi-user.target
# Copy
# Modify the value of JAVA_HOME if the path to your Java installation is different.
# Save and close the file and notify systemd that we created a new unit file:
# 
# sudo systemctl daemon-reload
# Start the Tomcat service by executing:
# 
# sudo systemctl start tomcat
# Check the service status with the following command:
# 
# 
# sudo systemctl status tomcat
# * tomcat.service - Tomcat 9 servlet container
#    Loaded: loaded (/etc/systemd/system/tomcat.service; disabled; vendor preset: enabled)
#    Active: active (running) since Wed 2018-09-05 15:45:28 PDT; 20s ago
#   Process: 1582 ExecStart=/opt/tomcat/latest/bin/startup.sh (code=exited, status=0/SUCCESS)
#  Main PID: 1604 (java)
#     Tasks: 47 (limit: 2319)
#    CGroup: /system.slice/tomcat.service

#Ensure Tomcat service to be automatically started at boot time
sudo systemctl enable tomcat

#Adjust the Firewall - allow traffic on port 8080
sudo ufw allow 8090/tcp

##Configure Tomcat Web Management Interface
#Create a user with access the web management interface
sudo nano /opt/tomcat/latest/conf/tomcat-users.xml

# <tomcat-users>
# <!--
#     Comments
# -->
#    <role rolename="admin-gui"/>
#    <role rolename="manager-gui"/>
#    <user username="admin" password="admin" roles="admin-gui,manager-gui"/>
# </tomcat-users>

#For the Manager app, open the following file:
sudo nano /opt/tomcat/latest/webapps/manager/META-INF/context.xml

#
# context.xml
# <Context antiResourceLocking="false" privileged="true" >
# <!--
#   <Valve className="org.apache.catalina.valves.RemoteAddrValve"
#          allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />
# -->
# </Context>

#For the Host Manager app, open the following file:
sudo nano /opt/tomcat/latest/webapps/host-manager/META-INF/context.xml
#
# context.xml
# <Context antiResourceLocking="false" privileged="true" >
# <!--
#   <Valve className="org.apache.catalina.valves.RemoteAddrValve"
#          allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />
# -->
# </Context>

#Restart the Tomcat service
sudo systemctl restart tomcat

#Test the Tomcat Installation
#Open your browser and type: http://<your_domain_or_IP_address>:8080
