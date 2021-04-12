# Action Pack for Citrix
Use cases for managing users, groups and computers in on prem AD
> Note: The use of the scripts requires the PowerShell Module ActiveDirectory.

## [Administration](./Administration)

+ New, add, get, remove users
+ New, get, set, rename, remove role
+ Get, create or update, remove role metadata 
+ Add, get, remove role permissions
+ New, get, set, rename, remove scope
+ Get, create or update, remove scope metadata
+ New, get, set, remove administrators
+ Get, create or update, remove administrators metadata  
+ Add, remove admin rights
+ Add, new, get, set, rename, remove tags
+ Get, disconnect, stop sessions
+ Get service, service status, service capabilities
+ Get, create or update, remove service metadata 
+ Get controller
+ Get, create or update, remove controller metadata 
+ Get, import role configuration
+ Get permission groups, admin effective rights, users effective administrator objects
+ Refresh enabled features
+ Tests the operations is permitted

## [Applications](./Applications)

+ New, get, set, rename, remove catalog
+ Add, get, set, rename, remove desktop group
+ Add, new, get, set, rename, remove application group
+ New, get, move, rename, remove application folder
+ Add, new, get, set, move, rename, remove application
+ Add, remove application from group
+ Get, create or update, remove catalog metadata 
+ Get, create or update, remove desktop group metadata 
+ Get, create or update, remove application group metadata 
+ Get, create or update, remove application folder metadata 
+ Get, create or update, remove application metadata 
+ Test application name available, desktop group name available, application group name available
+ Test Broker Database connection

## [Licenses](./Licenses)

+ Import License file
+ Get License Server Info, License Inventory Data, License localized names
+ Get certificate, usage details, renewals
+ Add, get, set, remove License administrator
+ Get, set CEIP option
+ Get, set Customer Success Services renewal license check option
+ Get, set collect samples of license usage
+ Test License server

## [Logging](./Logging)

+ Export Log Report as csv or html file
+ Get log summary, list of all available database schema versions
+ Get high level operations, low level operations
+ Get log service, service instance, service status
+ Get, reset data store
+ Get, set log site
+ Get, set, remove log service metadata
+ Get, set, remove log site metadata
+ Get, set, test log database connection
+ Refresh of enabled features
+ Reload access permissions and configuration for the ConfigurationLogging Service
+ Remove log operation
+ Test Log Database connection

## [Sites](./Sites)

+ Get, set site
+ Get, create or update, remove site metadata
+ New, get, set, rename, remove zone
+ New, get, set, remove zone users
+ Get, create or update, remove zone metadata

## [Reports](./_REPORTS_)

+ Report with high level operations, with low level operations
+ Report with license inventory

## [Queries](./_QUERY_)

+ Get catalogs, desktop groups, permission groups
+ Get applications, application groups
+ Get scopes, roles, service
+ Get zones, zone users
+ Get sessions
+ Get high level operation ids

## [Library](./_LIB_)

+ Start/close Citrix session
+ Get license location
+ Get license certificate
+ Start/stop logging