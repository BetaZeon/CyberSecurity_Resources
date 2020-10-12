# INSTALLATION INSTRUCTIONS
## for NetBSD 9.0-amd64

!!! warning
    This is not fully working yet. Mostly it is a template for our ongoing documentation efforts :spider:
    LIEF, will probably not be available for a long long time on NetBSD, until someone is brave enough to make it work.
    GnuPG also needs some more TLC.
    misp-modules are broken because of the python-opencv dependency.

### 0/ WIP! You are warned, this does only partially work!
------------

{!generic/globalVariables.md!}

```bash
export AUTOMAKE_VERSION=1.16
export AUTOCONF_VERSION=2.69
```

### 1/ Minimal OpenBSD install
------------

#### Install standard NetBSD-amd64 without X11

- ntpdate on boot
- ntp
- ntpd
- ssh

#### System Hardening

- TBD

#### sudo & pkgin (as root)
```bash
su root -c "cd /usr/pkgsrc/pkg tools/pkgin/; make install clean"
su root -c "pkgin update"
su root -c "pkgin -y install sudo gsed"
su root -c 'gsed -i -e "s/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/" /usr/pkg/etc/sudoers'
```

##### In case you forgot to fetch pkgsrc (optional)

```bash
cd /usr
env CVS_RSH=ssh cvs -d anoncvs@anoncvs.NetBSD.org:/cvsroot checkout -P pkgsrc
cd pkgsrc/bootstrap
./bootstrap
cd /usr/pkgsrc/pkg tools/pkgin/; make install clean
/usr/pkg/sbin/pkg_admin fetch-pkg-vulnerabilities
```

```
You may wish to have the vulnerabilities file downloaded daily so that it
remains current. This may be done by adding an appropriate entry to the root
users crontab(5) entry. For example the entry

# Download vulnerabilities file
0 3 * * * /usr/pkg/sbin/pkg_admin fetch-pkg-vulnerabilities >/dev/null 2>&1
# Audit the installed packages and email results to root
9 3 * * * /usr/pkg/sbin/pkg_admin audit |mail -s "Installed package audit result" \
            root >/dev/null 2>&1
```

#### Install bash
```bash
sudo pkgin -y install bash
```

#### mariadb server
```bash
sudo pkgin -y install mysql-server 
```

#### Install misc dependencies

```bash
sudo pkgin -y install curl git python37 py37-pip redis autoconf automake libtool magic
```

```bash
sudo pkgin -y install gnupg2
```

#### Install postfix (optional)

```bash
sudo pkgin -y install postfix
```

#### vim (optional)
```bash
sudo pkgin -y install vim
sudo mv /usr/bin/vi /usr/bin/vi-`date +%d%m%y`
sudo ln -s /usr/pkg/bin/vim /usr/bin/vi
```

#### apache + php + moz-rootcerts

```bash
sudo pkgin -y install php ap24-php74 php74-fpm php74-redis3 php74-mysqli php74-pdo_mysql php74-pcntl php74-json php74-iconv php74-gd php74-mbstring php74-pear-Crypt_GPG
sudo cp /usr/share/examples/openssl/openssl.cnf /etc/openssl/
sudo mozilla-rootcerts install
sudo cp /usr/pkg/share/examples/rc.d/apache /etc/rc.d/
echo apache=yes |sudo tee /etc/rc.conf.d/apache
```

#### misp user
```bash
sudo useradd -m -s /usr/pkg/bin/bash -G wheel,www misp
```

#### Install X11R7 post-install
```bash
cd /tmp
wget https://ftp.netbsd.org/pub/NetBSD/NetBSD-9.0/amd64/binary/sets/xbase.tgz
sudo tar -C / -xzphf xbase.tgz
rm xbase.tgz
```

#### If a valid SSL certificate is not already created for the server, create a self-signed certificate:

```
# OpenSSL configuration
OPENSSL_C='LU'
OPENSSL_ST='State'
OPENSSL_L='Location'
OPENSSL_O='Organization'
OPENSSL_OU='Organizational Unit'
OPENSSL_CN='Common Name'
OPENSSL_EMAILADDRESS='info@localhost'
```

```bash
sudo openssl req -sha256 -newkey rsa:4096 -days 3650 -nodes -x509 -subj "/C=$OPENSSL_C/ST=$OPENSSL_ST/L=$OPENSSL_L/O=<$OPENSSL_O/OU=$OPENSSL_OU/CN=$OPENSSL_CN/emailAddress=$OPENSSL_EMAILADDRESS" -keyout /etc/openssl/private/server.key -out /usr/pkg/etc/httpd/server.crt
```

