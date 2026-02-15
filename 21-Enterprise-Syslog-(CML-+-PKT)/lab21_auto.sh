#!/bin/bash
# --- COLORS ---
GREEN='\033[0;32m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
DB_PASS="123456"

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}   LAB 21: IMMORTAL SYSLOG SCRIPT (NO MORE ERRORS)  ${NC}"
echo -e "${BLUE}====================================================${NC}"

# 1. PRE-CONFIG (Bypass blue screens)
sudo debconf-set-selections <<< "rsyslog-mysql rsyslog-mysql/dbconfig-install boolean true"
sudo debconf-set-selections <<< "rsyslog-mysql rsyslog-mysql/mysql/admin-pass password $DB_PASS"
sudo debconf-set-selections <<< "rsyslog-mysql rsyslog-mysql/mysql/app-pass password $DB_PASS"
sudo debconf-set-selections <<< "rsyslog-mysql rsyslog-mysql/app-password-confirm password $DB_PASS"

# 2. INSTALL CORE & MARIADB
echo -e "${GREEN}[1/5] Installing Services...${NC}"
sudo apt update -y && sudo apt install apache2 mariadb-server php libapache2-mod-php php-mysql php-xml -y
sudo systemctl enable --now mariadb

# Wait for MariaDB to be ready
until sudo mysqladmin ping >/dev/null 2>&1; do echo -n "."; sleep 1; done

# 3. INSTALL RSYSLOG-MYSQL & DATABASE FIX
sudo DEBIAN_FRONTEND=noninteractive apt install rsyslog-mysql -y
echo -e "${GREEN}[2/5] Hardening Database & User...${NC}"
sudo mysql -u root <<EOF
CREATE USER IF NOT EXISTS 'rsyslog'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON Syslog.* TO 'rsyslog'@'localhost';
FLUSH PRIVILEGES;
USE Syslog;
-- Patch columns (Idempotent - won't fail if exists)
ALTER TABLE SystemEvents CHANGE NTSeverity ntseverity int, CHANGE Importance importance int, CHANGE EventSource eventsource varchar(60), CHANGE EventCategory eventcategory int, CHANGE EventLogType eventlogtype varchar(60);
ALTER TABLE SystemEvents ADD COLUMN IF NOT EXISTS processid varchar(60) DEFAULT '' AFTER SysLogTag;
ALTER TABLE SystemEvents ADD COLUMN IF NOT EXISTS messagetype varchar(60) DEFAULT '' AFTER processid;
ALTER TABLE SystemEvents ADD COLUMN IF NOT EXISTS fromip varchar(60) DEFAULT '' AFTER Message;
ALTER TABLE SystemEvents ADD COLUMN IF NOT EXISTS checksum int DEFAULT 0;
EOF

# 4. CONFIGURE RSYSLOG (THE MAGIC FIX)
echo -e "${GREEN}[3/5] Applying TCP Bypass & IP Template...${NC}"
sudo bash -c "cat > /etc/rsyslog.d/mysql.conf << EOF
module(load=\"ommysql\")
template(name=\"StdSQLtemplate\" type=\"list\") {
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
*.* :ommysql:127.0.0.1,Syslog,rsyslog,$DB_PASS;StdSQLtemplate
EOF"

# Enable UDP & Disable DNS globally in Rsyslog
sudo sed -i '/imudp/s/^#//g' /etc/rsyslog.conf
sudo sed -i '/port="514"/s/^#//g' /etc/rsyslog.conf
sudo sed -i '1i global(net.enableDNS="off")' /etc/rsyslog.conf

# 5. LOGANALYZER WEB DEPLOY
echo -e "${GREEN}[4/5] Deploying LogAnalyzer...${NC}"
cd /var/www/html/ && sudo wget -q https://download.adiscon.com/loganalyzer/loganalyzer-4.1.13.tar.gz
sudo tar -xzf loganalyzer-4.1.13.tar.gz && sudo mv loganalyzer-4.1.13/src syslog
sudo touch syslog/config.php && sudo chmod 666 syslog/config.php && sudo chown -R www-data:www-data syslog
sudo rm -rf loganalyzer-4.1.13*

# RESTART ALL
sudo systemctl restart rsyslog apache2
logger "BÚUUUUUU! SUCCESSFUL DEPLOYMENT!"

echo -e "\n${BLUE}====================================================${NC}"
echo -e "${GREEN}✅ SCRIPT COMPLETE!${NC}"
echo -e "🔗 URL: http://$(hostname -I | awk '{print $1}')/syslog"
echo -e "⚠️  AFTER Web Setup (Step 7), run this command to FIX LOADING:"
echo -e "${RED}sudo sed -i \"s/EnableIPAddressResolve'] = true/EnableIPAddressResolve'] = false/g\" /var/www/html/syslog/config.php${NC}"
echo -e "${BLUE}====================================================${NC}" false;\" /var/www/html/syslog/config.php${NC}"
echo -e "${BLUE}====================================================${NC}"
