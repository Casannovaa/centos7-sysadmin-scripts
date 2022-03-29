#!/bin/bash

echo "Select Option"
echo "-------------------"
echo "1 --> httpd"
echo "2 --> PHP"
echo "3 --> MariaDB"
echo "4 --> phpMyAdmin"
echo "5 --> WebTools"
echo "-------------------"
read -p "--> " install

if [[ "$install" == "1" ]]; then
    echo "httpd selected"
    sleep 1
    clear
    echo "Installing tools..."
    yum -y install httpd
    clear
    echo "firewall thing"
    firewall-cmd --add-service=http --zone=internal --permanent
    firewall-cmd --add-service=https --zone=internal --permanent
    firewall-cmd --reload
    clear
    echo "enabling service..."
    systemctl enable httpd
    systemctl start httpd
    clear
    echo "Enabled & Running"
    

elif [[ "$install" == "2" ]]; then
    echo "php selected"
    echo "installing php 7.3..."
    sleep 1
    clear
    sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm 
    sudo yum -y install epel-release yum-utils
    sudo yum-config-manager --disable remi-php54
    sudo yum-config-manager --enable remi-php73
    sudo yum -y install php php-cli php-opcache php-fpm php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json php-mysql
    echo "<FilesMatch \.php$>
    SetHandler \"proxy:fcgi://127.0.0.1:9000\"
    </FilesMatch>
    AddType text/html .php
    DirectoryIndex index.php
    php_value session.save_handler \"files\"
    php_value session.save_path    \"/var/opt/remi/php73/lib/php/session\"" > /etc/httpd/conf.d/php.conf
    systemctl start php-fpm
    systemctl enable php-fpm


elif [[ "$install" == "3" ]]; then
    echo "MariaDB selected"
    yum -y install mariadb-server
    echo "[mysqld]
    character-set-server=utf8
    datadir=/var/lib/mysql
    socket=/var/lib/mysql/mysql.sock
    # Disabling symbolic-links is recommended to prevent assorted security risks
    symbolic-links=0
    # Settings user and group are ignored when systemd is used.
    # If you need to run mysqld under a different user or group,
    # customize your systemd unit file for mariadb according to the
    # instructions in http://fedoraproject.org/wiki/Systemd

    [mysqld_safe]
    log-error=/var/log/mariadb/mariadb.log
    pid-file=/var/run/mariadb/mariadb.pid

    #
    # include all files from the config directory
    #
    !includedir /etc/my.cnf.d" > /etc/my.cnf
    echo "enabling service..."
    systemctl start mariadb
    systemctl enable mariadb
    clear
    echo "Installation of mysql, prepare"
    sleep 3
    mysql_secure_installation
    echo "select user,host,password from mysql.user;"
    mysql -u root -p -e "select user,host,password from mysql.user;"
    echo "show databases;"
    mysql -u root -p -e "show databases;"
    clear
    echo "firewall rules"
    sleep 2
    firewall-cmd --add-service=mysql --permanent --zone=internal
    firewall-cmd --reload

elif [[ "$install" == "4" ]]; then
    echo "phpmyadmin installation..."
    yum -y install phpmyadmin
    read -p "Internal network interface? (¿enp0s8?) --> " intif
    servip=$(ip a | grep "inet" | grep $intif | awk '{print $2}' | awk -F / '{print $1}')
    echo "
    # phpMyAdmin - Web based MySQL browser written in php
    # 
    # Allows only localhost by default
    #
    # But allowing phpMyAdmin to anyone other than localhost should be considered
    # dangerous unless properly secured by SSL

    Alias /phpMyAdmin /usr/share/phpMyAdmin
    Alias /phpmyadmin /usr/share/phpMyAdmin

    <Directory /usr/share/phpMyAdmin/>
    AddDefaultCharset UTF-8

    <IfModule mod_authz_core.c>
        # Apache 2.4
        <RequireAny>
        Require ip 127.0.0.1 $servip
        Require ip ::1
        </RequireAny>
    </IfModule>
    <IfModule !mod_authz_core.c>
        # Apache 2.2
        Order Deny,Allow
        Deny from All
        Allow from 127.0.0.1
        Allow from ::1
    </IfModule>
    </Directory>

    <Directory /usr/share/phpMyAdmin/setup/>
    <IfModule mod_authz_core.c>
        # Apache 2.4
        <RequireAny>
        Require ip 127.0.0.1 $servip
        Require ip ::1
        </RequireAny>
    </IfModule>
    <IfModule !mod_authz_core.c>
        # Apache 2.2
        Order Deny,Allow
        Deny from All
        Allow from 127.0.0.1
        Allow from ::1
    </IfModule>
    </Directory>

    # These directories do not require access over HTTP - taken from the original
    # phpMyAdmin upstream tarball
    #
    <Directory /usr/share/phpMyAdmin/libraries/>
    <IfModule mod_authz_core.c>
        # Apache 2.4
        Require all denied
    </IfModule>
    <IfModule !mod_authz_core.c>
        # Apache 2.2
        Order Deny,Allow
        Deny from All
        Allow from None
    </IfModule>
    </Directory>

    <Directory /usr/share/phpMyAdmin/setup/lib/>
    <IfModule mod_authz_core.c>
        # Apache 2.4
        Require all denied
    </IfModule>
    <IfModule !mod_authz_core.c>
        # Apache 2.2
        Order Deny,Allow
        Deny from All
        Allow from None
    </IfModule>
    </Directory>

    <Directory /usr/share/phpMyAdmin/setup/frames/>
    <IfModule mod_authz_core.c>
        # Apache 2.4
        Require all denied
    </IfModule>
    <IfModule !mod_authz_core.c>
        # Apache 2.2
        Order Deny,Allow
        Deny from All
        Allow from None
    </IfModule>
    </Directory>

    # This configuration prevents mod_security at phpMyAdmin directories from
    # filtering SQL etc.  This may break your mod_security implementation.
    #
    #<IfModule mod_security.c>
    #    <Directory /usr/share/phpMyAdmin/>
    #        SecRuleInheritance Off
    #    </Directory>
    #</IfModule>" > /etc/httpd/conf.d/phpMyAdmin.php
    systemctl restart httpd php*