#### Install Python virtualenv
```bash
sudo ln -sf /usr/pkg/bin/pip3.7 /usr/pkg/bin/pip
sudo ln -s /usr/pkg/bin/python3.7 /usr/pkg/bin/python
sudo ln -s /usr/pkg/bin/python3.7 /usr/pkg/bin/python3
sudo pkgin -y install py37-virtualenv
sudo ln -s /usr/pkg/bin/virtualenv-3.7 /usr/pkg/bin/virtualenv
```

#### Install ssdeep
```
sudo mkdir -p /usr/local/src
sudo chown misp:users /usr/local/src
cd /usr/local/src
sudo -u misp git clone https://github.com/ssdeep-project/ssdeep.git
cd ssdeep
sudo -u misp ./bootstrap
sudo -u misp ./configure --prefix=/usr
sudo -u misp make
sudo make install
```


#### /usr/pkg/etc/php.ini

#### Enable redis

```bash
sudo cp /usr/pkg/share/examples/rc.d/redis /etc/rc.d
echo redis=yes |sudo tee /etc/rc.conf.d/redis
sudo /etc/rc.d/redis start
```

#### Enable mysqld
```bash
sudo cp /usr/pkg/share/examples/rc.d/mysqld /etc/rc.d/
echo mysqld=yes |sudo tee /etc/rc.conf.d/mysqld
sudo /etc/rc.d/mysqld start
sudo /usr/pkg/bin/mysql_secure_installation
# TODO: Figure out how to properly bind to localhost
##doas rcctl set mysqld flags --bind-address=127.0.0.1
```

### 2/ MISP code
------------
```bash
# Download MISP using git in the /usr/local/www/ directory.
PATH_TO_MISP=/usr/pkg/share/httpd/htdocs/MISP
sudo mkdir $PATH_TO_MISP
sudo chown www:www $PATH_TO_MISP
cd $PATH_TO_MISP
sudo -u www git clone https://github.com/MISP/MISP.git $PATH_TO_MISP
sudo -u www git submodule update --progress --init --recursive
# Make git ignore filesystem permission differences for submodules
sudo -u www git submodule foreach --recursive git config core.filemode false

# Make git ignore filesystem permission differences
sudo -u www git config core.filemode false

#sudo pkgin -y install py-pip py3-pip libxslt py3-jsonschema
sudo pkgin -y install libxslt
#sudo virtualenv -ppython3 /usr/local/virtualenvs/MISP
sudo -u www virtualenv -ppython3 $PATH_TO_MISP/venv
sudo -u www HOME=/tmp $PATH_TO_MISP/venv/bin/pip install -U pip

cd $PATH_TO_MISP/app/files/scripts
sudo -u www git clone https://github.com/CybOXProject/python-cybox.git
sudo -u www git clone https://github.com/STIXProject/python-stix.git
cd $PATH_TO_MISP/app/files/scripts/python-cybox
sudo -u www $PATH_TO_MISP/venv/bin/python setup.py install --global-option=build_ext --global-option="-I/usr/pkg/include/"
cd $PATH_TO_MISP/app/files/scripts/python-stix
sudo -u www $PATH_TO_MISP/venv/bin/python setup.py install

# install mixbox to accommodate the new STIX dependencies:
cd $PATH_TO_MISP/app/files/scripts/
sudo -u www git clone https://github.com/CybOXProject/mixbox.git
cd $PATH_TO_MISP/app/files/scripts/mixbox
sudo -u www $PATH_TO_MISP/venv/bin/python setup.py install

# install PyMISP
cd $PATH_TO_MISP/PyMISP
sudo -u www $PATH_TO_MISP/venv/bin/python setup.py install

# install support for STIX 2.0
sudo -u www HOME=/tmp $PATH_TO_MISP/venv/bin/pip install stix2

# install python-magic, pydeep and maec
sudo -u www HOME=/tmp $PATH_TO_MISP/venv/bin/pip install python-magic
sudo -u www HOME=/tmp $PATH_TO_MISP/venv/bin/pip install git+https://github.com/kbandla/pydeep.git
sudo -u www HOME=/tmp $PATH_TO_MISP/venv/bin/pip install maec
sudo -u www HOME=/tmp $PATH_TO_MISP/venv/bin/pip install plyara
```

### 3/ CakePHP
-----------
```bash
# CakePHP is included as a submodule of MISP and has been fetched earlier.
# Install CakeResque along with its dependencies if you intend to use the built in background jobs:
cd $PATH_TO_MISP/app
#sudo -u www php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
#sudo -u www php -r "if (hash_file('SHA384', 'composer-setup.php') === 'baf1608c33254d00611ac1705c1d9958c817a1a33bce370c0595974b342601bd80b92a3f46067da89e3b06bff421f182') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink
#('composer-setup.php'); } echo PHP_EOL;"
#sudo -u www env HOME=/tmp php composer-setup.php
#sudo -u www php -r "unlink('composer-setup.php');"
sudo -u www HOME=/tmp php composer.phar install

# To use the scheduler worker for scheduled tasks, do the following:
sudo -u www cp -f $PATH_TO_MISP/INSTALL/setup/config.php $PATH_TO_MISP/app/Plugin/CakeResque/Config/config.php
```

