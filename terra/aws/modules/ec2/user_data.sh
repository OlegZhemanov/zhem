#!/bin/bash

# Update package list
sudo apt-get update

# S3 bucket mount script 
cd /home/ubuntu
mkdir -p tmp
cd tmp
wget https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.deb 
sudo apt-get install -y ./mount-s3.deb
mount-s3 --version

# Create S3 mount directory with proper permissions
mkdir -p /home/ubuntu/mnt/S3_storage
sudo chown ubuntu:ubuntu /home/ubuntu/mnt/S3_storage
sudo chmod 755 /home/ubuntu/mnt/S3_storage

# Mount S3 bucket as ubuntu user with proper permissions
sudo -u ubuntu mount-s3 ${s3_bucket_name} /home/ubuntu/mnt/S3_storage --allow-delete --allow-overwrite

# Create a script to remount S3 on boot
sudo tee /home/ubuntu/mount-s3-on-boot.sh > /dev/null <<'EOF'
#!/bin/bash
# Wait for network to be ready
sleep 30
# Mount S3 bucket
/usr/bin/mount-s3 ${s3_bucket_name} /home/ubuntu/mnt/S3_storage --allow-delete --allow-overwrite
EOF

sudo chmod +x /home/ubuntu/mount-s3-on-boot.sh
sudo chown ubuntu:ubuntu /home/ubuntu/mount-s3-on-boot.sh

# Add to ubuntu user's crontab for persistence
sudo -u ubuntu bash -c 'echo "@reboot /home/ubuntu/mount-s3-on-boot.sh" | crontab -'

rm -rf /home/ubuntu/tmp