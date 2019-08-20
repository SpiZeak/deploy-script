#
# Author: Max Trewhitt - Osolo
# Description: A safe deployment routine script
#

# Stop script on error signal
set -e

# Go to web root directory
cd /var/www

# Remove old deployment folders
if [ -d "example.com_deploy" ]; then
  rm -R example.com_deploy
fi

# Create separate deployment folder
cp -R example.com example.com_deploy

# Go to deployment folder
cd example.com_deploy

#
# Initiate build sequence
#

# Reset workspace and pull latest commit
git fetch --all
git reset --hard origin/master
git clean -fd

# Remove vendor folder
if [ -d "vendor" ]; then
  rm -R vendor
fi

# Install project dependencies
composer install --no-interaction --prefer-dist --optimize-autoloader

# Build vendor assets in main theme
cd /var/www/example.com_deploy/web/app/themes/exampletheme
composer install --no-interaction --prefer-dist --optimize-autoloader
npm install
npm run build:production

# Go to web root directory
cd /var/www

# Remove backup
if [ -d "example.com_backup" ]; then
  rm -R example.com_backup
fi

# Switch (downtime in microseconds)
mv example.com example.com_backup
mv example.com_deploy example.com

# Restart PHP service to clear cache
sudo service php7.2-fpm reload
