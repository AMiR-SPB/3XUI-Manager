<div align="center">

### 🚀 X-UI Manager Script

![Bash](https://img.shields.io/badge/Bash-Script-green)
![Linux](https://img.shields.io/badge/Linux-Debian%20%7C%20Ubuntu-blue)
![Version](https://img.shields.io/badge/Version-1.0-orange)
![Maintained](https://img.shields.io/badge/Maintained-Yes-brightgreen)

</div>

> ⚡ Powerful all-in-one management script for **3x-ui / X-UI** servers.

<div align="center">

### 🛠️ Install • Update • Backup • Restore • Automation • Client Management

Developed with ❤️ by **AMiR SPB**

</div>

---

## ✨ Features

### 📦 Installation

* ✅ Install 3x-ui from local `.tar.gz` package
* ✅ Automatic CPU architecture detection
* ✅ Automatic systemd service configuration
* ✅ Automatic GeoIP & GeoSite installation
* ✅ Displays panel URL and login information after installation

---

### 🔄 Update System

* ✅ Safe update process
* ✅ Automatic database backup before update
* ✅ Keep existing users and inbounds
* ✅ Fresh database installation option
* ✅ Automatic rollback if update fails

---

### 💾 Backup & Restore

#### 📥 Backup

* Full Backup
* Database Only Backup
* Compressed Archive Generation

#### ♻️ Restore

* Full Restore
* Database Only Restore
* Automatic Service Restart

---

### ☁️ Automatic Backup Module

* 📅 Scheduled backups via Cron
* 📁 Local backup storage
* 🌐 Remote backup synchronization
* 🖥️ Multi-server backup support
* 🧹 Automatic old backup cleanup
* ⚡ Rsync-based transfers

---

### 📊 Service Monitoring

View directly from the terminal:

* 🟢 Service Status
* 🔁 Auto Start Status
* ⏱️ Uptime Information
* 📜 Last Log Entries
* 🌍 Panel Information
* 👤 Username
* 🔗 Web Path
* 🚪 Port Information

---

### ⚙️ Panel Settings Management

Manage your panel without editing databases manually:

* 🌐 Change Port
* 👤 Change Username
* 🔐 Change Password
* 🔗 Change Web Path
* ♻️ Automatic Service Restart

---

### 👥 Advanced Client Management

Manage users directly from the X-UI database.

#### 📅 Expiry Management

* ➕ Add Days
* ➖ Subtract Days
* 🎯 Apply to Expired Clients
* 🎯 Apply to Active Clients
* 🎯 Apply to All Clients

#### 📦 Traffic Management

* ➕ Add Volume (GB)
* ➖ Subtract Volume (GB)
* 🚫 Skip Unlimited Users
* 📊 Active Client Filtering
* 📊 Limited Client Filtering

#### 📡 Inbound Selection

* Single Inbound
* All Inbounds
* Smart Client Detection

---

### 💻 CLI Integration

Enable the official X-UI command globally:

```bash
x-ui
```

Access the X-UI management menu from anywhere in the terminal.

---

### 🗑️ Full Removal

* 🛑 Stop Service
* ❌ Remove X-UI Files
* ❌ Remove Databases
* ❌ Remove Logs
* ❌ Remove Service Files
* 💾 Optional Backup Before Removal
* 🔄 Optional Reboot

---

## 🖥️ Requirements

### Supported Systems

* ✅ Debian
* ✅ Ubuntu
* ✅ Other Systemd-based Linux Distributions

### Required Packages

* Bash
* Python3
* Systemd

### Optional Packages

* sshpass
* rsync

---

## 🏗️ Installation

```bash
wget https://raw.githubusercontent.com/AMiR-SPB/xui-manager/main/xui-manager.sh

chmod +x xui-manager.sh

./xui-manager.sh
```

---

## 📋 Main Menu

```text
1) Install 3x-ui
2) Full Remove 3x-ui
3) Manual Backup & Restore
4) Update 3x-ui
5) Service Status
6) Enable CLI Command
7) Change Panel Settings
8) Set Automatic Backup
9) Client Management
0) Exit
```

---

## 🧠 Supported Architectures

| Architecture | Supported |
| ------------ | --------- |
| AMD64        | ✅         |
| ARM64        | ✅         |
| ARMv7        | ✅         |

Automatic architecture detection is performed during installation and updates.

---

## 🔒 Security Recommendations

After first login:

* 🔐 Change default password
* 👤 Change default username
* 🌐 Change panel port
* 🔗 Change web path
* 🛡️ Restrict panel access when possible

> ⚠️ Never keep default credentials on production servers.

---

## 👨‍💻 Author

**AMiR SPB**

📨 Telegram: **@Amir_SPB**

---

## ❤️ Why This Script?

Managing X-UI servers manually can be repetitive and time-consuming.

This project was built to automate common administrative tasks and provide a clean interactive interface for server administrators.

Whether you're managing a single server or multiple production nodes, X-UI Manager helps reduce maintenance time and simplify operations.

---

## ⭐ Support

If you find this project useful:

⭐ Star the repository

🔄 Share it with others

🐛 Report issues and suggest improvements

---

## 📜 License

This project is provided **AS IS** without warranty.

Use at your own responsibility.

---

<div align="center">

### 🚀 Made with ❤️ by AMiR SPB

⭐ Star the repository if you find it useful ⭐

</div>
