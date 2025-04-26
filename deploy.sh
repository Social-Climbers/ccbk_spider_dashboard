#!/bin/bash

# 1. Build the web app
flutter build web --release

# 2. Upload via FTP
lftp -u htongyai@socialclimbersapp.com,GoatFam789./ ftp://ftp.socialclimbersapp.com <<EOF
set ssl:verify-certificate no
mirror -R build/web .
quit
EOF

echo "✅ Deployment finished!"