### 4/ Set the permissions
----------------------
```bash
# Check if the permissions are set correctly using the following commands:
sudo chown -R www:www $PATH_TO_MISP
sudo chmod -R 750 $PATH_TO_MISP
sudo chmod -R g+ws $PATH_TO_MISP/app/tmp
sudo chmod -R g+ws $PATH_TO_MISP/app/files
sudo chmod -R g+ws $PATH_TO_MISP/app/files/scripts/tmp
```

### 5/ Create a database and user
-----------------------------
```bash
# Enter the mysql shell
sudo mysql -u root -p
```

```
MariaDB [(none)]> create database misp;
MariaDB [(none)]> grant usage on *.* to misp@localhost identified by 'XXXXdbpasswordhereXXXXX';
MariaDB [(none)]> grant all privileges on misp.* to misp@localhost;
MariaDB [(none)]> flush privileges;
MariaDB [(none)]> exit
```

```bash
# Import the empty MISP database from MYSQL.sql
sudo -u www sh -c "mysql -u misp -pmisp < /var/www/htdocs/MISP/INSTALL/MYSQL.sql"
# enter the password you set previously
```

### 6/ Apache configuration
-----------------------
```bash
# Now configure your Apache webserver with the DocumentRoot /var/www/htdocs/MISP/app/webroot/

#2.4
sudo /usr/pkg/etc/httpd/sites-available /usr/pkg/etc/httpd/sites-enabled

# If the apache version is 2.4:
sudo cp $PATH_TO_MISP/INSTALL/apache.24.misp.ssl /usr/pkg/etc/httpd/sites-available/misp-ssl.conf

# Be aware that the configuration files for apache 2.4 and up have changed.
# The configuration file has to have the .conf extension in the sites-available directory
# For more information, visit http://httpd.apache.org/docs/2.4/upgrading.html

# If a valid SSL certificate is not already created for the server, create a self-signed certificate: (Make sure to fill the <…>)

sudo openssl req -newkey rsa:4096 -days 3650 -nodes -x509 \
-subj "/C=$OPENSSL_C/ST=$OPENSSL_ST/L=$OPENSSL_L/O=<$OPENSSL_O/OU=$OPENSSL_OU/CN=$OPENSSL_CN/emailAddress=$OPENSSL_EMAILADDRESS" \
-keyout /etc/ssl/private/server.key -out /etc/openssl/server.crt
# Otherwise, copy the SSLCertificateFile, SSLCertificateKeyFile, and SSLCertificateChainFile to /etc/openssl/private/. (Modify path and config to fit your environment)
```

```
============================================= Begin sample working SSL config for MISP
<VirtualHost <IP, FQDN, or *>:80>
        ServerName <your.FQDN.here>

        Redirect permanent / https://<your.FQDN.here>

        LogLevel warn
        ErrorLog /var/log/apache2/misp.local_error.log
        CustomLog /var/log/apache2/misp.local_access.log combined
        ServerSignature Off
</VirtualHost>

<VirtualHost <IP, FQDN, or *>:443>
        ServerAdmin admin@<your.FQDN.here>
        ServerName <your.FQDN.here>
        DocumentRoot /var/www/htdocs/MISP/app/webroot
        <Directory /var/www/htdocs/MISP/app/webroot>
                Options -Indexes
                AllowOverride all
                Order allow,deny
                allow from all
        </Directory>

        SSLEngine On
        SSLCertificateFile /etc/ssl/server.crt
        SSLCertificateKeyFile /etc/ssl/private/server.key
#        SSLCertificateChainFile /etc/ssl/private/misp-chain.crt

        LogLevel warn
        ErrorLog /var/log/apache2/misp.local_error.log
        CustomLog /var/log/apache2/misp.local_access.log combined
        ServerSignature Off
</VirtualHost>
============================================= End sample working SSL config for MISP
```

```bash
# activate new vhost
cd /etc/apache2/sites-enabled/
doas ln -s ../sites-available/misp-ssl.conf
echo "Include /etc/apache2/sites-enabled/*.conf" |doas tee -a /etc/apache2/httpd2.conf

doas vi /etc/apache2/httpd2.conf
```

