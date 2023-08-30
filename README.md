this repository contains a playbook, and a web server with a chat.

the server:
    to loadup the server we need to run server.sh,
    that is a bash script that contains a handler function for the client's http requests.
    the script also uses netcat to listen to those requests and netcat calls the handler over and over to keep listening to all communication in port 3000.


the playbook:
    can reconfigure your server for you, does the following actions:
        - installs packages (git, docker, bind-utils)
        - adds a admin user to the system
        - disable root ssh auth
        - turns on the firewall
        - turns on SELinux
        - creates a directory and mounts a nfs on it
        - increases the open file limit (os-wide)
        - increases the tcp buffer allowed open ports (1024 to 65000)
        - set TCP r/w memory to 2mb
