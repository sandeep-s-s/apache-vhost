#!/bin/bash
isVhostExist () {
  domainVal=$(a2query -s|awk '$1 == "'$domain'" {print $1}')
  if [ ! -z "$domainVal" -a "$domainVal" != " " ]
  then
    return 0
  else
      return 1
  fi
}
echo "=========================================="
echo "	Welcome to Vhost "
echo "=========================================="
echo ""
echo -n "Site name [eg : example.com] :"
status=`echo $?`
read domain
if [ -z "$domain" ];then
    echo "Please provide a sitename to continue .."
    echo "eg : example.com"
    exit 3
fi


if isVhostExist $1; then 
  echo "##################################################"
  echo "  Unable to create $domain ; already exists "
  echo "##################################################"
  exit 1
fi
cd /var/www/html && mkdir $domain
cd /etc/apache2/sites-available 
echo "
<VirtualHost *:80>
    ServerAdmin admin@$domain
    ServerName $domain
    ServerAlias www.$domain
    DocumentRoot /var/www/html/$domain
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" | sudo tee -a  $domain.conf
sudo a2ensite $domain.conf
sudo service apache2 restart
sudo a2enmod rewrite
cd /etc
echo "127.0.0.1       $domain" | sudo tee -a hosts
sudo service apache2 restart


cd /var/www/html/$domain
echo "
<html>
  <head>
    <title>Welcome to $domain !</title>
  </head>
  <body>
    <h1>Success!  The $domain virtual host is working!</h1>
  </body>
</html>" | sudo tee -a  index.html


if [ $status = "0" ]; then
	echo "######################################"
	echo "	Virtualhost created "
	printf '\e]8;;http://%s\e\\%s\e]8;;\e\\\n' $domain $domain
	echo "######################################"
	exit 0
else
	echo "##################################################"
	echo "	Something went wrong Please do manually"
	echo "##################################################"
	exit 1
fi