```
/!\ Enable mod_rewrite in httpd2.conf /!\
LoadModule rewrite_module /usr/local/lib/apache2/mod_rewrite.so
LoadModule ssl_module /usr/local/lib/apache2/mod_ssl.so
LoadModule proxy_module /usr/local/lib/apache2/mod_proxy.so
LoadModule proxy_fcgi_module /usr/local/lib/apache2/mod_proxy_fcgi.so
Listen 443
DirectoryIndex index.php

# Disable mpm_event, enable mpm_prefork
/usr/pkg/etc/httpd/httpd.conf
LoadModule php7_module lib/httpd/mod_php7.so
SetHandler application/x-httpd-php
AddType application/x-httpd-php .php
DirectoryIndex index.html index.php
/usr/pkg/share/httpd/htdocs
```

```bash
doas ln -sf /var/www/conf/modules.sample/php-7.0.conf /var/www/conf/modules/php.conf
# Restart apache
doas /etc/rc.d/apache2 restart
``` 

### 7/ Log rotation (needs to be adapted to OpenBSD, newsyslog does this for you
---------------
!!! notice
    MISP saves the stdout and stderr of its workers in /var/www/htdocs/MISP/app/tmp/logs

### 8/ MISP configuration
---------------------
``` 
# There are 4 sample configuration files in $PATH_TO_MISP/app/Config that need to be copied
sudo -u www cp $PATH_TO_MISP/app/Config/bootstrap.default.php $PATH_TO_MISP/app/Config/bootstrap.php
sudo -u www cp $PATH_TO_MISP/app/Config/database.default.php $PATH_TO_MISP/app/Config/database.php
sudo -u www cp $PATH_TO_MISP/app/Config/core.default.php $PATH_TO_MISP/app/Config/core.php
sudo -u www cp $PATH_TO_MISP/app/Config/config.default.php $PATH_TO_MISP/app/Config/config.php

# Configure the fields in the newly created files:
sudo -u www vi $PATH_TO_MISP/app/Config/database.php
``` 
``` 
# DATABASE_CONFIG has to be filled
# With the default values provided in section 6, this would look like:
# class DATABASE_CONFIG {
#   public $default = array(
#       'datasource' => 'Database/Mysql',
#       'persistent' => false,
#       'host' => 'localhost',
#       'login' => 'misp', // grant usage on *.* to misp@localhost
#       'port' => 3306,
#       'password' => 'XXXXdbpasswordhereXXXXX', // identified by 'XXXXdbpasswordhereXXXXX';
#       'database' => 'misp', // create database misp;
#       'prefix' => '',
#       'encoding' => 'utf8',
#   );
#}
``` 

!!! danger
    Important! Change the salt key in /usr/local/www/MISP/app/Config/config.php
    The salt key must be a string at least 32 bytes long.
    The admin user account will be generated on the first login, make sure that the salt is changed before you create that user
    If you forget to do this step, and you are still dealing with a fresh installation, just alter the salt,
    delete the user from mysql and log in again using the default admin credentials (admin@admin.test / admin)

``` 
# Change base url in config.php
sudo -u www vi $PATH_TO_MISP/app/Config/config.php
# example: 'baseurl' => 'https://<your.FQDN.here>',
# alternatively, you can leave this field empty if you would like to use relative pathing in MISP
# 'baseurl' => '',

# and make sure the file permissions are still OK
sudo chown -R www:www $PATH_TO_MISP/app/Config
sudo chmod -R 750 $PATH_TO_MISP/app/Config

# Generate a GPG encryption key.
export GPG_REAL_NAME='Autogenerated Key'
export GPG_COMMENT='WARNING: MISP AutoGenerated Key consider this Key VOID!'
export GPG_EMAIL_ADDRESS='admin@admin.test'
export GPG_KEY_LENGTH='2048'
export GPG_PASSPHRASE='Password1234'
echo "%echo Generating a default key
    Key-Type: default
    Key-Length: $GPG_KEY_LENGTH
    Subkey-Type: default
    Name-Real: $GPG_REAL_NAME
    Name-Comment: $GPG_COMMENT
    Name-Email: $GPG_EMAIL_ADDRESS
    Expire-Date: 0
    Passphrase: $GPG_PASSPHRASE
    # Do a commit here, so that we can later print "done"
    %commit
%echo done" > /tmp/gen-key-script
sudo -u www mkdir $PATH_TO_MISP/.gnupg
sudo chmod 700 $PATH_TO_MISP/.gnupg
sudo gpg2 --homedir $PATH_TO_MISP/.gnupg --batch --gen-key /tmp/gen-key-script
# The email address should match the one set in the config.php / set in the configuration menu in the administration menu configuration file

# And export the public key to the webroot
sudo sh -c "gpg2 --homedir $PATH_TO_MISP/.gnupg --export --armor $GPG_EMAIL_ADDRESS > $PATH_TO_MISP/app/webroot/gpg.asc"

# To make the background workers start on boot
sudo chmod +x $PATH_TO_MISP/app/Console/worker/start.sh
sudo vi /etc/rc.local
# Add the following line before the last line (exit 0). Make sure that you replace www with your apache user:
sudo -u www bash $PATH_TO_MISP/app/Console/worker/start.sh
``` 

