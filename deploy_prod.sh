#!/bin/bash
set -euo pipefail

EC2_HOST="$1"
SSH_KEY_LOCAL="$2"
REPO_SSH="git@gitlab.com:Kalyanimishra_60120/cloud-deployment-pipeline.git"
REMOTE_USER="ubuntu"
REMOTE_SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

echo "Deploying to PRODUCTION on ${EC2_HOST}..."

# Copy private key to remote
scp $REMOTE_SSH_OPTS -i "$SSH_KEY_LOCAL" "$SSH_KEY_LOCAL" ${REMOTE_USER}@${EC2_HOST}:~/.ssh/id_rsa
ssh $REMOTE_SSH_OPTS -i "$SSH_KEY_LOCAL" ${REMOTE_USER}@${EC2_HOST} bash <<'REMOTE_EOF'
set -euo pipefail

APP_DIR="/var/www/prod-app"
REPO_SSH="git@gitlab.com:Kalyanimishra_60120/cloud-deployment-pipeline.git"

# secure ssh folder & key
mkdir -p ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa || true
ssh-keyscan gitlab.com >> ~/.ssh/known_hosts || true

# Wipe old directory and clone fresh
rm -rf "$APP_DIR"
git clone "$REPO_SSH" "$APP_DIR"
cd "$APP_DIR"

# Install dependencies
pip3 install --break-system-packages -r requirements.txt

# Restart production app (port 8080)
pkill -f "app/main.py --port=8080" || true
APP_ENV=production APP_PORT=8080 nohup python3 app/main.py --port=8080 > prod.log 2>&1 &
REMOTE_EOF

echo "Production deploy finished."
