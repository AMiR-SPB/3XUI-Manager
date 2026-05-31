#!/bin/bash

set -euo pipefail

SERVICE="x-ui"
INSTALL_DIR="/usr/local/x-ui"
DB_DIR="/etc/x-ui"

# =========================
# COLORS
# =========================
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

# =========================
# BANNER
# =========================
show_banner() {
clear
echo -e "\e[34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e "  \e[36m██╗  ██╗    ██╗   ██╗██╗\e[0m"
echo -e "  \e[36m╚██╗██╔╝    ██║   ██║██║\e[0m"
echo -e "  \e[36m ╚███╔╝     ██║   ██║██║\e[0m"
echo -e "  \e[36m ██╔██╗     ██║   ██║██║\e[0m"
echo -e "  \e[36m██╔╝ ██╗    ╚██████╔╝██║\e[0m"
echo -e "  \e[36m╚═╝  ╚═╝     ╚═════╝ ╚═╝\e[0m"
echo ""
echo -e "  \e[33m▸ Manager Script\e[0m         \e[90mby AMiR SPB\e[0m"
echo -e "  \e[90m▸ Telegram: @Amir_SPB\e[0m"
echo -e "\e[34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo ""
}

# =========================
# MENU
# =========================
show_menu() {
echo -e "${BLUE}"
echo "1) Install 3x-ui"
echo "2) Full Remove 3x-ui"
echo "3) Manual Backup & Restore"
echo "4) Update 3x-ui"
echo "5) Service Status"
echo "6) Enable CLI Command"
echo "7) Change Panel Settings"
echo "8) Set Automatic Backup"
echo "9) Client Management"
echo "0) Exit"
echo -e "${RESET}"
}

# =========================
# SHARED: SELECT TAR FILE
# =========================
select_tar_file() {
    local ARCH_NAME="$1"

    echo ""
    echo -e "${YELLOW}📂 Available x-ui tar files in /root:${RESET}"
    echo ""

    mapfile -t TAR_FILES < <(find /root -maxdepth 1 -name "*.tar.gz" 2>/dev/null | sort)

    if [[ ${#TAR_FILES[@]} -eq 0 ]]; then
        echo -e "${RED}❌ No .tar.gz files found in /root${RESET}"
        return 1
    fi

    for i in "${!TAR_FILES[@]}"; do
        SIZE=$(du -sh "${TAR_FILES[$i]}" 2>/dev/null | awk '{print $1}')
        DATE=$(stat -c '%y' "${TAR_FILES[$i]}" 2>/dev/null | cut -d'.' -f1)
        FNAME=$(basename "${TAR_FILES[$i]}")

        if [[ "$FNAME" == *"$ARCH_NAME"* ]]; then
            echo -e "  ${GREEN}$((i+1)))${RESET} $FNAME  ${YELLOW}[$SIZE]${RESET}  ${BLUE}$DATE${RESET}  ${GREEN}← recommended${RESET}"
        else
            echo -e "  ${GREEN}$((i+1)))${RESET} $FNAME  ${YELLOW}[$SIZE]${RESET}  ${BLUE}$DATE${RESET}"
        fi
    done

    echo ""
    read -p "Select file number: " file_num

    if ! [[ "$file_num" =~ ^[0-9]+$ ]] || (( file_num < 1 || file_num > ${#TAR_FILES[@]} )); then
        echo -e "${RED}❌ Invalid selection${RESET}"
        return 1
    fi

    SELECTED_TAR="${TAR_FILES[$((file_num-1))]}"
    echo -e "${GREEN}✅ Selected:${RESET} $(basename $SELECTED_TAR)"
    return 0
}

# =========================
# INSTALL FUNCTION
# =========================
install_xui() {

if [[ -x "$INSTALL_DIR/x-ui" ]]; then
    echo ""
    echo -e "${RED}❌ X-UI is already installed on this system.${RESET}"
    echo -e "${YELLOW}💡 To update, use option 4 from the main menu.${RESET}"
    echo -e "${YELLOW}💡 To reinstall, use option 2 to fully remove it first, then install again.${RESET}"
    sleep 2
    return
fi

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  ARCH_NAME="amd64" ;;
    aarch64) ARCH_NAME="arm64" ;;
    armv7l)  ARCH_NAME="armv7" ;;
    *)       ARCH_NAME="$ARCH" ;;
esac

XRAY_BIN="xray-linux-$ARCH_NAME"

echo -e "${YELLOW}"
echo "⚠️  Before continuing installation:"
echo ""
echo "Make sure your x-ui tar.gz file is placed in /root"
echo "Detected architecture: $ARCH_NAME"
echo ""
echo -e "${RESET}"

read -p "Have You Placed The File In /root? (y/n): " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo -e "${RED}❌ Installation Cancelled By User${RESET}"
    sleep 1
    return
fi

select_tar_file "$ARCH_NAME" || return
XUI_TAR="$SELECTED_TAR"

echo -e "${YELLOW}📦 Extracting...${RESET}"

cd /root
rm -rf /root/x-ui
tar -xzf "$XUI_TAR"

echo -e "${YELLOW}📁 Installing...${RESET}"

rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/bin"

cp -f /root/x-ui/x-ui "$INSTALL_DIR/x-ui"
chmod +x "$INSTALL_DIR/x-ui"

cp -f "/root/x-ui/bin/$XRAY_BIN" "$INSTALL_DIR/bin/$XRAY_BIN"
chmod +x "$INSTALL_DIR/bin/$XRAY_BIN"

cp -f /root/x-ui/bin/geoip.dat "$INSTALL_DIR/bin/"
cp -f /root/x-ui/bin/geosite.dat "$INSTALL_DIR/bin/"

chmod 644 "$INSTALL_DIR/bin/"*.dat

echo -e "${YELLOW}⚙️  Setting Up Service...${RESET}"

cp -f /root/x-ui/x-ui.service.debian /etc/systemd/system/x-ui.service

systemctl daemon-reload
systemctl enable x-ui

echo -e "${YELLOW}🚀 Starting X-UI...${RESET}"

systemctl restart x-ui
sleep 3

if systemctl is-active --quiet x-ui; then
    echo -e "${GREEN}✅ X-UI Installed Successfully${RESET}"
else
    echo -e "${RED}❌ Service Failed To Start${RESET}"
    return
fi

echo -e "${YELLOW}🧹 Cleaning Up Temporary Files...${RESET}"
cp -f /root/x-ui/x-ui.sh "$INSTALL_DIR/x-ui.sh" 2>/dev/null || true
chmod +x "$INSTALL_DIR/x-ui.sh" 2>/dev/null || true
rm -rf /root/x-ui

IP=$(curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')

echo ""
echo -e "${BLUE}======================================"
echo "🎉 INSTALL COMPLETE"
echo "======================================"
echo -e "${RESET}"

echo -e "${GREEN}🌐 Panel URL:${RESET} http://$IP:2053"
echo -e "${GREEN}👤 Username:${RESET} admin"
echo -e "${GREEN}🔑 Password:${RESET} admin"

echo -e "${BLUE}======================================"
echo -e "${RESET}"
echo -e "${YELLOW}⚠️  NOTE: After logging in, make sure to change the port, web path, username, and password immediately.${RESET}"
echo ""
}

# =========================
# FULL REMOVE FUNCTION
# =========================
remove_xui() {

echo ""
read -p "⚠️ Are you sure you want to REMOVE X-UI completely? (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
    echo -e "${RED}Cancelled.${RESET}"
    sleep 1
    return
fi

echo ""
read -p "💾 Do you want to create backup before remove? (y/n): " backup_confirm

if [[ "$backup_confirm" == "y" || "$backup_confirm" == "Y" ]]; then

    echo ""
    read -p "📁 Enter backup folder name: " BACKUP_FOLDER

    echo ""
    read -p "📦 Enter backup archive file name: " BACKUP_FILE

    BACKUP_DIR="/root/$BACKUP_FOLDER"

    mkdir -p "$BACKUP_DIR"

    echo -e "${GREEN}💾 Creating full backup...${RESET}"

    cp -rf "$INSTALL_DIR" "$BACKUP_DIR/x-ui" 2>/dev/null || true
    cp -rf "$DB_DIR" "$BACKUP_DIR/etc-x-ui" 2>/dev/null || true
    cp -rf /etc/systemd/system/x-ui.service "$BACKUP_DIR/" 2>/dev/null || true
    cp -rf /var/log/x-ui "$BACKUP_DIR/" 2>/dev/null || true

    tar -czf "/root/$BACKUP_FILE.tar.gz" -C /root "$BACKUP_FOLDER"

    if [[ $? -eq 0 ]]; then
        mv "/root/$BACKUP_FILE.tar.gz" "$BACKUP_DIR/$BACKUP_FILE.tar.gz"
        echo -e "${GREEN}📦 Backup saved:${RESET} $BACKUP_DIR/$BACKUP_FILE.tar.gz"
    else
        echo -e "${RED}❌ Backup failed! Files kept at: $BACKUP_DIR${RESET}"
    fi
fi

echo ""
echo -e "${YELLOW}🛑 Stopping X-UI service...${RESET}"

systemctl stop $SERVICE || true
systemctl disable $SERVICE || true

echo ""
echo -e "${RED}💣 Removing all X-UI files...${RESET}"

rm -rf "$INSTALL_DIR"
rm -rf "$DB_DIR"

rm -rf /var/log/x-ui
rm -rf /var/lib/x-ui

rm -rf /root/x-ui

rm -f /etc/systemd/system/x-ui.service

rm -f /usr/bin/x-ui
rm -f /usr/sbin/x-ui

systemctl daemon-reload

pkill -f x-ui || true
pkill -f xray || true

echo -e "${GREEN}✅ X-UI completely removed${RESET}"

echo ""
echo -e "${BLUE}======================================"
echo "🎉 REMOVAL COMPLETE"
echo "======================================"
echo -e "${RESET}"

echo ""
read -p "🔄 Do you want to reboot the server? (y/n): " reboot_confirm

if [[ "$reboot_confirm" == "y" || "$reboot_confirm" == "Y" ]]; then
    echo -e "${YELLOW}Rebooting...${RESET}"
    reboot
else
    echo -e "${GREEN}Done without reboot.${RESET}"
fi
}

# =========================
# BACKUP & RESTORE FUNCTION
# =========================
backup_restore_xui() {

echo ""
echo -e "${BLUE}=============================="
echo "   BACKUP & RESTORE MODULE"
echo "=============================="
echo -e "${RESET}"

echo "1) Backup"
echo "2) Restore"
read -p "Select option: " br_choice

# =========================
# BACKUP
# =========================
if [[ "$br_choice" == "1" ]]; then

    echo ""
    echo "1) Full Backup"
    echo "2) Database Only"
    read -p "Select backup type: " btype

    read -p "Enter backup folder name (saved in /root): " folder_name
    read -p "Enter backup file name: " file_name

    BACKUP_DIR="/root/$folder_name"
    mkdir -p "$BACKUP_DIR"

    echo ""
    echo -e "${YELLOW}📦 Creating backup...${RESET}"

    if [[ "$btype" == "1" ]]; then
        # FULL BACKUP
        cp -rf /usr/local/x-ui "$BACKUP_DIR/" 2>/dev/null || true
        cp -rf /etc/x-ui "$BACKUP_DIR/" 2>/dev/null || true
        cp -rf /var/log/x-ui "$BACKUP_DIR/" 2>/dev/null || true
        cp -rf /var/lib/x-ui "$BACKUP_DIR/" 2>/dev/null || true
        cp -rf /etc/systemd/system/x-ui.service "$BACKUP_DIR/" 2>/dev/null || true
        cp -rf /root/x-ui "$BACKUP_DIR/" 2>/dev/null || true

    elif [[ "$btype" == "2" ]]; then
        # DATABASE ONLY
        cp -rf /etc/x-ui "$BACKUP_DIR/" 2>/dev/null || true
    else
        echo -e "${RED}Invalid option${RESET}"
        return
    fi

    tar -czf "/root/$file_name.tar.gz" -C /root "$folder_name"

    if [[ $? -eq 0 ]]; then
        mv "/root/$file_name.tar.gz" "$BACKUP_DIR/$file_name.tar.gz"
        echo ""
        echo -e "${GREEN}✅ Backup completed${RESET}"
        echo -e "${GREEN}📍 Location:${RESET} $BACKUP_DIR/$file_name.tar.gz"
    else
        echo -e "${RED}❌ Backup failed! Files kept at: $BACKUP_DIR${RESET}"
    fi
fi

# =========================
# RESTORE
# =========================
if [[ "$br_choice" == "2" ]]; then

    echo ""
    echo "1) Full Restore"
    echo "2) Database Only Restore"
    read -p "Select restore type: " rtype

    echo ""
    echo -e "${YELLOW}📂 Available backup files in /root:${RESET}"
    echo ""

    mapfile -t BACKUP_FILES < <(find /root -maxdepth 1 -name "*.tar.gz" 2>/dev/null | sort)

    if [[ ${#BACKUP_FILES[@]} -eq 0 ]]; then
        echo -e "${RED}❌ No .tar.gz files found in /root${RESET}"
        return
    fi

    for i in "${!BACKUP_FILES[@]}"; do
        SIZE=$(du -sh "${BACKUP_FILES[$i]}" 2>/dev/null | awk '{print $1}')
        DATE=$(stat -c '%y' "${BACKUP_FILES[$i]}" 2>/dev/null | cut -d'.' -f1)
        echo -e "  ${GREEN}$((i+1)))${RESET} ${BACKUP_FILES[$i]}  ${YELLOW}[$SIZE]${RESET}  ${BLUE}$DATE${RESET}"
    done

    echo ""
    read -p "Select file number: " file_num

    if ! [[ "$file_num" =~ ^[0-9]+$ ]] || (( file_num < 1 || file_num > ${#BACKUP_FILES[@]} )); then
        echo -e "${RED}❌ Invalid selection${RESET}"
        return
    fi

    backup_file="${BACKUP_FILES[$((file_num-1))]}"
    echo -e "${GREEN}✅ Selected:${RESET} $backup_file"

    if [[ ! -f "$backup_file" ]]; then
        echo -e "${RED}Backup file not found!${RESET}"
        return
    fi

    systemctl stop x-ui || true

    echo ""
    echo -e "${YELLOW}♻️ Restoring...${RESET}"

    if [[ "$rtype" == "1" ]]; then
        # FULL RESTORE
        tar -xzf "$backup_file" -C /
        systemctl daemon-reload
        systemctl restart x-ui

    elif [[ "$rtype" == "2" ]]; then
        # DB ONLY RESTORE
        tar -xzf "$backup_file" -C /
        systemctl restart x-ui
    else
        echo -e "${RED}Invalid option${RESET}"
        return
    fi

    echo ""
    echo -e "${GREEN}✅ Restore completed${RESET}"
    echo -e "${GREEN}🚀 Service restarted${RESET}"
fi

}

# =========================
# UPDATE FUNCTION
# =========================
update_xui() {

echo ""
echo -e "${BLUE}======================================"
echo "        UPDATE X-UI MODULE"
echo "======================================"
echo -e "${RESET}"

if [[ ! -x "$INSTALL_DIR/x-ui" ]]; then
    echo -e "${RED}❌ X-UI is not installed on this system.${RESET}"
    echo -e "${YELLOW}💡 Please install X-UI first using option 1 from the main menu.${RESET}"
    sleep 2
    return
fi

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  ARCH_NAME="amd64" ;;
    aarch64) ARCH_NAME="arm64" ;;
    armv7l)  ARCH_NAME="armv7" ;;
    *)       ARCH_NAME="$ARCH" ;;
esac

XRAY_BIN="xray-linux-$ARCH_NAME"

echo -e "${YELLOW}⚠️  Before continuing update:"
echo ""
echo "Make sure your x-ui tar.gz file is placed in /root"
echo "Detected architecture: $ARCH_NAME"
echo -e "${RESET}"

read -p "Have you placed the file in /root? (y/n): " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo -e "${RED}❌ Update cancelled by user${RESET}"
    sleep 1
    return
fi

select_tar_file "$ARCH_NAME" || return
XUI_TAR="$SELECTED_TAR"

UPDATE_BACKUP_DIR="/root/xui-backup-$(date +%Y%m%d-%H%M%S)"
TMP_DIR="/root/x-ui-tmp"

mkdir -p "$UPDATE_BACKUP_DIR"

echo -e "${YELLOW}🛑 Stopping service...${RESET}"
systemctl stop $SERVICE || true
sleep 2

echo -e "${YELLOW}💾 Backing up database and configs...${RESET}"
cp -f "$DB_DIR/x-ui.db"* "$UPDATE_BACKUP_DIR/" 2>/dev/null || true
cp -f "$INSTALL_DIR/bin/config.json" "$UPDATE_BACKUP_DIR/" 2>/dev/null || true
cp -f /etc/systemd/system/x-ui.service "$UPDATE_BACKUP_DIR/" 2>/dev/null || true
cp -f "$INSTALL_DIR/bin/geoip.dat" "$UPDATE_BACKUP_DIR/" 2>/dev/null || true
cp -f "$INSTALL_DIR/bin/geosite.dat" "$UPDATE_BACKUP_DIR/" 2>/dev/null || true

echo -e "${YELLOW}📦 Extracting new version...${RESET}"
cd /root
rm -rf "$TMP_DIR" /root/x-ui
tar -xzf "$XUI_TAR"
mv /root/x-ui "$TMP_DIR"

echo -e "${YELLOW}🗑  Cleaning old install...${RESET}"
rm -rf "$INSTALL_DIR"

echo -e "${YELLOW}📁 Installing new version...${RESET}"
mkdir -p "$INSTALL_DIR/bin"

cp -f "$TMP_DIR/x-ui" "$INSTALL_DIR/x-ui"
chmod +x "$INSTALL_DIR/x-ui"

cp -f "$TMP_DIR/bin/$XRAY_BIN" "$INSTALL_DIR/bin/$XRAY_BIN"
chmod +x "$INSTALL_DIR/bin/$XRAY_BIN"

cp -f "$UPDATE_BACKUP_DIR/geoip.dat" "$INSTALL_DIR/bin/" 2>/dev/null || true
cp -f "$UPDATE_BACKUP_DIR/geosite.dat" "$INSTALL_DIR/bin/" 2>/dev/null || true
chmod 644 "$INSTALL_DIR/bin/"*.dat 2>/dev/null || true

cp -f "$TMP_DIR/x-ui.service.debian" /etc/systemd/system/x-ui.service

systemctl daemon-reload
systemctl enable $SERVICE

echo ""
echo -e "${BLUE}======================================"
echo "🧠 Database Options"
echo "======================================"
echo -e "${RESET}"
echo "1) Restore old database (keep users/inbounds)"
echo "2) Fresh database (RESET everything)"
echo ""

read -p "Choose option [1 or 2]: " db_choice

mkdir -p "$DB_DIR"

if [[ "$db_choice" == "1" ]]; then
    echo -e "${YELLOW}♻️  Restoring old database...${RESET}"
    cp -f "$UPDATE_BACKUP_DIR"/x-ui.db* "$DB_DIR/" 2>/dev/null || true
else
    echo -e "${YELLOW}🧹 Creating fresh database (reset)...${RESET}"
    rm -f "$DB_DIR"/x-ui.db*
fi

echo -e "${YELLOW}🚀 Starting service...${RESET}"
systemctl restart $SERVICE
sleep 3

if systemctl is-active --quiet $SERVICE; then
    echo -e "${GREEN}✅ X-UI updated and running${RESET}"
else
    echo -e "${RED}❌ Service failed to start — rolling back database...${RESET}"
    systemctl stop $SERVICE || true
    cp -f "$UPDATE_BACKUP_DIR"/x-ui.db* "$DB_DIR/" 2>/dev/null || true
    systemctl restart $SERVICE || true
    echo -e "${RED}⚠️  Rollback done. Check your install manually.${RESET}"
    return
fi

rm -rf "$TMP_DIR"

echo ""
echo -e "${BLUE}======================================"
echo "✅ UPDATE COMPLETE"
echo -e "📦 Backup saved at: ${GREEN}$UPDATE_BACKUP_DIR${RESET}"
echo -e "${BLUE}======================================"
echo -e "${RESET}"

read -p "🔄 Do you want to reboot the server? (y/n): " reboot_confirm

if [[ "$reboot_confirm" == "y" || "$reboot_confirm" == "Y" ]]; then
    echo -e "${YELLOW}Rebooting...${RESET}"
    reboot
else
    echo -e "${GREEN}Done without reboot.${RESET}"
fi
}

# =========================
# SERVICE STATUS FUNCTION
# =========================
status_xui() {

echo ""
echo -e "${BLUE}======================================"
echo "       SERVICE STATUS MODULE"
echo "======================================"
echo -e "${RESET}"

if systemctl is-active --quiet $SERVICE; then
    echo -e "🟢 Status:    ${GREEN}Running${RESET}"
else
    echo -e "🔴 Status:    ${RED}Stopped${RESET}"
fi

if systemctl is-enabled --quiet $SERVICE 2>/dev/null; then
    echo -e "🔁 Autostart: ${GREEN}Enabled${RESET}"
else
    echo -e "🔁 Autostart: ${RED}Disabled${RESET}"
fi

UPTIME=$(systemctl show $SERVICE --property=ActiveEnterTimestamp 2>/dev/null | cut -d'=' -f2)
if [[ -n "$UPTIME" ]]; then
    echo -e "⏱  Since:     ${YELLOW}$UPTIME${RESET}"
fi

echo ""
echo -e "${BLUE}--- Panel Settings ---${RESET}"

if [[ -x "$INSTALL_DIR/x-ui" ]]; then
    SETTINGS=$("$INSTALL_DIR/x-ui" setting -show true 2>/dev/null || true)
    IP=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')

    PANEL_PORT=$(echo "$SETTINGS" | grep -Eo 'port: .+' | awk '{print $2}' || true)
    PANEL_USER=$(echo "$SETTINGS" | grep -Eo 'username: .+' | awk '{print $2}' || true)
    PANEL_PATH=$(echo "$SETTINGS" | grep -Eo 'webBasePath: .+' | awk '{print $2}' || true)

    [[ -n "$PANEL_PORT" ]] && echo -e "🌐 Port:      ${GREEN}$PANEL_PORT${RESET}"
    [[ -n "$PANEL_USER" ]] && echo -e "👤 Username:  ${GREEN}$PANEL_USER${RESET}"
    [[ -n "$PANEL_PATH" ]] && echo -e "🔗 Web Path:  ${GREEN}$PANEL_PATH${RESET}"
    [[ -n "$IP" && -n "$PANEL_PORT" ]] && echo -e "🖥  Panel URL: ${GREEN}http://$IP:$PANEL_PORT${PANEL_PATH}${RESET}"
else
    echo -e "${YELLOW}⚠️  x-ui binary not found — cannot read settings${RESET}"
fi

echo ""
echo -e "${BLUE}--- Last 10 Log Lines ---${RESET}"
journalctl -u $SERVICE -n 10 --no-pager 2>/dev/null || echo -e "${YELLOW}No logs available${RESET}"

echo ""
echo -e "${BLUE}======================================"
echo -e "${RESET}"
}

# =========================
# CHANGE PANEL SETTINGS
# =========================
change_settings_xui() {

echo ""
echo -e "${BLUE}======================================"
echo "    CHANGE PANEL SETTINGS MODULE"
echo "======================================"
echo -e "${RESET}"

if [[ ! -x "$INSTALL_DIR/x-ui" ]]; then
    echo -e "${RED}❌ x-ui binary not found. Is x-ui installed?${RESET}"
    sleep 2
    return
fi

echo -e "${YELLOW}📋 Current Settings:${RESET}"
"$INSTALL_DIR/x-ui" setting -show true 2>/dev/null | grep -E 'port:|username:|webBasePath:' | while read line; do
    echo -e "   ${GREEN}$line${RESET}"
done
echo ""

echo "What do you want to change?"
echo "1) Port"
echo "2) Username & Password"
echo "3) Web Path"
echo "4) All of the above"
echo ""
read -p "Select option: " setting_choice

case $setting_choice in
    1)
        read -p "Enter new port (1024-65535): " new_port
        if [[ "$new_port" =~ ^[0-9]+$ ]] && (( new_port >= 1024 && new_port <= 65535 )); then
            "$INSTALL_DIR/x-ui" setting -port "$new_port"
            echo -e "${GREEN}✅ Port changed to $new_port${RESET}"
        else
            echo -e "${RED}❌ Invalid port number${RESET}"
            return
        fi
        ;;
    2)
        read -p "Enter new username: " new_user
        read -p "Enter new password: " new_pass
        if [[ -n "$new_user" && -n "$new_pass" ]]; then
            "$INSTALL_DIR/x-ui" setting -username "$new_user" -password "$new_pass"
            echo -e "${GREEN}✅ Username and password updated${RESET}"
        else
            echo -e "${RED}❌ Username or password cannot be empty${RESET}"
            return
        fi
        ;;
    3)
        read -p "Enter new web path (e.g. mypath): " new_path
        if [[ -n "$new_path" ]]; then
            "$INSTALL_DIR/x-ui" setting -webBasePath "$new_path"
            echo -e "${GREEN}✅ Web path changed to /$new_path${RESET}"
        else
            echo -e "${RED}❌ Web path cannot be empty${RESET}"
            return
        fi
        ;;
    4)
        read -p "Enter new port (1024-65535): " new_port
        read -p "Enter new username: " new_user
        read -p "Enter new password: " new_pass
        read -p "Enter new web path (e.g. mypath): " new_path

        if [[ ! "$new_port" =~ ^[0-9]+$ ]] || (( new_port < 1024 || new_port > 65535 )); then
            echo -e "${RED}❌ Invalid port number${RESET}"
            return
        fi
        if [[ -z "$new_user" || -z "$new_pass" || -z "$new_path" ]]; then
            echo -e "${RED}❌ All fields are required${RESET}"
            return
        fi

        "$INSTALL_DIR/x-ui" setting -port "$new_port" -username "$new_user" -password "$new_pass" -webBasePath "$new_path"
        echo -e "${GREEN}✅ All settings updated${RESET}"
        ;;
    *)
        echo -e "${RED}Invalid option${RESET}"
        return
        ;;
esac

echo -e "${YELLOW}🔄 Restarting service to apply changes...${RESET}"
systemctl restart $SERVICE
sleep 2

if systemctl is-active --quiet $SERVICE; then
    echo -e "${GREEN}✅ Service restarted successfully${RESET}"

    IP=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
    NEW_SETTINGS=$("$INSTALL_DIR/x-ui" setting -show true 2>/dev/null || true)
    NEW_PORT=$(echo "$NEW_SETTINGS" | grep -Eo 'port: .+' | awk '{print $2}' || true)
    NEW_PATH=$(echo "$NEW_SETTINGS" | grep -Eo 'webBasePath: .+' | awk '{print $2}' || true)
    echo -e "${GREEN}🌐 New Panel URL: http://$IP:$NEW_PORT${NEW_PATH}${RESET}"
else
    echo -e "${RED}❌ Service failed to restart${RESET}"
fi
}

# =========================
# ENABLE CLI COMMAND
# =========================
enable_cmd() {

XUI_SH=""

if [[ -f "$INSTALL_DIR/x-ui.sh" ]]; then
    XUI_SH="$INSTALL_DIR/x-ui.sh"
elif [[ -f "/root/x-ui/x-ui.sh" ]]; then
    XUI_SH="/root/x-ui/x-ui.sh"
else
    echo -e "${YELLOW}⚠️  x-ui.sh not found. Attempting to extract from a tar file...${RESET}"
    echo ""

    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)  ARCH_NAME="amd64" ;;
        aarch64) ARCH_NAME="arm64" ;;
        armv7l)  ARCH_NAME="armv7" ;;
        *)       ARCH_NAME="$ARCH" ;;
    esac

    select_tar_file "$ARCH_NAME" || return
    XUI_TAR="$SELECTED_TAR"

    echo ""
    echo -e "${YELLOW}📦 Extracting x-ui.sh from archive...${RESET}"

    cd /root
    rm -rf /root/x-ui
    tar -xzf "$XUI_TAR"

    if [[ ! -f "/root/x-ui/x-ui.sh" ]]; then
        echo -e "${RED}❌ x-ui.sh not found inside the archive. Archive may be corrupted.${RESET}"
        rm -rf /root/x-ui
        sleep 2
        return
    fi

    mkdir -p "$INSTALL_DIR"
    cp -f /root/x-ui/x-ui.sh "$INSTALL_DIR/x-ui.sh"
    chmod +x "$INSTALL_DIR/x-ui.sh"
    rm -rf /root/x-ui

    echo -e "${GREEN}✅ x-ui.sh extracted and installed.${RESET}"
    XUI_SH="$INSTALL_DIR/x-ui.sh"
fi

chmod +x "$XUI_SH"
ln -sf "$XUI_SH" /usr/bin/x-ui

if [[ -x "/usr/bin/x-ui" ]]; then
    echo ""
    echo -e "${GREEN}✅ CLI command enabled successfully!${RESET}"
    echo -e "${GREEN}💡 From now on, you can type${RESET} x-ui ${GREEN}anywhere in the terminal to access the management menu.${RESET}"
    echo ""
else
    echo -e "${RED}❌ Something went wrong. Symlink not created properly.${RESET}"
fi

}

