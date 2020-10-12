# Hardening a base system

## Intro

MISP is a web-based **information sharing platform**, by design it is kept rather simple and hardening can be done by following the common best practices.

Bare in mind that neither the MISP documentation efforts or the core MISP project can give you the ultimate guide on how to harden your system.
This is not the purpose of the MISP Project but the purpose and care of those individuals and organizations deploying MISP Instances.

Nevertheless here is a very rough **food for thoughts** bulletpoint list for you to consider, and a list of some hardening ressources below.

- Are we using SSL by default? (Especially when syncing over the internet and exposing the API)
- How to we access the machine remotely? Via ssh? What is the path to get there? Does a [bastion host](https://en.wikipedia.org/wiki/Bastion_host) make sense?
- Is the machine shared with other user accounts? Do I need to care about useri-land security due to this sharing?
- Is the instance deployed in the "**cloud**"? Is it a VPS? AWS? docker? ansible? kubernetes? whateverCloudContainterMagicIsFancibleNow?
- Do we need to encrypt the partitions where some data is stored?
- Are we redundant in case one MISP instance might fail?
- Is the database server and any other servers running on the machine bound to **localhost**? Do we need to expose because our setup is more complex?
- Do we have enough storage? What about [MISP and size estimation](https://misp-project.org/MISP-sizer/) anyways?
- Do we care about BIOS updates?
- Do we care about physical access to the servers? (Disabling USB ports etc...)
- Is any fancy management engine à la [IME](https://en.wikipedia.org/wiki/Intel_Management_Engine) in use?

## Apache

To make Apache less verbose in terms of sending banners, the belo might help.

```
diff --git a/apache2/conf-available/security.conf b/apache2/conf-available/security.conf
index f9f69d4..2e8fd78 100644
--- a/apache2/conf-available/security.conf
+++ b/apache2/conf-available/security.conf
@@ -22,7 +22,7 @@
 # Set to one of:  Full | OS | Minimal | Minor | Major | Prod
 # where Full conveys the most information, and Prod the least.
 #ServerTokens Minimal
-ServerTokens OS
+ServerTokens Prod
 #ServerTokens Full
 
 #
@@ -33,7 +33,7 @@ ServerTokens OS
 # Set to "EMail" to also include a mailto: link to the ServerAdmin.
 # Set to one of:  On | Off | EMail
 #ServerSignature Off
-ServerSignature On
+ServerSignature Off
 
 #
 # Allow TRACE method
```

## Resources

[IT Security Guidelines for TLS by NCSC.nl](https://www.ncsc.nl/english/current-topics/factsheets/it-security-guidelines-for-transport-layer-security-tls.html)

[Weak Diffie-Hellman and the Logjam Attack](https://weakdh.org/sysadmin.html)

[Debian Wiki Hardening](https://wiki.debian.org/Hardening)

[CentOS Hardening](https://wiki.centos.org/HowTos/OS_Protection)

[Some Linux hardening tips](https://www.cyberciti.biz/tips/linux-security.html)