{!generic/INSTALL.done.md!}

{!generic/recommended.actions.md!}

#### MISP Modules
```
#/usr/pkgsrc/graphics/opencv2/ (needs X11)
sudo pkgin -y install jpeg yara
cd /usr/local/src/
git clone https://github.com/MISP/misp-modules.git
cd misp-modules
# pip3 install
sudo $PATH_TO_MISP/venv/bin/pip install -I -r REQUIREMENTS
sudo $PATH_TO_MISP/venv/bin/pip install -I .
sudo $PATH_TO_MISP/venv/bin/pip install git+https://github.com/VirusTotal/yara-python.git
sudo $PATH_TO_MISP/venv/bin/pip install wand
##doas gem install pygments.rb
##doas gem install asciidoctor-pdf --pre
sudo -u www $PATH_TO_MISP/venv/bin/misp-modules -l 0.0.0.0 -s &
echo "sudo -u www $PATH_TO_MISP/venv/bin/misp-modules -l 0.0.0.0 -s &" |doas tee -a /etc/rc.local
```

!!! notice
    Make sure that the STIX libraries and GnuPG work as intended, if not, refer to INSTALL.txt's paragraphs dealing with these two items

!!! notice
    If anything goes wrong, make sure that you check MISP's logs for errors:
    /var/www/htdocs/MISP/app/tmp/logs/error.log
    /var/www/htdocs/MISP/app/tmp/logs/resque-worker-error.log
    /var/www/htdocs/MISP/app/tmp/logs/resque-scheduler-error.log
    /var/www/htdocs/MISP/app/tmp/logs/resque-2015-01-01.log // where the actual date is the current date


#### MISP Config Automation

