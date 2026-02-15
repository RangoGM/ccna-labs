#!/bin/bash

# --- COLORS FOR FANCY OUTPUT ---
GREEN='\033[0-32m'
BLUE='\033[0-34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Lab 21 Enterprise Syslog Automation...${NC}"

# Function to show progress bar
progress_bar() {
    local duration=$1
    local sleep_interval=0.1
    local progress=0
    while [ $progress -lt 100 ]; do
        echo -ne "  [$(printf '%-50s' $(printf '#%.0s' $(seq 1 $((progress / 2)))))] $progress%\r"
        sleep $sleep_interval
        progress=$((progress + 2))
    done
    echo -e "  [##################################################] 100% - Done!"
}

# 1. Installing Core Services
echo -e "\n${GREEN}1/4 Installing Apache2, MariaDB, PHP, Rsyslog-MySQL...${NC}"
sudo apt update -y && sudo apt install apache2 mariadb-server php libapache2-mod-php php-mysql rsyslog-mysql wget -y > /dev/null 2>&1
progress_bar 2

# 2. Deploying LogAnalyzer Web UI
echo -e "\n${GREEN}2/4 Fetching and Setting up LogAnalyzer 4.1.13...${NC}"
cd /var/www/html/
sudo wget -q https://download.adiscon.com/loganalyzer/loganalyzer-4.1.13.tar.gz
sudo tar -xzf loganalyzer-4.1.13.tar.gz
sudo mv loganalyzer-4.1.13/src syslog
sudo touch syslog/config.php
sudo chmod 666 syslog/config.php
sudo chown -R www-data:www-data syslog
sudo rm -rf loganalyzer-4.1.13*
progress_bar 2

# 3. Applying "The Golden SQL Patch" (Hardening)
echo -e "\n${GREEN}3/4 Patching Database Schema & Case Sensitivity...${NC}"
# Use the SQL logic you've built
sudo mysql -e "USE Syslog; 
ALTER TABLE SystemEvents CHANGE NTSeverity ntseverity int, CHANGE Importance importance int, CHANGE EventSource eventsource varchar(60), CHANGE EventCategory eventcategory int, CHANGE EventLogType eventlogtype varchar(60);
ALTER TABLE SystemEvents ADD COLUMN processid varchar(60) DEFAULT '' AFTER SysLogTag, ADD COLUMN messagetype varchar(60) DEFAULT '' AFTER processid, ADD COLUMN fromip varchar(60) DEFAULT '' AFTER Message, ADD COLUMN eventid int DEFAULT 0 AFTER messagetype, ADD COLUMN checksum int DEFAULT 0;
UPDATE SystemEvents SET FromHost = '10.0.99.1' WHERE FromHost = '_gateway';"
progress_bar 2

# 4. Global Hardening (DNS & Permissions)
echo -e "\n${GREEN}4/4 Final Hardening (DNS Suppress & Service Restart)...${NC}"
sudo sed -i '1i global(net.enableDNS="off")' /etc/rsyslog.conf
sudo systemctl restart rsyslog mariadb apache2
progress_bar 1

echo -e "\n${BLUE}✨ BÚUUUUUU! EVERYTHING IS READY!${NC}"
echo -e "🔗 Access your dashboard at: http://localhost/syslog"
echo -e "⚠️ Remember: Complete the Web UI setup, then run 'sudo chmod 444 /var/www/html/syslog/config.php'"
