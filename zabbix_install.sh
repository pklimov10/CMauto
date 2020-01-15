#!/bin/bash
#утсановка веб обвязок
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
yum install http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm -y
yum install nginx -y
systemctl start nginx
systemctl enable nginx
#Дальше устанавливаем php-fpm. Для этого подключаем репозиторий remi и epel-release.
yum install epel-release -y
yum install  http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
#Активируем репу remi-php71, для этого выполняем команды:
yum install yum-utils -y
yum-config-manager --enable remi-php71 -y
#Устанавливаем php 7.1 и модули к нему.
yum install php71 php-fpm php-cli php-mysql  php-gd php-ldap php-odbc php-pdo php-pecl-memcache php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap php-bcmath -y
#Запускаем php-fpm и добавляем в автозагрузку.
chown -R nginx:nginx /var/lib/php/session
chown -R nginx:nginx /etc/zabbix/web
systemctl start php-fpm
systemctl enable php-fpm
sed -i 's/listen = 127.0.0.1:9000/;listen = 127.0.0.1:9000/' /etc/php-fpm.d/www.conf
sed -i 's/;listen.mode = 0660/listen.mode = 0660/' /etc/php-fpm.d/www.conf
echo "listen = /var/run/php-fpm/php-fpm.sock" >> /etc/php-fpm.d/www.conf
#echo "llisten.mode = 0660" >> /etc/php-fpm.d/www.conf
echo "listen.owner = nginx" >> /etc/php-fpm.d/www.conf
echo "listen.group = nginx" >> /etc/php-fpm.d/www.conf
sed -i 's/user = apache/user = nginx/' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/' /etc/php-fpm.d/www.conf
systemctl restart php-fpm
yum install yum install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm -y
yum -y install postgresql12 postgresql12-server
/usr/pgsql-12/bin/postgresql-12-setup initdb
systemctl enable postgresql-12
systemctl start postgresql-12
yum install -y  https://repo.zabbix.com/zabbix/4.4/rhel/7/x86_64/zabbix-release-4.4-1.el7.noarch.rpm
yum -y install zabbix-server-pgsql zabbix-web-pgsql zabbix-agent -y
cat /dev/null > /var/lib/pgsql/12/data/pg_hba.conf
echo  'local   all             all                                     trust' >> /var/lib/pgsql/12/data/pg_hba.conf
echo  'local   zabbix          zabbix                                       md5' >>  /var/lib/pgsql/12/data/pg_hba.conf
echo  'host    all             postgres             127.0.0.1/32            md5' >>  /var/lib/pgsql/12/data/pg_hba.conf
echo  'host    zabbix          zabbix               127.0.0.1/32            md5' >> /var/lib/pgsql/12/data/pg_hba.conf
echo  'host    all             all             ::1/128                 ident' >> /var/lib/pgsql/12/data/pg_hba.conf
echo  'local   replication     all                                     peer' >> /var/lib/pgsql/12/data/pg_hba.conf
echo  'host    replication     all             127.0.0.1/32            ident' >> /var/lib/pgsql/12/data/pg_hba.conf
echo 'host    replication     all             ::1/128                 ident' >> /var/lib/pgsql/12/data/pg_hba.conf
systemctl restart postgresql-12
sudo -u postgres createuser  zabbix
psql -U postgres -t -c "alter user zabbix with encrypted password 'zabbix'";
sudo -u postgres createdb -O zabbix zabbix
zcat /usr/share/doc/zabbix-server-pgsql*/create.sql.gz | sudo -u zabbix psql zabbix
sed -i 's/# DBPassword=/DBPassword=zabbix/' /etc/zabbix/zabbix_server.conf
systemctl reload postgresql-12
cat /dev/null > /etc/nginx/conf.d/default.conf
echo  'server {
    listen       80;
    server_name  localhost;
    root /usr/share/zabbix;

    location / {
	index index.php index.html index.htm;
    }

    location ~ \.php$ {
	fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
	fastcgi_index index.php;
	fastcgi_param SCRIPT_FILENAME  $document_root$fastcgi_script_name;
	include fastcgi_params;
	fastcgi_param PHP_VALUE "
	max_execution_time = 300
	memory_limit = 128M
	post_max_size = 16M
	upload_max_filesize = 2M
	max_input_time = 300
	date.timezone = Europe/Moscow
	always_populate_raw_post_data = -1
	";
	fastcgi_buffers 8 256k;
	fastcgi_buffer_size 128k;
	fastcgi_intercept_errors on;
	fastcgi_busy_buffers_size 256k;
	fastcgi_temp_file_write_size 256k;
        }
}' >>/etc/nginx/conf.d/default.conf
nginx -s reload
chown -R nginx:nginx /var/lib/php/session
chown -R nginx:nginx /etc/zabbix/web
systemctl restart php-fpm
echo  "Пароль от РСУБД zabbix"
echo  "Доступно по ссылке http://ip"
echo  "В разделе DatabaseHost в вэб морде прописать 127.0.0.1 место localhost"
systemctl restart zabbix-server