 #!/bin/bash
export HOME=/home/ec2-user
sudo yum update -y
# Install git
sudo yum install git -y
# Install curl
sudo yum install curl -y
# Install npm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install 13.0.0
# Download repo 
git clone https://github.com/timeoff-management/application.git timeoff-management
# Run application
cd timeoff-management
npm install 
npm run start&