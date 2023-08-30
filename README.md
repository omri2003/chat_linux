this repository contains a playbook that can reconfigure your server for you with ease
the playbook does the following actions:
    - installs packages (git, docker, bind-utils)
    - adds a admin user to the system
    - disable root ssh auth
    - turns on the firewall
    - turns on SELinux
    - creates a directory and mounts a nfs on it
    - increases the open file limit (os-wide)
    - increases the tcp buffer allowed open ports (1024 to 65000)
    - set TCP r/w memory to 2mb
