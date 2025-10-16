# Born2beRoot

Born2beRoot is a project from École 42 focusing on **configuring and securing a virtual machine without a user interface**. It offers hands-on immersion in system administration, from partitioning to service deployment. The goal is to become familiar with **system administration** and managing essential services.

## 1 - Installation

The VM was installed on Debian 12 “Bookworm.” After allocating resources, the installation involved:
- Choosing the language, time zone, and hostname.
- Configuring users and passwords, with creation of the main user.
- Partitioning: a primary ```/boot``` partition and an encrypted logical partition for LVM, with volumes dedicated to the ```/root, /home, /var, /srv, /tmp, /swap, and /var/log``` folders.
- Installation of the GRUB boot program only, without additional software.

This rather technical step lays the foundations for the secure infrastructure.

## 2 - Configuration

After the system update, the main configurations focused on:

### 2. 1 - Password policies

The ```libpam-pwquality``` library was used to enforce strong passwords and expiration rules, applicable to both existing and new users.

### 2. 2 - SUDO

The sudo configuration included:
- Limiting the number of password attempts.
- Logging commands and outputs.
- Defining a secure path for binaries.
- Adding the main user to the sudo group with full rights.

### 2.3 - UFW and SSH configuration

The UFW firewall has been enabled and the necessary ports authorized.
The SSH service has been configured to prohibit root access and listen on a custom port.

### 2.4 - Cron and monitoring script

A monitoring script, executed every 10 minutes via cron, provides a complete status of the VM: CPU, RAM, disk, network connections, sudo usage, and LVM information.


## 3 - Bonus part

### 3.1 - Wordpress site

WordPress was deployed on Lighttpd with MariaDB and the necessary PHP modules. Configuring file permissions, ports, and FastCGI modules was crucial for the site to function properly.



### 3.2 - Minecraft server

A Minecraft server has been installed as an optional service. All Java dependencies have been configured and resources limited to ensure VM stability. The server is accessible via port 25565, with the graphical interface disabled to reduce load.

![Screenshot_from_2023-07-29_00-22-53](https://github.com/rmnina/Born2beRoot/assets/118455014/2af5bba2-e845-4e30-be91-71c4a1065f9e)



## Conclusion

Born2beRoot has provided an introduction to:
- The command line and shell for comprehensive VM management.
- System security (passwords, sudo, firewall, SSH).
- Service and volume management, as well as automated monitoring.

The project provides an excellent foundation for approaching system administration and server management independently and securely, while putting rigor and best practices into practice.

