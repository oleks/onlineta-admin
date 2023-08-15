dnl -*- mode: conf-unix -*-
dnl vim: filetype=systemd

[Unit]
Description=OnlineTA Grading Server
After=network.target

[Service]
User=COURSE_NAME
Group=www-data
WorkingDirectory=/home/COURSE_NAME
ExecStart=/home/COURSE_NAME/bin/testserver
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=COURSE_NAME-testserver
Environment="PATH=/home/COURSE_NAME/.local/bin:/home/COURSE_NAME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

[Install]
WantedBy=multi-user.target
