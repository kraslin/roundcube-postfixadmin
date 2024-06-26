# malfurious/roundcube-postfixadmin

![postfixadmin](http://i.imgur.com/UCtvKHR.png "postfixadmin") ![roundcube](https://raw.githubusercontent.com/Malfurious/docker-templates/master/images/roundcube-logo.jpg "roundcube")

### What is this ?

PostfixAdmin is a web based interface used to manage mailboxes, virtual domains and aliases. It also features support for vacation/out-of-the-office messages.
Roundcube Webmail is a browser-based multilingual IMAP client with an application-like user interface. It provides full functionality you expect from an email client, including MIME support, address book, folder management, message searching and spell checking. Roundcube Webmail is written in PHP and requires the MySQL, PostgreSQL or SQLite database. With its plugin API it is easily extendable and the user interface is fully customizable using skins which are pure XHTML and CSS 2.

#### Important Note
This docker was built to be used with malfurious/mailserver.
Goto https://github.com/Malfurious/mailserver for more information!

### Postfixadmin Features

- Lightweight & secure image (no root process)
- Based on Alpine Linux
- Latest Postfixadmin version (3.1)
- MySQL/Mariadb driver
- With PHP7
- Simple nginx server built-in for reverse proxy

### Roundcube Features
- Lightweight, based on Alpine Linux
- Latest Roundcube version (1.3.1)
- Simple nginx server built-in for reverse proxy

#### Roundcube Plugins:
- **Password Change Plugin configured for Postfixadmin**
- **Enigma Plugin enabled for email encryption, plus it stores your generated encryption keys server-side**
- **ManageSieve Plugin enabled, allowing custom filter scripts**
- **Emoticons Plugin enabled**
- **MarkAsJunk2 Plugin enabled**
- **Calendar Plugin by Kolab**
- **Tasklist Plugin by Kolab**
- **Persistent Login Plugin**
- **Google 2-factor Authenticator Plugin**
- **Identity SMTP Plugin**
- **Contextmenu Plugin**

### Ports (Configurable)

Roundcube:
- **8888**

Postfixadmin:
- **8080**

### Environment variables

| Variable | Description | Type | Default value |
| -------- | ----------- | ---- | ------------- |
| **UID** | postfixadmin user id | *optional* | 991
| **GID** | postfixadmin group id | *optional* | 991
| **MYSQL_HOST** | MariaDB instance ip/hostname | **required** | null
| **ROUND_USER** | MariaDB Roundcube username | *optional* | roundcube
| **ROUND_PASS** | MariaDB Roundcube password | **required** | null
| **ROUND_DB** | MariaDB Roundcube Database Name | **required** | roundcube
| **POST_USER** | MariaDB Postfix username | *optional* | postfix
| **POST_PASS** | MariaDB Postfix password | **required** | null
| **POST_DB** | MariaDB Postfix Database Name | *optional* | postfix
| **MAIL_HOST** | Mail Server Name | **required** | mail.domain.com
| **ENABLE_IMAPS** | Enable/Disable IMAPS (SSL) | *optional* | true
| **ENABLE_SMTPS** | Enable/Disable SMTPS (STARTTLS) | *optional* | true
| **DISABLE_INSTALLER** | Enable/Disable Roundcube Installer | *optional* | false
| **ROUNDCUBE_PORT** | Roundcube nginx listening port | *optional* | null
| **POSTFIX_PORT** | Postfixadmin nginx listening port | *optional* | null
| **PASS_CRYPT** | Passwords encryption method | *optional* | `SHA512-CRYPT`
| **TZ** | Used to set php's date.timezone | *optional* | none


### Installation

#### 1. Set required Environment Variables.
After looking at the above tabe, set variables as required. 
If running manually, be sure to add this extra parameter: --add-host mail.domain.com:xxx.xxx.xxx.xxx
Replace 'mail.domain.com' with your MAIL_HOST, and the 'xxx.xxx.xxx.xxx' with your MAIL_HOST's IP Address.
Then start the docker.

#### 2. Postfixadmin Setup: Goto http://[YOUR IP]:[POSTFIX PORT]/setup.php
![postfix1](https://raw.githubusercontent.com/Malfurious/docker-examples/master/roundcube-postfixadmin/Postfixadmin-1.PNG "postfix1")
Enter a long setup password in the first box, then confirm the password in the second. Click 'Generate password hash'
Something like: $CONF['setup_password'] = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'; should show up.
![postfix2](https://raw.githubusercontent.com/Malfurious/docker-examples/master/roundcube-postfixadmin/Postfixadmin-2.PNG "postfix2")
Run the following command on: 'docker exec -it <name of this docker container> setup'
![postfix3](https://raw.githubusercontent.com/Malfurious/docker-examples/master/roundcube-postfixadmin/Postfixadmin-3.PNG "postfix3")
Enter in the long string you got earlier (the long string of xxxxx as shown above), and hit enter. You should be greeted with a 'Setup done'
Now, back at the Postfixadmin screen you left, you can now create the superadmin account.
![postfix4](https://raw.githubusercontent.com/Malfurious/docker-examples/master/roundcube-postfixadmin/Postfixadmin-4.PNG "postfix4")
Once finished, you may login at: http://[YOUR IP]:[POSTFIX PORT]/login.php using the superadmin credentials.
Once logged in, create a new domain by going under 'Domain list', and selecting 'New domain'.
![postfix5](https://raw.githubusercontent.com/Malfurious/docker-examples/master/roundcube-postfixadmin/Postfixadmin-5.PNG "postfix5")
Fill in the domain you want to use (the last half of the 'mail.domain.com' used earlier), and click 'Add Domain'.
![postfix6](https://raw.githubusercontent.com/Malfurious/docker-examples/master/roundcube-postfixadmin/Postfixadmin-6.PNG "postfix6")
Now under 'Virtual List', you can add mailboxes to this domain, creating individual email accounts.
![postfix7](https://raw.githubusercontent.com/Malfurious/docker-examples/master/roundcube-postfixadmin/Postfixadmin-7.PNG "postfix7")
![postfix8](https://raw.githubusercontent.com/Malfurious/docker-examples/master/roundcube-postfixadmin/Postfixadmin-8.PNG "postfix8")
We are now done with setting up Postfixadmin for now.

#### 3. Roundcube Setup: Goto http://[YOUR IP]:[ROUNDCUBE PORT]/installer
Everything should say "OK" on the first screen, except:
- **SQLite**
- **SQLite (v2)**
- **SQL Server (SQLSRV)**
- **SQL Server (DBLIB)**
- **Oracle**
- **Net_LDAP3**
- **date.timezone**
![roundcube1](https://raw.githubusercontent.com/Malfurious/docker-examples/master/roundcube-postfixadmin/Roundcube-Setup-1.PNG "roundcube1")
### Hit "Next" at the bottom of the page.
Assuming you entered the MySQL Information correction, you should see a green "OK" next to "DSN (write)".
If so, click the initialize button.
![roundcube2](https://raw.githubusercontent.com/Malfurious/docker-examples/master/roundcube-postfixadmin/Roundcube-Setup-2.PNG "roundcube2")
Once done, feel free to test your connection to the mailserver by entering in mailbox credentials that you setup earlier while configuring Postfixadmin.
Hopefully, when tested, you will get a green 'OK' indicating its working.
If everything works, shutdown the container, and start back up with the DISABLE_INSTALLER variable set to 'true'.

#### Installation (Manually, not using UnRAID Template)
Run the following command to pull the latest image: 'docker pull malfurious/roundcube-postfixadmin:latest'
Now, Run this to start the docker:
```
docker run -d --name=roundcube-postfixadmin \
  -p 8888:8888 -p 8080:8080 --add-host mail.domain.com:127.0.0.1 \
  -e MAIL_HOST=mail.domain.com -e POST_USER=postfix -e POST_PASS=password \
  -e POST_DB=postfix -e MYSQL_HOST=mariadb_ipaddress -e ROUND_USER=roundcube \
  -e ROUND_PASS=password -e ROUND_DB=roundcube -e ENABLE_IMAPS=true -e ENABLE_SMTPS=true \
  -e DISABLE_INSTALLER=false -e PASS_CRYPT=sha512-crypt \
  -v /mnt/docker/enigma:/enigma malfurious/mailserver:latest
```
#### Setup Complete!

#### For a Guide on setting up a Reverse Proxy with SSL Certificates, follow the link below!
https://github.com/Malfurious/mailserver/wiki/Reverse-Proxy-Configuration
