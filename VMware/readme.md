# Action Pack for VMware 
Use cases for managing vCenter/ESXi Server, Virtual Machines and more

> Note: The use of the scripts requires the PowerShell Module VMware.PowerCLI.

## [Administration](./Administration)

+ Import/export auto deploy state

## [Cluster](./Cluster)

+ Get/set a cluster
+ Add/move/remove a cluster
+ Add, get, set, move, remove datastore cluster

## [Datacenters](./Datacenter)

+ Get/set a datacenter
+ Add/move/remove a datacenter

## [Datastores](./Datastore)

+ Get/set a datastore
+ Add/remove a datastore

## [Disks](./Disks)

+ Get/set a hard disk
+ Add/copy/move/remove a hard disk
+ Add/get/set a SCSI controller
+ Add, get, set, copy, move, remove VDisk

## [Drives](./Drives)

+ Get/set a floppy drive
+ Add/remove a floppy drive
+ Get/set a CD drive
+ Add/remove a CD drive
+ Get/remove a USB device

## [Folders](./Folder)

+ Get/set a folder
+ Add/move/remove a folder

## [Host](./Host)

+ Get/set a host
+ Add/move/remove a host
+ Get/set a host user account
+ Add/remove a host user account
+ Get/set a host firewall default policy
+ Get/set a host firewall exception
+ Get/set hosts firmware settings
+ Get/set hosts Sphere logs, log types
+ Get/set hosts firmware settings
+ Get/set a host network adapter
+ Add/remove a host network adapter
+ Start/suspend/restart/stop a host
+ Get/set a host profile
+ Get/set start policy
+ Export/import a host profile
+ Add/invoke/remove a host profile
+ Test host profile compliance
+ Invoke a command
+ Get hardware informations
+ Get/set host storages
+ Get/start/stop/restart host services
+ Get/format host disk partitions
+ Get/set host diagnostic partition
+ Get host disks
+ Get PCI devices
+ Get/add routes from the routing table
+ Get, install host patches
+ Get host profile required input

## [Network](./Network)

+ Get/set a virtual network adapter
+ Add/remove a virtual network adapter
+ Get virtual port groups
+ Get distributed switches

## [Patches](./Patches)

+ Copy, get, sync patches

## [PowerCLI](./PowerCLI)

+ Get/set a PowerCLI configuration
+ Get a PowerCLI version

## [Resource Pools](./ResourcePool)

+ Get/set a resource pool
+ Add/remove a resource pool

## [Specifications](./Specifications)

+ New, get, set, copy, remove OS customization specifications

## [Tasks](./Tasks)

+ Get history tasks
+ Get/Stop a task

## [Templates](./Templates)

+ Create a new virtual machine template
+ Convert/clone/register/remove a virtual machine template
+ Get/set a virtual machine template

## [Tags](./Tags)

+ Get, set, new, remove tag category
+ Get, set, new, remove tag
+ Get, new, remove tag assignment

## [Virtual switches](./VirtualSwitch)

+ Get/set a virtual switch
+ Add/remove a virtual switch

## [Virtual machines](./VMs)

+ Get/set a virtual machine
+ Add/move/clone/create from template/remove a virtual machine
+ Start/suspend/restart/stop a virtual machine
+ New/remove/get/set snap shot
+ Restore a virtual machine
+ Register a virtual machine
+ New/clone/create from template/register a virtual machine on a cluster
+ Get/set start policy
+ Install/update/mount/dismount tools
+ Get guest system
+ Start/suspend/restart/stop a guest system
+ Run a script in the guest OS of a virtual machine
+ Get/set resource configuration
+ Copies guest system files and folders 

## [VMware Server](./Server)

+ Get available time zones, counters, topologies
+ Get inventory items
+ Get server properties
+ Get statistical informations
+ Exposes the ESXCLI functionality

## [Reports](./_REPORTS_)

+ Report all available patches
+ Report all host patches

## [Queries](./_QUERY_)

+ Search host IDs or names
+ Search resource pool IDs or names
+ Search virtual switches IDs or names
+ Search virtual machine IDs or names
+ Search disk IDs, paths or names
+ Search VDisks
+ Search running or queued tasks
+ Search available folders
+ Search available network adapters, virtual networks
+ Search available host accounts
+ Search available host network adapters
+ Search available datastore IDs or names
+ Search available datacenter IDs or names
+ Search snap shot IDs or names
+ Search available port groups
+ Search available guest system IDs
+ Search the names of then time zones available on the specified host
+ Search the names of the SCSI controllers
+ Search information about a host services
+ Search templates, clusters, datastore clusters

## [Library](./_LIB_)