#!/bin/bash

# --- COLORS & VARIABLES ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'
DB_PASS="123456" 

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}    LAB 21: THE ULTIMATE SYSLOG AUTOMATION (ENG)    ${NC}"
echo -e "${BLUE}====================================================${NC}"

# 1. PRE-CONFIGURATION (Avoid blue screen prompts)
echo -e "\n${GREEN}[1/7] Pre-seeding Debconf settings...${NC}"
sudo debconf-set-selections <<< "rsyslog-mysql rsyslog-mysql/dbconfig-install boolean true"
sudo debconf-set-selections <<< "rsyslog-mysql rsyslog-mysql/mysql/admin-pass password $DB_PASS"
sudo debconf-set-selections <<< "rsyslog-mysql rsyslog-mysql/mysql/app-pass password $DB_PASS"
sudo debconf-set-selections <<< "rsyslog-mysql rsyslog-mysql/app-password-confirm password $DB_PASS"

# 2. INSTALL CORE SERVICES
echo -e "${GREEN}[2/7] Installing Apache2, MariaDB, and PHP...${NC}"
sudo apt update -y
sudo apt install apache2 mariadb-server php libapache2-mod-php php-mysql php-xml -y
sudo systemctl enable --now mariadb

# Wait for MariaDB to start properly
echo -n "Waiting for Database to stabilize..."
until sudo mysqladmin ping >/dev/null 2>&1; do
    echo -n "."
    sleep 1
done
echo "OK!"

# Install Rsyslog-MySQL (Non-Interactive)
sudo DEBIAN_FRONTEND=noninteractive apt install rsyslog-mysql -y

# 3. CONFIGURE DATABASE PERMISSIONS
echo -e "${GREEN}[3/7] Setting up Database User...${NC}"
sudo mysql -u root <<EOF
CREATE USER IF NOT EXISTS 'rsyslog'@'localhost' IDENTIFIED BY '$DB_PASS';
ALTER USER 'rsyslog'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON Syslog.* TO 'rsyslog'@'localhost';
FLUSH PRIVILEGES;
EOF

# 4. APPLY SQL PATCHES & HOSTNAME FIX
echo -e "${GREEN}[4/7] Patching SQL Schema & Cleaning Hostnames...${NC}"
# Update existing columns (Silencing errors if already exists)
sudo mysql -u root -D Syslog -e "ALTER TABLE SystemEvents CHANGE NTSeverity ntseverity int;" 2>/dev/null
sudo mysql -u root -D Syslog -e "ALTER TABLE SystemEvents CHANGE Importance importance int;" 2>/dev/null
sudo mysql -u root -D Syslog -e "ALTER TABLE SystemEvents CHANGE EventSource eventsource varchar(60);" 2>/dev/null
sudo mysql -u root -D Syslog -e "ALTER TABLE SystemEvents CHANGE EventCategory eventcategory int;" 2>/dev/null
sudo mysql -u root -D Syslog -e "ALTER TABLE SystemEvents CHANGE EventLogType eventlogtype varchar(60);" 2>/dev/null

# Add new columns
sudo mysql -u root -D Syslog -e "ALTER TABLE SystemEvents ADD COLUMN processid varchar(60) DEFAULT '' AFTER SysLogTag;" 2>/dev/null
sudo mysql -u root -D Syslog -e "ALTER TABLE SystemEvents ADD COLUMN messagetype varchar(60) DEFAULT '' AFTER processid;" 2>/dev/null
sudo mysql -u root -D Syslog -e "ALTER TABLE SystemEvents ADD COLUMN fromip varchar(60) DEFAULT '' AFTER Message;" 2>/dev/null
sudo mysql -u root -D Syslog -e "ALTER TABLE SystemEvents ADD COLUMN checksum int DEFAULT 0;" 2>/dev/null

# FIX: Change 'ciscoserver' hostnames to 127.0.0.1 to prevent DNS hang
sudo mysql -u root -D Syslog -e "UPDATE SystemEvents SET FromHost = '127.0.0.1' WHERE FromHost = 'ciscoserver';" 2>/dev/null

# 5. CONFIGURE RSYSLOG (Fix Socket 13 & UDP 514)
echo -e "${GREEN}[5/7] Configuring Rsyslog Pipeline...${NC}"
sudo bash -c "cat > /etc/rsyslog.d/mysql.conf << EOF
module(load=\"ommysql\")
*.* :ommysql:127.0.0.1,Syslog,rsyslog,$DB_PASS
EOF"

sudo sed -i '/module(load="imudp")/s/^#//g' /etc/rsyslog.conf
sudo sed -i '/input(type="imudp" port="514")/s/^#//g' /etc/rsyslog.conf
sudo sed -i '1i global(net.enableDNS="off")' /etc/rsyslog.conf

# 6. DEPLOY LOGANALYZER
echo -e "${GREEN}[6/7] Extracting LogAnalyzer Files...${NC}"
cd /var/www/html/
sudo wget -q https://download.adiscon.com/loganalyzer/loganalyzer-4.1.13.tar.gz
sudo tar -xzf loganalyzer-4.1.13.tar.gz
sudo mv loganalyzer-4.1.13/src syslog
sudo touch syslog/config.php
sudo chmod 666 syslog/config.php
sudo chown -R www-data:www-data syslog
sudo rm -rf loganalyzer-4.1.13*

# 7. RESTART SERVICES
echo -e "${GREEN}[7/7] Restarting Services...${NC}"
sudo systemctl restart rsyslog apache2

# Send Initial Test Log
logger "DEPLOYMENT SUCCESSFUL - SYSTEM IS LIVE"

echo -e "\n${BLUE}====================================================${NC}"
echo -e "${GREEN}✅ MISSION ACCOMPLISHED!${NC}"
echo -e "👉 Access URL: http://$(hostname -I | awk '{print $1}')/syslog"
echo -e "👉 Step 7 DB Info: User: ${RED}rsyslog${NC} | Pass: ${RED}$DB_PASS${NC} | Name: ${RED}Syslog${NC}"
echo -e "\n${YELLOW}⚠️  IMPORTANT: AFTER YOU FINISH THE WEB SETUP (STEP 7),${NC}"
echo -e "${YELLOW}   RUN THESE TWO COMMANDS TO FIX THE LOADING HANG:${NC}"
echo -e "${RED}sudo sed -i \"s/EnableIPAddressResolve'] = true/EnableIPAddressResolve'] = false/g\" /var/www/html/syslog/config.php${NC}"
echo -e "${RED}sudo sed -i \"s/ViewDNSNames'] = true/ViewDNSNames'] = false/g\" /var/www/html/syslog/config.php${NC}"
echo -e "${BLUE}====================================================${NC}"
