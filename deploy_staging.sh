#!/bin/bash
set -euo pipefail

EC2_HOST="$1"
SSH_KEY_LOCAL="$2"
REPO_SSH="${3:-git@gitlab.com:Kalyanimishra_60120/cloud-deployment-pipeline.git}"
REMOTE_USER="ubuntu"
REMOTE_SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

echo "Deploying to STAGING on ${EC2_HOST}..."

#Copy the SSH key to the remote
scp $REMOTE_SSH_OPTS -i "$SSH_KEY_LOCAL" "$SSH_KEY_LOCAL" ${REMOTE_USER}@${EC2_HOST}:~/.ssh/id_rsa
ssh $REMOTE_SSH_OPTS -i "$SSH_KEY_LOCAL" ${REMOTE_USER}@${EC2_HOST} bash <<'REMOTE_EOF'
set -euo pipefail

APP_DIR="/var/www/staging-app"
REPO_SSH="git@gitlab.com:Kalyanimishra_60120/cloud-deployment-pipeline.git"

# secure ssh folder
mkdir -p ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa || true

# Ensure gitlab host key known
ssh-keyscan gitlab.com >> ~/.ssh/known_hosts || true

# Wipe old directory and clone fresh
rm -rf "$APP_DIR"
git clone "$REPO_SSH" "$APP_DIR"
cd "$APP_DIR"

# Install dependencies
pip3 install --break-system-packages -r requirements.txt

# Restart staging app (port 5000)
pkill -f "app/main.py --port=5000" || true
APP_ENV=staging APP_PORT=5000 nohup python3 app/main.py --port=5000 > staging.log 2>&1 &
REMOTE_EOF

echo "Staging deploy finished."