# =========================
# MANAGE CLIENT EXPIRY
# =========================
manage_expiry_xui() {

echo ""
echo -e "${BLUE}======================================"
echo "     CLIENT MANAGEMENT MODULE"
echo "======================================"
echo -e "${RESET}"

DB_FILE="$DB_DIR/x-ui.db"

if [[ ! -f "$DB_FILE" ]]; then
    echo -e "${RED}❌ Database not found at $DB_FILE${RESET}"
    echo -e "${YELLOW}💡 Make sure X-UI is installed.${RESET}"
    sleep 2
    return
fi

if ! command -v python3 &>/dev/null; then
    echo -e "${RED}❌ python3 is required but not installed.${RESET}"
    sleep 2
    return
fi

echo "1) Add days"
echo "2) Subtract days"
echo "3) Add / Subtract volume (GB)"
echo ""
read -p "Select option: " action

if [[ "$action" != "1" && "$action" != "2" && "$action" != "3" ]]; then
    echo -e "${RED}❌ Invalid option${RESET}"
    return
fi

# =========================
# SELECT INBOUND
# =========================
SELECTED_INBOUND_ID=""

INBOUND_COUNT=$(python3 -c "
import sqlite3, json
conn = sqlite3.connect('$DB_FILE')
c = conn.cursor()
c.execute('SELECT COUNT(*) FROM inbounds')
print(c.fetchone()[0])
conn.close()
")

if (( INBOUND_COUNT > 1 )); then
    echo ""
    echo -e "${YELLOW}📡 Available Inbounds:${RESET}"
    echo ""

    python3 << PYEOF
import sqlite3, json
conn = sqlite3.connect("$DB_FILE")
c = conn.cursor()
c.execute("SELECT id, remark, settings FROM inbounds")
rows = c.fetchall()
for i, r in enumerate(rows):
    iid, remark, settings = r
    try:
        clients = json.loads(settings).get('clients', [])
        print(f"  {i+1}) {remark}  ({len(clients)} clients)")
    except:
        print(f"  {i+1}) {remark}")
conn.close()
PYEOF

    echo ""
    echo -e "  ${GREEN}0)${RESET} All inbounds"
    echo ""
    read -p "Select inbound: " inbound_choice

    SELECTED_INBOUND_ID=$(python3 << PYEOF
import sqlite3
conn = sqlite3.connect("$DB_FILE")
c = conn.cursor()
c.execute("SELECT id FROM inbounds ORDER BY id")
rows = [r[0] for r in c.fetchall()]
conn.close()
choice = "$inbound_choice"
if choice == "0":
    print("")
elif choice.isdigit() and 1 <= int(choice) <= len(rows):
    print(rows[int(choice)-1])
else:
    print("INVALID")
PYEOF
)

    if [[ "$SELECTED_INBOUND_ID" == "INVALID" ]]; then
        echo -e "${RED}❌ Invalid selection${RESET}"
        return
    fi

    if [[ -n "$SELECTED_INBOUND_ID" ]]; then
        INBOUND_NAME=$(python3 -c "
import sqlite3
conn = sqlite3.connect('$DB_FILE')
c = conn.cursor()
c.execute('SELECT remark FROM inbounds WHERE id = ?', ($SELECTED_INBOUND_ID,))
r = c.fetchone()
conn.close()
print(r[0] if r else '')
")
        echo -e "${GREEN}✅ Selected inbound:${RESET} $INBOUND_NAME"
    else
        echo -e "${GREEN}✅ Applying to all inbounds${RESET}"
    fi
fi

# ========================= VOLUME MANAGEMENT =========================
if [[ "$action" == "3" ]]; then

    echo ""
    echo "1) Add volume"
    echo "2) Subtract volume"
    echo ""
    read -p "Select option: " vol_action

    if [[ "$vol_action" != "1" && "$vol_action" != "2" ]]; then
        echo -e "${RED}❌ Invalid option${RESET}"
        return
    fi

    echo ""
    echo "Apply to which clients?"
    echo "1) All clients (skip unlimited)"
    echo "2) Active clients only"
    echo "3) Volume-limited clients only"
    echo ""
    read -p "Select option: " vol_target

    if [[ "$vol_target" != "1" && "$vol_target" != "2" && "$vol_target" != "3" ]]; then
        echo -e "${RED}❌ Invalid option${RESET}"
        return
    fi

    echo ""
    read -p "📦 How many GB? " gb

    if ! [[ "$gb" =~ ^[0-9]+$ ]] || (( gb < 1 )); then
        echo -e "${RED}❌ Invalid number${RESET}"
        return
    fi

    echo ""
    echo -e "${YELLOW}📋 Affected clients:${RESET}"
    echo ""

    now_ms=$(date +%s%3N)

    python3 << PYEOF
import sqlite3, time, json

db = "$DB_FILE"
gb = $gb
vol_action = "$vol_action"
vol_target = "$vol_target"
now_ms = int(time.time() * 1000)
delta_bytes = gb * 1024 * 1024 * 1024

conn = sqlite3.connect(db)
c = conn.cursor()
selected_id = "$SELECTED_INBOUND_ID"
if selected_id:
    c.execute("SELECT id, settings FROM inbounds WHERE id = ?", (int(selected_id),))
else:
    c.execute("SELECT id, settings FROM inbounds")
inbound_rows = c.fetchall()

all_clients = []
for inbound_id, settings_str in inbound_rows:
    try:
        s = json.loads(settings_str)
        for cl in s.get('clients', []):
            total = cl.get('totalGB', 0) or 0
            email = cl.get('email', '')
            enable = cl.get('enable', True)
            exp = cl.get('expiryTime', 0) or 0

            if total == 0:
                continue  # skip unlimited volume

            # Get used traffic from client_traffics
            c.execute("SELECT up, down FROM client_traffics WHERE email = ?", (email,))
            row = c.fetchone()
            used = (row[0] + row[1]) if row else 0
            remaining = max(0, total - used)
            is_limited = used >= total

            if vol_target == "2" and not enable:
                continue  # active only
            if vol_target == "3" and not is_limited:
                continue  # limited only

            all_clients.append({
                'inbound_id': inbound_id,
                'email': email,
                'total': total,
                'used': used,
                'remaining': remaining,
                'enable': enable,
                'is_limited': is_limited
            })
    except:
        pass

conn.close()

if not all_clients:
    print("  No clients with volume limit found.")
else:
    for cl in all_clients:
        total_gb = cl['total'] / (1024**3)
        if vol_action == "1":
            new_total = cl['total'] + delta_bytes
        else:
            new_total = max(0, cl['total'] - delta_bytes)
        new_gb = new_total / (1024**3)
        status = "✅" if cl['enable'] else "🔴"
        limited = " ⚠️ limited" if cl['is_limited'] else ""
        print(f"  {status} {cl['email']:<20} {total_gb:.1f}GB  →  {new_gb:.1f}GB{limited}")
    print(f"\n  Total: {len(all_clients)} client(s)")
PYEOF

    echo ""
    if [[ "$vol_action" == "1" ]]; then
        read -p "➕ Add ${gb}GB to selected clients? (y/n): " confirm
    else
        read -p "➖ Subtract ${gb}GB from selected clients? (y/n): " confirm
    fi

    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo -e "${RED}❌ Cancelled${RESET}"
        return
    fi

    python3 << PYEOF
import sqlite3, time, json

db = "$DB_FILE"
gb = $gb
vol_action = "$vol_action"
vol_target = "$vol_target"
now_ms = int(time.time() * 1000)
delta_bytes = gb * 1024 * 1024 * 1024

conn = sqlite3.connect(db)
c = conn.cursor()
selected_id = "$SELECTED_INBOUND_ID"
if selected_id:
    c.execute("SELECT id, settings FROM inbounds WHERE id = ?", (int(selected_id),))
else:
    c.execute("SELECT id, settings FROM inbounds")
inbound_rows = c.fetchall()
total_updated = 0

for inbound_id, settings_str in inbound_rows:
    try:
        s = json.loads(settings_str)
        clients = s.get('clients', [])
        changed = False

        for cl in clients:
            total = cl.get('totalGB', 0) or 0
            email = cl.get('email', '')
            enable = cl.get('enable', True)

            if total == 0:
                continue  # skip unlimited

            c.execute("SELECT up, down FROM client_traffics WHERE email = ?", (email,))
            row = c.fetchone()
            used = (row[0] + row[1]) if row else 0
            is_limited = used >= total

            if vol_target == "2" and not enable:
                continue
            if vol_target == "3" and not is_limited:
                continue

            if vol_action == "1":
                new_total = total + delta_bytes
            else:
                new_total = max(0, total - delta_bytes)

            cl['totalGB'] = new_total
            c.execute("UPDATE client_traffics SET total = ? WHERE email = ?", (new_total, email))

            # Re-enable if now has enough volume
            if new_total > used:
                cl['enable'] = True
                c.execute("UPDATE client_traffics SET enable = 1 WHERE email = ?", (email,))

            changed = True
            total_updated += 1

        if changed:
            s['clients'] = clients
            c.execute("UPDATE inbounds SET settings = ? WHERE id = ?", (json.dumps(s), inbound_id))

    except Exception as e:
        print(f"  Error: {e}")

conn.commit()
conn.close()
print(f"  Updated {total_updated} client(s) successfully.")
PYEOF

    echo ""
    echo -e "${YELLOW}🔄 Restarting X-UI to apply changes...${RESET}"
    systemctl restart $SERVICE
    sleep 2

    if systemctl is-active --quiet $SERVICE; then
        echo -e "${GREEN}✅ Done! Changes applied and service restarted.${RESET}"
    else
        echo -e "${RED}❌ Service failed to restart${RESET}"
    fi
    return
fi
# ========================= END VOLUME =========================

echo ""
echo "Apply to which clients?"
echo "1) All clients (skip unlimited)"
if [[ "$action" == "1" ]]; then
    echo "2) Expired clients only"
    echo "3) Active clients only"
else
    echo "2) Active clients only"
fi
echo ""
read -p "Select option: " target

if [[ "$action" == "1" ]]; then
    if [[ "$target" != "1" && "$target" != "2" && "$target" != "3" ]]; then
        echo -e "${RED}❌ Invalid option${RESET}"
        return
    fi
else
    if [[ "$target" != "1" && "$target" != "2" ]]; then
        echo -e "${RED}❌ Invalid option${RESET}"
        return
    fi
fi

echo ""
read -p "📅 How many days? " days

if ! [[ "$days" =~ ^[0-9]+$ ]] || (( days < 1 )); then
    echo -e "${RED}❌ Invalid number of days${RESET}"
    return
fi

# Show affected clients before applying
echo ""
echo -e "${YELLOW}📋 Affected clients:${RESET}"
echo ""

python3 << PYEOF
import sqlite3, time, json

db = "$DB_FILE"
days = $days
action = "$action"
target = "$target"
now_ms = int(time.time() * 1000)
delta_ms = days * 24 * 60 * 60 * 1000

conn = sqlite3.connect(db)
c = conn.cursor()

# Collect all clients from inbounds settings JSON
selected_id = "$SELECTED_INBOUND_ID"
if selected_id:
    c.execute("SELECT id, settings FROM inbounds WHERE id = ?", (int(selected_id),))
else:
    c.execute("SELECT id, settings FROM inbounds")
inbound_rows = c.fetchall()

all_clients = []
for inbound_id, settings_str in inbound_rows:
    try:
        s = json.loads(settings_str)
        for cl in s.get('clients', []):
            exp = cl.get('expiryTime', 0) or 0
            if exp == 0:
                continue  # skip unlimited
            if target == "2" and action == "1" and exp >= now_ms:
                continue  # add mode option 2: skip non-expired
            if target == "3" and action == "1" and exp < now_ms:
                continue  # add mode option 3: skip expired (active only)
            if target == "2" and action == "2" and exp < now_ms:
                continue  # subtract mode: skip already expired
            all_clients.append({
                'inbound_id': inbound_id,
                'email': cl.get('email', ''),
                'exp': exp,
                'enable': cl.get('enable', True)
            })
    except:
        pass

conn.close()

if not all_clients:
    print("  No clients with a set date found. (Unlimited clients are skipped)")
else:
    for cl in all_clients:
        exp_str = time.strftime('%Y-%m-%d %H:%M', time.localtime(cl['exp'] / 1000))
        if action == "1":
            new_exp = cl['exp'] + delta_ms
        else:
            new_exp = max(0, cl['exp'] - delta_ms)
        new_str = time.strftime('%Y-%m-%d %H:%M', time.localtime(new_exp / 1000)) if new_exp > 0 else "Expired"
        status = "✅" if cl['enable'] else "🔴"
        print(f"  {status} {cl['email']:<20} {exp_str}  →  {new_str}")
    print(f"\n  Total: {len(all_clients)} client(s)")
PYEOF

echo ""
if [[ "$action" == "1" ]]; then
    read -p "➕ Add $days day(s) to selected clients? (y/n): " confirm
else
    read -p "➖ Subtract $days day(s) from selected clients? (y/n): " confirm
fi

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo -e "${RED}❌ Cancelled${RESET}"
    return
fi

# Apply changes
python3 << PYEOF
import sqlite3, time, json

db = "$DB_FILE"
days = $days
action = "$action"
target = "$target"
now_ms = int(time.time() * 1000)
delta_ms = days * 24 * 60 * 60 * 1000

conn = sqlite3.connect(db)
c = conn.cursor()
selected_id = "$SELECTED_INBOUND_ID"
if selected_id:
    c.execute("SELECT id, settings FROM inbounds WHERE id = ?", (int(selected_id),))
else:
    c.execute("SELECT id, settings FROM inbounds")
inbound_rows = c.fetchall()

total_updated = 0

for inbound_id, settings_str in inbound_rows:
    try:
        s = json.loads(settings_str)
        clients = s.get('clients', [])
        changed = False

        for cl in clients:
            exp = cl.get('expiryTime', 0) or 0
            if exp == 0:
                continue  # skip unlimited
            if target == "2" and action == "1" and exp >= now_ms:
                continue  # add mode option 2: skip non-expired
            if target == "3" and action == "1" and exp < now_ms:
                continue  # add mode option 3: skip expired (active only)
            if target == "2" and action == "2" and exp < now_ms:
                continue  # subtract mode: skip already expired

            if action == "1":
                new_exp = exp + delta_ms
            else:
                new_exp = max(0, exp - delta_ms)

            cl['expiryTime'] = new_exp

            # Enable/disable based on new expiry
            if new_exp > now_ms:
                cl['enable'] = True
            else:
                cl['enable'] = False

            # Update client_traffics too
            c.execute(
                "UPDATE client_traffics SET expiry_time = ?, enable = ? WHERE email = ?",
                (new_exp, 1 if new_exp > now_ms else 0, cl.get('email', ''))
            )

            total_updated += 1
            changed = True

        if changed:
            s['clients'] = clients
            c.execute("UPDATE inbounds SET settings = ? WHERE id = ?", (json.dumps(s), inbound_id))

    except Exception as e:
        print(f"  Error on inbound {inbound_id}: {e}")

conn.commit()
conn.close()
print(f"  Updated {total_updated} client(s) successfully.")
PYEOF

echo ""
echo -e "${YELLOW}🔄 Restarting X-UI to apply changes...${RESET}"
systemctl restart $SERVICE
sleep 2

if systemctl is-active --quiet $SERVICE; then
    echo -e "${GREEN}✅ Done! Changes applied and service restarted.${RESET}"
else
    echo -e "${RED}❌ Service failed to restart${RESET}"
fi
}

# =========================
# SET AUTOMATIC BACKUP
# =========================
auto_backup_xui() {

echo ""
echo -e "${BLUE}======================================"
echo "     SET AUTOMATIC BACKUP MODULE"
echo "======================================"
echo -e "${RESET}"

echo -e "${YELLOW}📋 Please enter backup configuration:${RESET}"
echo ""

read -p "📁 Local backup directory [/root/xui-backups]: " input_backup_dir
BACKUP_DIR="${input_backup_dir:-/root/xui-backups}"

echo ""
read -p "🌐 How many remote servers do you want to send backup to? [1]: " input_server_count
SERVER_COUNT="${input_server_count:-1}"

if ! [[ "$SERVER_COUNT" =~ ^[0-9]+$ ]] || (( SERVER_COUNT < 1 )); then
    echo -e "${RED}❌ Invalid number. Must be >= 1${RESET}"
    return
fi

# Collect info for each server
declare -a R_USERS R_HOSTS R_PASSES R_DIRS

for (( s=1; s<=SERVER_COUNT; s++ )); do
    echo ""
    echo -e "${BLUE}--- Remote Server $s of $SERVER_COUNT ---${RESET}"

    read -p "👤 Username [root]: " input_user
    R_USERS[$s]="${input_user:-root}"

    read -p "🌐 IP/Host: " R_HOSTS[$s]
    if [[ -z "${R_HOSTS[$s]}" ]]; then
        echo -e "${RED}❌ Host cannot be empty${RESET}"
        return
    fi

    read -p "🔑 Password: " R_PASSES[$s]
    if [[ -z "${R_PASSES[$s]}" ]]; then
        echo -e "${RED}❌ Password cannot be empty${RESET}"
        return
    fi

    read -p "📂 Remote backup directory [/root/xui-backups]: " input_dir
    R_DIRS[$s]="${input_dir:-/root/xui-backups}"
done

echo ""
read -p "⏱  Run every how many minutes? [30]: " input_interval
INTERVAL="${input_interval:-30}"

if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]] || (( INTERVAL < 1 )); then
    echo -e "${RED}❌ Invalid interval. Must be a number >= 1${RESET}"
    return
fi

# Write the backup script
SCRIPT_PATH="/root/xui-auto-backup.sh"

cat > "$SCRIPT_PATH" << EOF
#!/bin/bash
# X-UI Auto Backup Script
# Generated by xui-manager

DATE=\$(TZ="Asia/Tehran" date +%Y-%m-%d_%H-%M)
BACKUP_DIR="$BACKUP_DIR"

mkdir -p \$BACKUP_DIR

# Take local backup
cp /etc/x-ui/x-ui.db \$BACKUP_DIR/x-ui-\$DATE.db

# Keep only last 48 local backups
ls -t \$BACKUP_DIR | tail -n +49 | xargs -I {} rm -- \$BACKUP_DIR/{}

EOF

# Add a block for each remote server
for (( s=1; s<=SERVER_COUNT; s++ )); do
    cat >> "$SCRIPT_PATH" << EOF
# --- Remote Server $s: ${R_USERS[$s]}@${R_HOSTS[$s]} ---
REMOTE_USER_$s="${R_USERS[$s]}"
REMOTE_HOST_$s="${R_HOSTS[$s]}"
REMOTE_PASS_$s="${R_PASSES[$s]}"
REMOTE_DIR_$s="${R_DIRS[$s]}"

sshpass -p "\$REMOTE_PASS_$s" ssh -o StrictHostKeyChecking=no \$REMOTE_USER_$s@\$REMOTE_HOST_$s "mkdir -p \$REMOTE_DIR_$s"
sshpass -p "\$REMOTE_PASS_$s" rsync -az \$BACKUP_DIR/x-ui-\$DATE.db \$REMOTE_USER_$s@\$REMOTE_HOST_$s:\$REMOTE_DIR_$s/
sshpass -p "\$REMOTE_PASS_$s" rsync -az --delete \$BACKUP_DIR/ \$REMOTE_USER_$s@\$REMOTE_HOST_$s:\$REMOTE_DIR_$s/

EOF
done

chmod +x "$SCRIPT_PATH"
echo ""
echo -e "${GREEN}✅ Backup script created at:${RESET} $SCRIPT_PATH"

# Check sshpass installed
if ! command -v sshpass &>/dev/null; then
    echo -e "${YELLOW}⚠️  sshpass not installed. Installing...${RESET}"
    apt-get install -y sshpass 2>/dev/null || yum install -y sshpass 2>/dev/null || \
        echo -e "${RED}❌ Could not install sshpass. Please install it manually.${RESET}"
fi

# Set cronjob
CRON_JOB="*/$INTERVAL * * * * $SCRIPT_PATH >> /var/log/xui-auto-backup.log 2>&1"
( crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH" ; echo "$CRON_JOB" ) | crontab -

echo -e "${GREEN}✅ Cronjob set:${RESET} every $INTERVAL minute(s)"
echo ""
echo -e "${BLUE}======================================"
echo "🎉 AUTOMATIC BACKUP CONFIGURED"
echo "======================================"
echo -e "${RESET}"
echo -e "  ${GREEN}📁 Local dir:${RESET}    $BACKUP_DIR"
for (( s=1; s<=SERVER_COUNT; s++ )); do
    echo -e "  ${GREEN}🌐 Server $s:${RESET}     ${R_USERS[$s]}@${R_HOSTS[$s]}:${R_DIRS[$s]}"
done
echo -e "  ${GREEN}⏱  Interval:${RESET}     every $INTERVAL minute(s)"
echo -e "  ${GREEN}📝 Log file:${RESET}     /var/log/xui-auto-backup.log"
echo ""
}

# =========================
# MAIN LOOP
# =========================
while true; do

show_banner
show_menu

read -p "Select option: " choice

case $choice in
    1) install_xui ;;
    2) remove_xui ;;
    3) backup_restore_xui ;;
    4) update_xui ;;
    5) status_xui ;;
    6) enable_cmd ;;
    7) change_settings_xui ;;
    8) auto_backup_xui ;;
    9) manage_expiry_xui ;;
    0)
        echo -e "${RED}Exiting...${RESET}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option!${RESET}"
        sleep 1
        ;;
esac

echo ""
read -p "Press Enter to continue..."

done
