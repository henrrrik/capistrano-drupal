## Staging server settings

set :branch, "master"

role :web, "server.example.com", :primary => true
#role :db, "db.example.com", :primary => true
set :user, "deploy"
#  set :password, ""
set :remote_mysqldump, "/usr/bin/mysqldump"
set :deploy_to, "/mnt/persist/www/docroot/#{application}"

set :db_user, ""
set :db_password, ""
set :db_name, ""
# Address relative to the :web server
set :db_host, "localhost"

set :drush, "/usr/local/drush/drush"
set :use_sudo, false
