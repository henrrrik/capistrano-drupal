# General

set :application, "mysite"
# Drupal site folder, TODO: multisite support
set :site, "default"

# Version control

set :scm, :git
set :repository,  "git@github.com:myaccount/myrepo.git"
set :repository_cache, "git_master"
set :deploy_via, :remote_cache
set :scm_verbose, true
set :keep_releases, 2
