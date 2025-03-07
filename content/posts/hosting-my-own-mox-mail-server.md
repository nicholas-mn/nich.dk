+++
date = '2025-03-07T21:06:44+01:00'
draft = false
title = 'Hosting My Own Mox Mail Server'
+++
# Intro

I have wanted to distance my self as much as possible from Big Tech (Google, Microsoft, etc.), so I have been using [mailbox.org](https://mailbox.org/en/) as my mail host for the past few years. No major complaints from me.

Recently, I was reading some articles on [Hacker News](https://news.ycombinator.com/) and stumbled upon Mox [[1](https://news.ycombinator.com/item?id=43261729), [2](https://www.xmox.nl/)] - a _modern, secure, all-in-one email server_.

I have always been afraid of hosting my own email server, due to all of the horror stories I’ve read about it online.
Primarily about how Outlook, Gmail and other bigger providers might silently reject my emails and how hard it is to keep up with security etc.

From what I could gather from the comments and the website, it looks like Mox solves most of the complexity issues and makes it easier to setup a complete email-suite - so I decided to give it a go!

(I was also attracted to the brutalist/minimalist design choices in the webmail/admin pages tbh)

# Setup

**BEWARE:** I was very confused doing my first run of this. I thought that you HAD to use the subdomain mail.example.com as the actual domain of your email, like so: _example@mail.example.com_.

Luckily, this is not the case! You can just use the subdomain to connect to IMAP and SMTP, and still get an email with your domain without a subdomain like so: _example@example.com_.

You just need to add the appropriate DNS entries, which I will do later in this post.

You can also use your subdomain if you want to.

## Setting up Debian Server
I spun up a new VPS on Hetzner

I then ran my trusty Ansible Debian Server setup script: `ansible-playbook -i hosts setup_debian.yml`
     
_setup_debian.yml_:
```yaml
---
- name: Setup Debian server, secure SSH, and change SSH port
  hosts: all
  become: yes
  vars:
    github_keys_url: https://github.com/nicholas-mn.keys
    new_user: user
    new_ssh_port: 1234

  tasks:
    - name: Create new user
      user:
        name: "{{ new_user }}"
        groups: sudo
        shell: /bin/bash
        create_home: yes

    - name: Install SSH keys for new user
      authorized_key:
        user: "{{ new_user }}"
        state: present
        key: "https://github.com/nicholas-mn.keys"

    - name: Secure SSH configuration and change port
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: "{{ item.regexp }}"
        line: "{{ item.line }}"
      loop:
        - { regexp: '^#?Port', line: 'Port {{ new_ssh_port }}' }
        - { regexp: '^PermitRootLogin', line: 'PermitRootLogin no' }
        - { regexp: '^PasswordAuthentication', line: 'PasswordAuthentication no' }
        - { regexp: '^X11Forwarding', line: 'X11Forwarding no' }
        - { regexp: '^MaxAuthTries', line: 'MaxAuthTries 3' }
      notify: Restart SSH

    - name: Ensure public key authentication is enabled
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: "^#?PubkeyAuthentication"
        line: "PubkeyAuthentication yes"
      notify: Restart SSH

    - name: Allow new user to use sudo without password
      lineinfile:
        path: /etc/sudoers
        state: present
        regexp: '^{{ new_user }}'
        line: '{{ new_user }} ALL=(ALL) NOPASSWD: ALL'
        validate: 'visudo -cf %s'

  handlers:
    - name: Restart SSH
      service:
        name: ssh
        state: restarted


```

_hosts_:
```ini
[mail.nich.dk]
88.198.127.102 ansible_user=root
```

I then made sure the hostname is correct.
* `sudo nano /etc/hostname`
  * Changed the content to _mail.nich.dk_, which is where users will access IMAP and SMTP
* `sudo nano /etc/hosts`
  * Changed first entry _127.0.1.1 oldhostname_ to _88.198.127.102 mail.nich.dk_ <- so it routes back to itself. It’s apparently for internal mail or something? Don’t take my word for it, I am completely new to mail hosting. Replace with your own public IP and domain (Your SMTP and IMAP subdomain, not your actual domain - or you can, if you plan to use it as the email domain as well).

I then installed Docker:
```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Add user to Docker group
sudo groupadd docker
sudo usermod -aG docker $USER
```


Lastly I restarted the machine: `sudo systemctl reboot`


## Setting up Mox

Fix DNSSEC errors
  * `sudo apt install unbound dns-root-data`

Create the Mox user:
  * `sudo su` <- switch to root
  * `useradd -d $PWD mox` <- will create mox user with the current directory as their home directory

Create the directory, which will contain all of the data and the docker compose file:
```bash
mkdir mox
cd mox
mkdir config data web
nano docker-compose.yml
```

_docker-compose.yml_:
```yaml
# Before launching mox, run the quickstart to create config files for running as
# user the mox user (create it on the host system first, e.g. "useradd -d $PWD mox"):
#
#	mkdir config data web
# 	docker-compose run mox mox quickstart you@yourdomain.example $(id -u mox)
#
# note: if you are running quickstart on a different machine than you will deploy
# mox to, use the "quickstart -hostname ..." flag.
#
# After following the quickstart instructions you can start mox:
#
# 	docker-compose up
#

services:
  mox:
    # Replace "latest" with the version you want to run, see https://r.xmox.nl/r/mox/.
    # Include the @sha256:... digest to ensure you get the listed image.
    image: r.xmox.nl/mox:latest
    environment:
      - MOX_DOCKER=yes # Quickstart won't try to write systemd service file.
    # Mox needs host networking because it needs access to the IPs of the
    # machine, and the IPs of incoming connections for spam filtering.
    network_mode: 'host'
    volumes:
      - ./config:/mox/config
      - ./data:/mox/data
      # web is optional but recommended to bind in, useful for serving static files with
      # the webserver.
      - ./web:/mox/web
    working_dir: /mox
    restart: always
    healthcheck:
      test: netstat -nlt | grep ':25 '
      interval: 1s
      timeout: 1s
      retries: 10
```

Run the quickstart: 
  * `docker compose run mox mox quickstart example@nich.dk $(id -u mox)` <- replace with your own domain

**MAKE SURE YOU READ THE OUTPUT CAREFULLY!!**
There is very important info. You will see various errors and important info here. The most important information that you will see is your admin and account login information. Save this somewhere!!

Paste the DNS entries shown in the output into your DNS Management Host (Like Cloudflare). I manage my domain and DNS with [Simply.com](https://www.simply.com/en/).

**BEWARE**: I overwrote my original DNS entries my first time around, oops! - see if there is an option in your DNS provider to add the entries without resetting DNS.

Wait for DNS to kick in - it took less than an hour for me.

Start the docker compose container: `docker compose up -d`

You can see logs with `docker compose logs`

Then login on devices. I use Thunderbird on desktop and mobile.

Profit?

[You can read more documentation here](https://www.xmox.nl/config/)

### Webmail

You can also access the built-in webmail by forwarding the remote port to your device like so:
  * `ssh -L 8080:localhost:80 -p 1234 user@ip/domain`
  * Then navigate to [http://localhost:8080/webmail/](http://localhost:8080/webmail/) and login with your details.

![Mox webmail](/mox-webmail.png "Mox webmail")

# What now?

You and I should probably read this [as recommended](https://www.xmox.nl/faq/#hdr-i-m-now-running-an-email-server-but-how-does-email-work) by Mox:
https://explained-from-first-principles.com/email/

We should probably also set up some backup solution, so we won’t lose our emails in case of server (or human) failure.

I will be running Mox for a while and do some testing. If it proves reliable, then I’ll switch over to it as my primary email solution.

See you around!