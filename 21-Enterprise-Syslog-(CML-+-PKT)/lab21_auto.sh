#!/bin/bash

# --- STYLING ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'
DB_PASS="123456"

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}   LAB 21: THE FINAL BOSS - GOD MODE AUTOMATION     ${NC}"
echo -e "${BLUE}====================================================${NC}"

# 1. PRE-CONFIGURATION
echo -e "\n${GREEN}[1/7] Seeding Database Credentials...${NC}"
sudo debconf-set-selections <<< "rsyslog-mysql rsyslog-mysql/dbconfig-install boolean true"
sudo debconf-set-selections <<< "rsyslog-mysql rsyslog-mysql/mysql/admin-pass password $DB_PASS"
sudo debconf-set-selections <<< "rsyslog-mysql rsyslog-mysql/mysql/app-pass password $DB_PASS"
sudo debconf-set-selections <<< "rsyslog-mysql rsyslog-mysql/app-password-confirm password $DB_PASS"

# 2. INSTALL CORE PACKAGES
echo -e "${GREEN}[2/7] Installing Apache, MariaDB, PHP...${NC}"
sudo apt update -y && sudo apt install apache2 mariadb-server php libapache2-mod-php php-mysql php-xml -y
sudo systemctl enable --now mariadb

# 3. RSYSLOG-MYSQL & FORCE START
sudo DEBIAN_FRONTEND=noninteractive apt install rsyslog-mysql -y
sudo systemctl restart mariadb

# 4. DATABASE & SQL PATCHING (Vá triệt để các cột)
echo -e "${GREEN}[4/7] Fixing Database User & Applying SQL Patch...${NC}"
sudo mysql -u root <<EOF
CREATE USER IF NOT EXISTS 'rsyslog'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON Syslog.* TO 'rsyslog'@'localhost';
FLUSH PRIVILEGES;
USE Syslog;
-- Fix columns
ALTER TABLE SystemEvents CHANGE NTSeverity ntseverity int, CHANGE Importance importance int, CHANGE EventSource eventsource varchar(60), CHANGE EventCategory eventcategory int, CHANGE EventLogType eventlogtype varchar(60);
-- Add columns if not exists
ALTER TABLE SystemEvents ADD COLUMN processid varchar(60) DEFAULT '' AFTER SysLogTag;
ALTER TABLE SystemEvents ADD COLUMN messagetype varchar(60) DEFAULT '' AFTER processid;
ALTER TABLE SystemEvents ADD COLUMN fromip varchar(60) DEFAULT '' AFTER Message;
ALTER TABLE SystemEvents ADD COLUMN checksum int DEFAULT 0;
-- THE CLEANUP: Force change any old 'ciscoserver' to IP
UPDATE SystemEvents SET FromHost = '127.0.0.1' WHERE FromHost LIKE '%cisco%';
EOF

# 5. THE SILVER BULLET: RSYSLOG TEMPLATE (Ép dùng IP)
echo -e "${GREEN}[5/7] Configuring Rsyslog Template (Force IP over Hostname)...${NC}"
sudo bash -c "cat > /etc/rsyslog.d/mysql.conf << EOF
# Load the MySQL module
module(load=\"ommysql\")

# Define a template to force IP address instead of Hostname
template(name=\"InsertIP\" type=\"list\") {
    constant(value=\"insert into SystemEvents (Message, Facility, FromHost, Priority, DeviceReportedTime, ReceivedAt, InfoUnitID, SysLogTag) values ('\")
    property(name=\"msg\")
    constant(value=\"', \")
    property(name=\"syslogfacility\")
    constant(value=\", '\")
    property(name=\"fromhost-ip\")
    constant(value=\"', \")
    property(name=\"syslogpriority\")
    constant(value=\", '\")
    property(name=\"timereported\" dateFormat=\"mysql\")
    constant(value=\"', '\")
    property(name=\"timegenerated\" dateFormat=\"mysql\")
    constant(value=\"', \")
    property(name=\"iut\")
    constant(value=\", '\")
    property(name=\"syslogtag\")
    constant(value=\"')\")
}

# Apply the template to force TCP 127.0.0.1 (No Socket 13 error)
*.* :ommysql:127.0.0.1,Syslog,rsyslog,$DB_PASS;InsertIP
EOF"

# Enable UDP and Disable DNS in main config
sudo sed -i '/module(load="imudp")/s/^#//g' /etc/rsyslog.conf
sudo sed -i '/input(type="imudp" port="514")/s/^#//g' /etc/rsyslog.conf
sudo sed -i '1i global(net.enableDNS="off")' /etc/rsyslog.conf

# 6. LOGANALYZER DEPLOYMENT
echo -e "${GREEN}[6/7] Deploying LogAnalyzer Web...${NC}"
cd /var/www/html/
sudo wget -q https://download.adiscon.com/loganalyzer/loganalyzer-4.1.13.tar.gz
sudo tar -xzf loganalyzer-4.1.13.tar.gz
sudo mv loganalyzer-4.1.13/src syslog
sudo touch syslog/config.php
sudo chmod 666 syslog/config.php
sudo chown -R www-data:www-data syslog
sudo rm -rf loganalyzer-4.1.13*

# 7. RESTART & FINAL TEST
sudo systemctl restart rsyslog apache2
logger "FINAL TEST: This should appear as an IP, not ciscoserver!"

echo -e "\n${BLUE}====================================================${NC}"
echo -e "${GREEN}✅ SCRIPT FINISHED!${NC}"
echo -e "🔗 URL: http://$(hostname -I | awk '{print $1}')/syslog"
echo -e "⚠️  IMPORTANT: After finishing the 7 Web Steps, run this to STOP LOADING HANG:"
echo -e "${RED}sudo sed -i \"/EnableIPAddressResolve/c\\\$CFG['EnableIPAddressResolve'] = false;\" /var/www/html/syslog/config.php${NC}"
echo -e "${BLUE}====================================================${NC}"
