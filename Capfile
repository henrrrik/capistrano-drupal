load 'deploy' if respond_to?(:namespace) # cap2 differentiator
require 'railsless-deploy'
load 'config/deploy'

# Multistage, add more stages as needed.
set :stages, %w(staging production)

# Optionally set a default stage
#set :default_stage, "testing"
require 'capistrano/ext/multistage'

# Drupal deployment

after 'deploy:setup', 'drupal:setup'
after 'deploy:setup', 'drupal:createconfig'
before 'deploy:symlink', 'drupal:symlink'
after 'deploy:update_code', 'drupal:settings'
after 'deploy:update_code', 'drupal:dump'
after 'deploy', 'drupal:finalize'
after 'deploy', 'drupal:cacheclear'
after 'deploy:rollback', 'drupal:rollback'
after 'deploy:cleanup', 'drupal:cleanup'


# Drupal-specific stuff

namespace :drupal do
  task :setup, :roles => :web, :except => { :no_release => true } do
    run "mkdir -p #{shared_path}/files"
    run "chmod a+w #{shared_path}/files"
    run "mkdir -p #{deploy_to}/dumps"
    run "mkdir -p #{shared_path}/config"
  end

  # Create settings.php in shared/config (Drupal 7)
  task :createconfig, :roles => :web do
    configuration = <<-EOF
<?php

$databases['default']['default'] = array(
  'driver'   => 'mysql',
  'database' => '#{db_name}',
  'username' => '#{db_user}',
  'password' => '#{db_password}',
  'host'     => '#{db_host}',
  'prefix'   => '',
);
EOF
    put configuration, "#{deploy_to}/#{shared_dir}/config/local_settings.php"
  end
  
  # Create a symlink from the latest release to the shared files directory
  task :symlink, :roles => :web, :only => { :primary => true }, :except => { :no_release => true } do
    run "ln -s #{shared_path}/files #{latest_release}/sites/#{site}/files"
  end

  # Copy and rename the stage specific settings file to sites/<sitename>/settings.php
  task :settings, :roles => :web do
    source = "#{latest_release}/sites/#{site}/settings.#{stage}.php"
    dest = "#{latest_release}/sites/#{site}/settings.php"
    run "cp #{source} #{dest}"

    source = "#{latest_release}/#{stage}.htaccess"
    dest = "#{latest_release}/.htaccess"
    run "cp #{source} #{dest}"

    source = "#{latest_release}/#{stage}.robots.txt"
    dest = "#{latest_release}/robots.txt"
    run "cp #{source} #{dest}"
   end

  task :finalize, :roles => :web do
    # Unprotect the site folder for the previous release
    if previous_release then
      run "chmod a+w #{previous_release}/sites/#{site}"
    end
    # Protect the site folder for the new release
    run "chmod a-w #{latest_release}/sites/#{site}"
  end

  ## Dump a DB backup for the old release in case we need to roll back.
  task :dump, :roles => :web, :only => { :primary => true } do
    if previous_release then 
      filename = "#{releases[-2]}.dump.sql"
      
      # Make sure we don't have a dump with the same name from a failed deployment.
      if remote_file_exists?("#{deploy_to}/dumps/#{filename}") then
        run "rm -f #{deploy_to}/dumps/#{filename}"
      end

      run "#{drush} --uri=#{site} --root=#{previous_release} sql-dump --skip-tables-key=common > #{deploy_to}/dumps/#{filename}"
      run "cd #{deploy_to}/dumps; gzip #{filename}"
    end
  end

  desc "Flush the Drupal cache system."
  task :cacheclear, :roles => :web, :only => { :primary => true } do
    run "#{drush} --uri=#{site} --root=#{current_path} cache-clear all"
  end

  desc "Set Drupal maintainance mode to online."
  task :enable, :roles => :web, :only => { :primary => true } do
    run "#{drush} --uri=#{site} --root=#{current_path} variable-set --always-set site_offline 0"
  end

  desc "Set Drupal maintainance mode to off-line."
  task :disable, :roles => :web, :only => { :primary => true } do
    run "#{drush} --uri=#{site} --root=#{current_path} variable-set --always-set site_offline 1"
  end

    desc "Revert all enabled feature modules."
  task :revert, :roles => :web, :only => { :primary => true } do
    run "#{drush} --uri=#{site} --root=#{current_path} features-revert-all -y"
  end

  desc "Execute the update.php process."
  task :update, :roles => :web, :only => { :primary => true } do
    run "#{drush} --uri=#{site} --root=#{current_path} updatedb -y"
  end

  # When rolling back, restore the database too
  task :rollback, :roles => :web, :only => { :primary => true } do
    if previous_release then
      # Roll back database
      filename = "#{releases[-2]}.dump.sql"
      run "cd #{deploy_to}/dumps; gunzip #{filename}.gz"
      run "(#{drush} --uri=#{site} --root=#{previous_release} sql-connect) < #{deploy_to}/dumps/#{filename}"    
      # We need to rename the DB dump so that we can create a fresh dump for this release when deploying the next release.
      backup_filename = "#{releases[-2]}-#{Time.now.utc.strftime("%Y%m%d%H%M%S")}.dump.sql"
      run "cd #{deploy_to}/dumps; mv #{filename} #{backup_filename}; gzip #{backup_filename}"

      # Protect site folder
      run "chmod a-w #{previous_release}/sites/#{site}"
    end
  end

  # When running deploy:cleanup, also remove stale DB dumps
  task :cleanup, :roles => :web, :only => { :primary => true }, :except => { :no_release => true } do
    count = fetch(:keep_releases, 5).to_i
    if count < releases.length
      dumps = (releases - releases.last(count)).map { |release|
        "#{release}*.sql.gz" }.join(" ")

      run "cd #{deploy_to}/dumps; rm #{dumps}"
    end
  end
end

def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

