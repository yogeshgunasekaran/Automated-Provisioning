# Installing nginx in Ubuntu	
sudo apt update
sudo apt upgrade
sudo apt install nginx -y

# Configuring Ngnix for Application Servers
cat <<EOT>> backend
upstream backend {

	server <tomcat-ip-here>:8080;

}

server {

	listen 80;

	location / {

		proxy_pass http://backend;

	}

}

EOT

# Move the backend Ngnix Configuration file to Ngnix sites-available directory
sudo mv backend /etc/nginx/sites-available/backend

# Remove default Nginx configuration file
sudo rm -rf /etc/nginx/sites-enabled/default

# Create a Symbolic soft-link in Ngnix sites-enabled for the backend config file in Ngnix sites-available
sudo ln -s /etc/nginx/sites-available/backend /etc/nginx/sites-enabled/backend

# Starting Nginx service
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl restart nginx
