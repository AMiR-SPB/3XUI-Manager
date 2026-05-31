<div align="center">
# 🚀 X-UI Manager Script


### ⚡ Powerful All-in-One Management Script for 3x-ui / X-UI

**Install • Update • Backup • Restore • Client Management • Automation**

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

Automatic detection is performed during installation and updates.

---

## 🔒 Security Recommendations

After the first login:

* 🔐 Change the default password
* 👤 Change the default username
* 🌐 Change the default port
* 🔗 Change the web path
* 🛡️ Restrict panel access when possible

**Never use default credentials on production servers.**

---

## 👨‍💻 Author

**AMiR SPB**

📨 Telegram:

```text
@Amir_SPB
```

---

## ❤️ Special Notes

This project was created to simplify X-UI management and reduce repetitive administrative tasks.

If this project helps you, consider giving it a ⭐ on GitHub.

---

## 📜 License

This project is provided **AS IS** without warranty.

Use at your own responsibility.

---

<div align="center">

### ⭐ Star the repository if you find it useful ⭐

</div>
