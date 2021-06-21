# OpenSSH preparations

Do the following steps to prepare your machines for using OpenSSH.

## Install and configure ssh at Linux (Ubuntu 16.04.2 LTS)

- Install openssh client and server

```bash
sudo apt-get install openssh-client
sudo apt-get install openssh-server
```

- Edit the sshd_config file at location /etc/ssh
  - Make sure password authentication is enabled
  - Optionally enable key authentication

```config
...
PubkeyAuthentication yes
...
PasswordAuthentication yes
...
```

- Restart sshd service

```bash
sudo /etc/init.d/ssh restart
# or
sudo service ssh restart
```

## Install OpenSSH at Windows

- Download and install [OpenSSH Release from GitHub](https://github.com/PowerShell/Win32-OpenSSH/releases), if required

- Generate a public/private rsa key pair for the windows user that will connect to the remote host.

```powershell
ssh-keygen -t rsa -b 2048
Generating public/private rsa key pair.
Enter file in which to save the key (C:\Users\my.username/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in C:\Users\my.username/.ssh/id_rsa.
Your public key has been saved in C:\Users\my.username/.ssh/id_rsa.pub.
```

- Copy the public key to the remote host using SSH

```powershell
cat ~/.ssh/id_rsa.pub | ssh my.username@remote_host "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

## References

- [SSH key-based authentication](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server)
- [OpenSSH Release from GitHub](https://github.com/PowerShell/Win32-OpenSSH/releases)