```bash
sudo -u www $CAKE Live $MISP_LIVE
AUTH_KEY=$(mysql -u misp -p misp -e "SELECT authkey FROM users;" | tail -1)
# Update the galaxies…
sudo -u www $CAKE Admin updateGalaxies

# Updating the taxonomies…
sudo -u www $CAKE Admin updateTaxonomies

# Updating the warning lists…
sudo -u www $CAKE Admin updateWarningLists

# Updating the notice lists…
sudo -u www $CAKE Admin updateNoticeLists

# Updating the object templates…
sudo -u www $CAKE Admin updateObjectTemplates 1337

# Tune global time outs
sudo -u www $CAKE Admin setSetting "Session.autoRegenerate" 0
sudo -u www $CAKE Admin setSetting "Session.timeout" 600
sudo -u www $CAKE Admin setSetting "Session.cookie_timeout" 3600

# Enable GnuPG
sudo -u www $CAKE Admin setSetting "GnuPG.email" "admin@admin.test"
sudo -u www $CAKE Admin setSetting "GnuPG.homedir" "$PATH_TO_MISP/.gnupg"
sudo -u www $CAKE Admin setSetting "GnuPG.password" "Password1234"

# Enable Enrichment set better timeouts
sudo -u www $CAKE Admin setSetting "Plugin.Enrichment_services_enable" true
sudo -u www $CAKE Admin setSetting "Plugin.Enrichment_hover_enable" true
sudo -u www $CAKE Admin setSetting "Plugin.Enrichment_timeout" 300
sudo -u www $CAKE Admin setSetting "Plugin.Enrichment_hover_timeout" 150
sudo -u www $CAKE Admin setSetting "Plugin.Enrichment_cve_enabled" true
sudo -u www $CAKE Admin setSetting "Plugin.Enrichment_dns_enabled" true
sudo -u www $CAKE Admin setSetting "Plugin.Enrichment_services_url" "http://127.0.0.1"
sudo -u www $CAKE Admin setSetting "Plugin.Enrichment_services_port" 6666

# Enable Import modules set better timout
sudo -u www $CAKE Admin setSetting "Plugin.Import_services_enable" true
sudo -u www $CAKE Admin setSetting "Plugin.Import_services_url" "http://127.0.0.1"
sudo -u www $CAKE Admin setSetting "Plugin.Import_services_port" 6666
sudo -u www $CAKE Admin setSetting "Plugin.Import_timeout" 300
sudo -u www $CAKE Admin setSetting "Plugin.Import_ocr_enabled" true
sudo -u www $CAKE Admin setSetting "Plugin.Import_csvimport_enabled" true

# Enable Export modules set better timout
sudo -u www $CAKE Admin setSetting "Plugin.Export_services_enable" true
sudo -u www $CAKE Admin setSetting "Plugin.Export_services_url" "http://127.0.0.1"
sudo -u www $CAKE Admin setSetting "Plugin.Export_services_port" 6666
sudo -u www $CAKE Admin setSetting "Plugin.Export_timeout" 300
sudo -u www $CAKE Admin setSetting "Plugin.Export_pdfexport_enabled" true

# Enable installer org and tune some configurables
sudo -u www $CAKE Admin setSetting "MISP.host_org_id" 1
sudo -u www $CAKE Admin setSetting "MISP.email" "info@admin.test"
sudo -u www $CAKE Admin setSetting "MISP.disable_emailing" true
sudo -u www $CAKE Admin setSetting "MISP.contact" "info@admin.test"
sudo -u www $CAKE Admin setSetting "MISP.disablerestalert" true
sudo -u www $CAKE Admin setSetting "MISP.showCorrelationsOnIndex" true

# Provisional Cortex tunes
sudo -u www $CAKE Admin setSetting "Plugin.Cortex_services_enable" false
sudo -u www $CAKE Admin setSetting "Plugin.Cortex_services_url" "http://127.0.0.1"
sudo -u www $CAKE Admin setSetting "Plugin.Cortex_services_port" 9000
sudo -u www $CAKE Admin setSetting "Plugin.Cortex_timeout" 120
sudo -u www $CAKE Admin setSetting "Plugin.Cortex_services_url" "http://127.0.0.1"
sudo -u www $CAKE Admin setSetting "Plugin.Cortex_services_port" 9000
sudo -u www $CAKE Admin setSetting "Plugin.Cortex_services_timeout" 120
sudo -u www $CAKE Admin setSetting "Plugin.Cortex_services_authkey" ""
sudo -u www $CAKE Admin setSetting "Plugin.Cortex_ssl_verify_peer" false
sudo -u www $CAKE Admin setSetting "Plugin.Cortex_ssl_verify_host" false
sudo -u www $CAKE Admin setSetting "Plugin.Cortex_ssl_allow_self_signed" true

# Various plugin sightings settings
sudo -u www $CAKE Admin setSetting "Plugin.Sightings_policy" 0
sudo -u www $CAKE Admin setSetting "Plugin.Sightings_anonymise" false
sudo -u www $CAKE Admin setSetting "Plugin.Sightings_range" 365

# Plugin CustomAuth tuneable
sudo -u www $CAKE Admin setSetting "Plugin.CustomAuth_disable_logout" false

# RPZ Plugin settings

sudo -u www $CAKE Admin setSetting "Plugin.RPZ_policy" "DROP"
sudo -u www $CAKE Admin setSetting "Plugin.RPZ_walled_garden" "127.0.0.1"
sudo -u www $CAKE Admin setSetting "Plugin.RPZ_serial" "\$date00"
sudo -u www $CAKE Admin setSetting "Plugin.RPZ_refresh" "2h"
sudo -u www $CAKE Admin setSetting "Plugin.RPZ_retry" "30m"
sudo -u www $CAKE Admin setSetting "Plugin.RPZ_expiry" "30d"
sudo -u www $CAKE Admin setSetting "Plugin.RPZ_minimum_ttl" "1h"
sudo -u www $CAKE Admin setSetting "Plugin.RPZ_ttl" "1w"
sudo -u www $CAKE Admin setSetting "Plugin.RPZ_ns" "localhost."
sudo -u www $CAKE Admin setSetting "Plugin.RPZ_ns_alt" ""
sudo -u www $CAKE Admin setSetting "Plugin.RPZ_email" "root.localhost"

# Force defaults to make MISP Server Settings less RED
sudo -u www $CAKE Admin setSetting "MISP.language" "eng"
sudo -u www $CAKE Admin setSetting "MISP.proposals_block_attributes" false

## Redis block
sudo -u www $CAKE Admin setSetting "MISP.redis_host" "127.0.0.1"
sudo -u www $CAKE Admin setSetting "MISP.redis_port" 6379
sudo -u www $CAKE Admin setSetting "MISP.redis_database" 13
sudo -u www $CAKE Admin setSetting "MISP.redis_password" ""

# Force defaults to make MISP Server Settings less YELLOW
sudo -u www $CAKE Admin setSetting "MISP.ssdeep_correlation_threshold" 40
sudo -u www $CAKE Admin setSetting "MISP.extended_alert_subject" false
sudo -u www $CAKE Admin setSetting "MISP.default_event_threat_level" 4
sudo -u www $CAKE Admin setSetting "MISP.newUserText" "Dear new MISP user,\\n\\nWe would hereby like to welcome you to the \$org MISP community.\\n\\n Use the credentials below to log into MISP at \$misp, where you will be prompted to manually change your password to something of your own choice.\\n\\nUsername: \$username\\nPassword: \$password\\n\\nIf you have any questions, don't hesitate to contact us at: \$contact.\\n\\nBest regards,\\nYour \$org MISP support team"
sudo -u www $CAKE Admin setSetting "MISP.passwordResetText" "Dear MISP user,\\n\\nA password reset has been triggered for your account. Use the below provided temporary password to log into MISP at \$misp, where you will be prompted to manually change your password to something of your own choice.\\n\\nUsername: \$username\\nYour temporary password: \$password\\n\\nIf you have any questions, don't hesitate to contact us at: \$contact.\\n\\nBest regards,\\nYour \$org MISP support team"
sudo -u www $CAKE Admin setSetting "MISP.enableEventBlacklisting" true
sudo -u www $CAKE Admin setSetting "MISP.enableOrgBlacklisting" true
sudo -u www $CAKE Admin setSetting "MISP.log_client_ip" false
sudo -u www $CAKE Admin setSetting "MISP.log_auth" false
sudo -u www $CAKE Admin setSetting "MISP.disableUserSelfManagement" false
sudo -u www $CAKE Admin setSetting "MISP.block_event_alert" false
sudo -u www $CAKE Admin setSetting "MISP.block_event_alert_tag" "no-alerts=\"true\""
sudo -u www $CAKE Admin setSetting "MISP.block_old_event_alert" false
sudo -u www $CAKE Admin setSetting "MISP.block_old_event_alert_age" ""
sudo -u www $CAKE Admin setSetting "MISP.incoming_tags_disabled_by_default" false
sudo -u www $CAKE Admin setSetting "MISP.footermidleft" "This is an initial install"
sudo -u www $CAKE Admin setSetting "MISP.footermidright" "Please configure and harden accordingly"
sudo -u www $CAKE Admin setSetting "MISP.welcome_text_top" "Initial Install, please configure"
sudo -u www $CAKE Admin setSetting "MISP.welcome_text_bottom" "Welcome to MISP, change this message in MISP Settings"

# Force defaults to make MISP Server Settings less GREEN
sudo -u www $CAKE Admin setSetting "Security.password_policy_length" 12
sudo -u www $CAKE Admin setSetting "Security.password_policy_complexity" '/^((?=.*\d)|(?=.*\W+))(?![\n])(?=.*[A-Z])(?=.*[a-z]).*$|.{16,}/'
# Tune global time outs
sudo -u www $CAKE Admin setSetting "Session.autoRegenerate" 0
sudo -u www $CAKE Admin setSetting "Session.timeout" 600
sudo -u www $CAKE Admin setSetting "Session.cookie_timeout" 3600
```

