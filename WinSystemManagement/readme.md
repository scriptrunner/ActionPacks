# Action Pack for Windows Server and Windows 10 Client Management 
Use cases for managing systems settings in Windows server and Windows 10 client. The general part is working on both systems. Special scripts for Windows servers can be found in the subdirectory server. The same applies to Windows 10 clients.

## [Apps](./Clients/Apps)

+ Add,get,mount,dismount,remove volume
+ Get/set default volume
+ Move,remove app package
+ Get app packages, logs, last error

## [BitLocker](./BitLocker)

+ Enable/disable BitLocker
+ Lock/unlock BitLocker
+ Suspend/resume BitLocker
+ Enable/disable/clear BitLocker auto unlock
+ Get BitLocker volumes
+ Add/backup/remove BitLocker key protector

## [Computer Restore](./Clients/ComputerRestore)

+ Enable/disable Computer restore
+ Restore Computer
+ Get/create Computer restore point

## [Defender](./Defender)

+ Get status of antimalware software on the computer
+ Get threat, threat catalog, threat detection
+ Remove threat
+ Add/get/set/remove preference
+ Start scan, offline scan
+ Update antimalware definitions 

## [Event logs](./EventLogs)

+ Create/remove an event log
+ Limit size of an event log
+ Write an event to an event log
+ Get/export/clear an event log
+ Get event log items
+ Unregister event source

## [Firewall](./Firewall)

+ Add/remove firewall rule
+ Get/set properties of a firewall rule
+ Enable/disable firewall rule
+ List of firewall rules

## [Local accounts](./LocalAccounts)

+ Get/set local group
+ Get/set local user
+ Create/remove local group
+ Create/remove local user
+ Enable/disable local user
+ Add/remove users to group
+ Get group members
+ Get user memberships

## [Network](./Network)

+ Get/reset DNS 
+ Register DNS client
+ Clear/get DNS cache
+ Get DNS client details
+ Get/set IP addresses
+ Get/set DNS IP addresses

## [Processes](./Processes)

+ Get process or list of processes
+ Start/stop a process

## [Remote Desktop](./RemoteDesktop)

+ Get user sessions
+ Remove user session
+ Enable/disable Remote Desktop

## [Reporting](./Reporting)

+ Enable/disable error reporting
+ Get the Windows Error Reporting status

## [Scheduled Tasks](./ScheduledTasks)

+ Get/set/unregister a scheduled task
+ Start/stop a scheduled task
+ Enable/disable a scheduled task
+ Export/import a scheduled task

## [Services](./Services)

+ New/remove service
+ Get/set a service
+ Start/stop/suspend/resume/restart a service

## [System](./System)

+ Ping computers
+ Get user profiles
+ Remove user profile
+ Restart/shut down computers
+ Get/set computer time zone
+ Get computer infos
+ Get Windows Update log 
+ Enable/disable Automatic Updates for Windows Update
+ Set User Account Control
+ Set explorer settings for users
+ Set auto logon settings
+ Get hot fixes
+ Get installed programs
+ Get PowerShell version
+ Clear Windows Update
+ Clear computer profiles
+ Clear recyle bin

## [Windows Server Backup](./Server/Backup)

+ Get backup files, sets, targets
+ Get disks, files, jobs, summary, volume
+ Get/set/remove policy
+ Get/set schedule
+ Remove backup set, file
+ Start backup, file recovery, volume recovery
+ Stop backup job

## [Reports](./_REPORTS_)
+ Generate report with services, processes, event log entries, firewall rules, hot fixes, installed programms
+ Generate report with restore points, scheduled tasks, user profiles 
+ Generate report with app last errors, app logs, app packages
+ Generate report with local groups, local users, user memberships, group members 
+ Generate report with BitLocker volumes, Defender threat detection, Defender threat catalog

## [Queries](./_QUERY_)

+ Search firewall rules on a client computer
+ Search DNS or IP interface aliases
+ Search event logs on a client computer
+ Search event log sources on a client computer
+ Search scheduled tasks on a client computer
+ Search services on a client computer
+ Search processes on a client computer
+ Search time zones on a client computer
+ Search BitLocker key protectors
+ Search user profiles

## [Library](./_LIB_)

+ Remove computer or server profile 
+ Remove old profiles