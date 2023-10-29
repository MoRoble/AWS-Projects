cat << EOF >> ~/.ssh/config
 
Host ${hostname}
  HostName ${hostname}
  IdentityFile ${identityfile}
  User ${user}

EOF

## copy these line of texts at top lines of config file 