### Recommended actions
-------------------
- By default CakePHP exposes its name and version in email headers. Apply a patch to remove this behavior.

- You should really harden your OS
- You should really harden the configuration of Apache/httpd
- You should really harden the configuration of MySQL/MariaDB
- Keep your software up2date (OS, MISP, CakePHP and everything else)
- Log and audit


### Optional features
-------------------

!!! notice
    MISP has a pub/sub feature, using ZeroMQ.

#### ZeroMQ depends on the Python client for Redis
```bash
sudo pkgin -y install zeromq
sudo -u www HOME=/tmp $PATH_TO_MISP/venv/bin/pip install pyzmq
```

#### misp-dashboard 

!!! notice
    Enable ZeroMQ for misp-dashboard

!!! warning
    This still needs more testing, it runs but no data is showing.


!!! warning
    The install_dependencies.sh script is for Linux ONLY. The following blurp will be a diff of a working OpenBSD version.

```diff
(DASHENV) obsd# diff -u install_dependencies.sh install_dependencies_obsd.sh  
--- install_dependencies.sh     Fri Oct 19 12:14:38 2018
+++ install_dependencies_obsd.sh        Fri Oct 19 12:43:22 2018
@@ -1,14 +1,14 @@
-#!/bin/bash
+#!/usr/local/bin/bash
 
 set -e
 #set -x
 
-sudo apt-get install python3-virtualenv virtualenv screen redis-server unzip -y
+doas pkg_add -v unzip wget
 
 if [ -z "$VIRTUAL_ENV" ]; then
-    virtualenv -p python3 DASHENV
+    virtualenv -p python3 /usr/local/virtualenvs/DASHENV
 
-    . ./DASHENV/bin/activate
+    . /usr/local/virtualenvs/DASHENV/bin/activate
 fi
 
 pip3 install -U pip argparse redis zmq geoip2 flask phonenumbers pycountry
```

