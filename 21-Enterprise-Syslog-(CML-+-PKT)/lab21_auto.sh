#!/bin/bash

# --- STYLING ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}   LAB 21: AUTOMATED SYSLOG & MARIADB HARDENING     ${NC}"
echo -e "${BLUE}====================================================${NC}"

# 1. DATABASE PRE-CONFIGURATION (SKIPPING BLUE SCREENS)
echo -e "\n${GREEN}[1/5] Pre-configuring MariaDB & Rsyslog-MySQL...${NC}"
# Pre-set the database password so the installer doesn't ask manually
sudo debconf-set-selections <<< 'rsyslog-mysql rsyslog-mysql/dbconfig-install boolean true'
sudo debconf-set-selections <<< 'rsyslog-mysql rsyslog-mysql/mysql/admin-pass password 123456'
sudo debconf-set-selections <<< 'rsyslog-mysql rsyslog-mysql/mysql/app-pass password 123456'
sudo debconf-set-selections <<< 'rsyslog-mysql rsyslog-mysql/app-password-confirm password 123456'

# 2. INSTALLING CORE SERVICES
echo -e "${GREEN}[2/5] Installing Apache2, MariaDB, and PHP...${NC}"
sudo apt update -y
sudo apt install apache2 mariadb-server php libapache2-mod-php php-mysql -y

# Force Enable and Start MariaDB BEFORE installing the MySQL connector
sudo systemctl enable mariadb
sudo systemctl start mariadb

echo -e "${GREEN}[3/5] Installing Rsyslog-MySQL (Non-Interactive)...${NC}"
sudo DEBIAN_FRONTEND=noninteractive apt install rsyslog-mysql -y

# Fix any broken dependencies if they occurred
sudo apt install -f -y

# 3. WAITING FOR DATABASE STABILITY
echo -n "Waiting for MariaDB to stabilize"
until sudo mysqladmin ping >/dev/null 2>&1; do
    echo -n "."
    sleep 1
done
echo -e "\n${BLUE}MariaDB is ACTIVE.${NC}"

# 4. APPLYING THE "GOLDEN" SQL PATCH
echo -e "${GREEN}[4/5] Applying SQL Schema Hardening...${NC}"
sudo mysql -e "USE Syslog; 
ALTER TABLE SystemEvents CHANGE NTSeverity ntseverity int, CHANGE Importance importance int, CHANGE EventSource eventsource varchar(60), CHANGE EventCategory eventcategory int, CHANGE EventLogType eventlogtype varchar(60);
ALTER TABLE SystemEvents ADD COLUMN processid varchar(60) DEFAULT '' AFTER SysLogTag, ADD COLUMN messagetype varchar(60) DEFAULT '' AFTER processid, ADD COLUMN fromip varchar(60) DEFAULT '' AFTER Message, ADD COLUMN eventid int DEFAULT 0 AFTER messagetype, ADD COLUMN checksum int DEFAULT 0;
UPDATE SystemEvents SET FromHost = '10.0.99.1' WHERE FromHost = '_gateway';"

# 5. DEPLOYING LOGANALYZER WEB UI
echo -e "${GREEN}[5/5] Deploying LogAnalyzer 4.1.13...${NC}"
cd /var/www/html/
sudo wget -q https://download.adiscon.com/loganalyzer/loganalyzer-4.1.13.tar.gz
sudo tar -xzf loganalyzer-4.1.13.tar.gz
sudo mv loganalyzer-4.1.13/src syslog
sudo touch syslog/config.php
sudo chmod 666 syslog/config.php
sudo chown -R www-data:www-data syslog
sudo rm -rf loganalyzer-4.1.13*

# FINAL HARDENING
sudo sed -i '1i global(net.enableDNS="off")' /etc/rsyslog.conf
sudo systemctl restart rsyslog apache2

echo -e "\n${BLUE}====================================================${NC}"
echo -e "${GREEN}✅ SUCCESS: LAB 21 DEPLOYED IN ONE NOTE!${NC}"
echo -e "🔗 URL: http://$(hostname -I | awk '{print $1}')/syslog"
echo -e "⚠️ Remember: Complete the Web UI setup, then run 'sudo chmod 444 /var/www/html/syslog/config.php'"
echo -e "${BLUE}====================================================${NC}"
