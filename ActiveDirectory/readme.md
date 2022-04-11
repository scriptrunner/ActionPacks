# Action Pack for Active Directory
Use cases for managing users, groups and computers in on prem AD
> Note: The use of the scripts requires the PowerShell Module ActiveDirectory.

## [Manage Computers](./Computers)

+ Get/Set properties of the computer
+ Create/remove computer
+ Enable/Disable Computer
+ Add/remove computers to groups
+ List of disabled computers
+ List of inactive computers

## [Manage Groups](./Groups)

+ Create/remove Active Directory group
+ Get/Set properties of the Active Directory group 
+ List of all Active Directory groups
+ List of members and sub groups of Active Directory group
+ List of Active Directory groups without members

## [Manage Users](./Users)

+ Create/copy/remove Active Directory user
+ Get/Set properties of the Active Directory user
+ Add/remove Active Directory users to Active Directory groups
+ Get memberships of the Active Directory user
+ Enable/Disable Active Directory account
+ Unlock/reset Active Directory account
+ Set the date when the Active Directory account expires
+ Remove Active Directory service account
+ List of Active Directory users whose account has expired, inactive, disabled or locked

## [Common](./Common)

+ Move an object to a different container

## [Reports](./_REPORTS_)

+ Generate report with users or computers with defined status
+ Generate report with user, computer or group properties
+ Generate report with group members
+ Generate report with user memberships

## [Queries](./_QUERY_)

+ Search users whose account has expired, inactive, disabled or locked
+ Search users

## [Library](./_LIB_)

+ Get domain object