```
cd /var/www
doas mkdir misp-dashboard
doas chown www:www misp-dashboard
doas -u www git clone https://github.com/MISP/misp-dashboard.git
cd misp-dashboard
#/!\ Made on Linux, the next script will fail
#doas /var/www/misp-dashboard/install_dependencies.sh
doas virtualenv -ppython3 /usr/local/virtualenvs/DASHENV
doas /usr/local/virtualenvs/DASHENV/bin/pip install -U pip argparse redis zmq geoip2 flask phonenumbers pycountry

doas sed -i "s/^host\ =\ localhost/host\ =\ 0.0.0.0/g" /var/www/misp-dashboard/config/config.cfg
doas sed -i -e '$i \doas -u www bash /var/www/misp-dashboard/start_all.sh\n' /etc/rc.local
#/!\ Add port 8001 as a listener
#doas sed -i '/Listen 80/a Listen 0.0.0.0:8001' /etc/apache2/ports.conf
doas pkg_add -v ap2-mod_wsgi

echo "<VirtualHost *:8001>
    ServerAdmin admin@misp.local
    ServerName misp.local
    DocumentRoot /var/www/misp-dashboard
    
    WSGIDaemonProcess misp-dashboard \
       user=misp group=misp \
       python-home=/var/www/misp-dashboard/DASHENV \
       processes=1 \
       threads=15 \
       maximum-requests=5000 \
       listen-backlog=100 \
       queue-timeout=45 \
       socket-timeout=60 \
       connect-timeout=15 \
       request-timeout=60 \
       inactivity-timeout=0 \
       deadlock-timeout=60 \
       graceful-timeout=15 \
       eviction-timeout=0 \
       shutdown-timeout=5 \
       send-buffer-size=0 \
       receive-buffer-size=0 \
       header-buffer-size=0 \
       response-buffer-size=0 \
       server-metrics=Off
    WSGIScriptAlias / /var/www/misp-dashboard/misp-dashboard.wsgi
    <Directory /var/www/misp-dashboard>
        WSGIProcessGroup misp-dashboard
        WSGIApplicationGroup %{GLOBAL}
        Require all granted
    </Directory>
    LogLevel info
    ErrorLog /var/log/apache2/misp-dashboard.local_error.log
    CustomLog /var/log/apache2/misp-dashboard.local_access.log combined
    ServerSignature Off
</VirtualHost>" | doas tee /etc/apache2/sites-available/misp-dashboard.conf

doas ln -s /etc/apache2/sites-available/misp-dashboard.conf /etc/apache2/sites-enabled/misp-dashboard.conf
```

Add this to /etc/httpd2.conf
```
LoadModule wsgi_module /usr/local/lib/apache2/mod_wsgi.so
Listen 8001
```


```
sudo -u www $CAKE Admin setSetting "Plugin.ZeroMQ_enable" true
sudo -u www $CAKE Admin setSetting "Plugin.ZeroMQ_event_notifications_enable" true
sudo -u www $CAKE Admin setSetting "Plugin.ZeroMQ_object_notifications_enable" true
sudo -u www $CAKE Admin setSetting "Plugin.ZeroMQ_object_reference_notifications_enable" true
sudo -u www $CAKE Admin setSetting "Plugin.ZeroMQ_attribute_notifications_enable" true
sudo -u www $CAKE Admin setSetting "Plugin.ZeroMQ_sighting_notifications_enable" true
sudo -u www $CAKE Admin setSetting "Plugin.ZeroMQ_user_notifications_enable" true
sudo -u www $CAKE Admin setSetting "Plugin.ZeroMQ_organisation_notifications_enable" true
sudo -u www $CAKE Admin setSetting "Plugin.ZeroMQ_port" 50000
sudo -u www $CAKE Admin setSetting "Plugin.ZeroMQ_redis_host" "localhost"
sudo -u www $CAKE Admin setSetting "Plugin.ZeroMQ_redis_port" 6379
sudo -u www $CAKE Admin setSetting "Plugin.ZeroMQ_redis_database" 1
sudo -u www $CAKE Admin setSetting "Plugin.ZeroMQ_redis_namespace" "mispq"
sudo -u www $CAKE Admin setSetting "Plugin.ZeroMQ_include_attachments" false
sudo -u www $CAKE Admin setSetting "Plugin.ZeroMQ_tag_notifications_enable" false
sudo -u www $CAKE Admin setSetting "Plugin.ZeroMQ_audit_notifications_enable" false
```

{!generic/hardening.md!}
