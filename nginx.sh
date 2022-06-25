# Installing nginx in Ubuntu	
apt update
apt install nginx -y
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

mv backend /etc/nginx/sites-available/backend
rm -rf /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/backend /etc/nginx/sites-enabled/backend

#starting nginx service and firewall
systemctl start nginx
systemctl enable nginx
systemctl restart nginx
