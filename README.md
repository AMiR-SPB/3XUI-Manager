# X-UI Manager Script

A powerful all-in-one Bash management script for **3x-ui / X-UI** servers.

Developed to simplify installation, updating, backup management, client administration, and daily maintenance of X-UI panels.

---

## Features

### Installation

* Install 3x-ui from local `.tar.gz` package
* Automatic architecture detection
* Automatic service setup and enable on boot
* Automatic GeoIP & GeoSite installation
* Displays panel URL and default credentials after installation

### Update System

* Safe update process
* Automatic database backup before update
* Option to:

  * Keep existing users and inbounds
  * Start with a fresh database
* Automatic rollback if update fails

### Backup & Restore

* Full backup
* Database-only backup
* Full restore
* Database-only restore
* Backup archive management

### Automatic Backup Module

* Scheduled backups using Cron
* Local backup storage
* Remote backup synchronization
* Multiple remote server support
* Automatic cleanup of old backups
* Rsync-based transfer

### Service Management

* Service status monitoring
* Startup status check
* Uptime information
* Last service logs
* Panel information display

### Panel Settings Management

Change directly from terminal:

* Panel Port
* Username
* Password
* Web Path

No manual database editing required.

### Client Management

Manage all users directly from X-UI database.

#### Expiry Management

* Add days to clients
* Subtract days from clients
* Apply to:

  * All clients
  * Active clients
  * Expired clients

#### Traffic Management

* Add traffic quota (GB)
* Subtract traffic quota (GB)
* Apply to:

  * All clients
  * Active clients
  * Limited clients

#### Inbound Selection

* Single inbound
* All inbounds

### CLI Integration

Enable global command:

```bash
x-ui
```

Access the official X-UI management script from anywhere.

### Full Removal

* Complete uninstall
* Optional backup before removal
* Service cleanup
* Database cleanup
* Log cleanup
* Optional reboot

---

## Requirements

* Debian / Ubuntu
* Root access
* Bash
* Python3
* Systemd

Optional:

* sshpass
* rsync

---

## Installation

Download the script:

```bash
wget https://raw.githubusercontent.com/YOUR_USERNAME/xui-manager/main/xui-manager.sh
chmod +x xui-manager.sh
./xui-manager.sh
```

---

## Menu

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

## Supported Architectures

* AMD64
* ARM64
* ARMv7

Automatic detection is performed during installation and update.

---

## Security Notice

After first login:

* Change default username
* Change default password
* Change panel port
* Change web path

Never keep default credentials on a production server.

---

## Author

**AMiR SPB**

Telegram:

```text
@Amir_SPB
```

---

## License

This project is provided as-is without warranty.

Use at your own risk.