elif [[ "$install" == "5" ]]; then
    echo "Webtools selected"
    sleep 1
    yum -y install wget zip
    clear
    echo "-------------------"
    echo "1 --> Piwik (Matomo)"
    echo "2 --> Wiki"
    echo "3 --> Wordpress"
    echo "-------------------"
    read -p "--> " webtool
    
    if [[ $webtool == "1" ]]; then
        echo "Piwik selected"
        sleep 2
        clear
        echo "mariadb config..."
        sleep 2
        clear
        echo "create database piwik;"
        mysql -u root -p -e "create database piwik;"
        echo "grant all privileges on piwik.* to piwik@'localhost' identified by 'password';"
        mysql -u root -p -e "grant all privileges on piwik.* to piwik@'localhost' identified by 'password';"
        echo "flush privileges;"
        mysql -u root -p -e "flush privileges;"
        sed -i 's/memory_limit = 128M/memory_limit = 512M/g'
        wget http://piwik.org/latest.zip -P /var/www/html
        unzip /var/www/html/latest.zip -d /var/www/html
        chown -R apache. /var/www/html/matomo/tmp
        chown -R apache. /var/www/html/matomo/config
        setsebool -P httpd_can_network_connect_db on
        chcon -R -t httpd_sys_rw_content_t /var/www/html/matomo/tmp
        chcon -R -t httpd_sys_rw_content_t /var/www/html/matomo/config
        semanage fcontext -a -t httpd_sys_rw_content_t /var/www/html/matomo/tmp
        semanage fcontext -a -t httpd_sys_rw_content_t /var/www/html/matomo/config
        systemctl restart httpd php*

    elif [[ $webtool == "2" ]]; then
        echo "Wiki selected"
        sleep 1
        clear
        echo "create database mediawiki;"
        mysql -u root -p -e "create database mediawiki;"
        echo "grant all privileges on mediawiki.* to mediawiki@'localhost' identified by 'password';"
        mysql -u root -p -e "grant all privileges on mediawiki.* to mediawiki@'localhost' identified by 'password';"
        echo "flush privileges;"
        mysql -u root -p -e "flush privileges;"
        clear
        echo "Downloading Mediawiki"
        sleep 1
        yum -y install centos-release-scl-rh centos-release-scl
        sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-SCLo-scl.repo
        sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo
        yum --enablerepo=centos-sclo-rh -y install rh-php73-php-mysql rh-php73-php-mbstring
        wget http://releases.wikimedia.org/mediawiki/1.27/mediawiki-1.27.1.tar.gz
        tar zxvf mediawiki-1.27.1.tar.gz
        rm mediawiki-1.27.1.tar.gz
        mv mediawiki-1.27.1 /var/www/html/mediawiki
        chown -R apache. /var/www/html/mediawiki
        systemctl restart httpd php*

        chcon -R -t httpd_sys_rw_content_t /var/www/html/mediawiki
        semanage fcontext -a -t httpd_sys_rw_content_t /var/www/html/mediawiki

    elif [[ $webtool == "3" ]]; then
        echo "Wordpress selected"
        sleep 2
        clear
        echo "QUE VA BRO QUE ASCO"
   fi
fi

echo "Done i guess"
