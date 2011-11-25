# Capistrano deployment scripts for Drupal

##Getting started

You need capistrano itself, capistrano-ext for multistage deployment and
railsless-deploy for convenient overrides.

    gem install capistrano capistrano-ext railsless-deploy

##Configuration

`config/deploy.rb` - general configuration settings

`config/deploy/<stagename>.rb` - stage-specific settings

It expects the following files for each stage:

    sites/<site>/settings.<stage>.php
    <stage>.robots.txt
    <stage>.htaccess

`.htaccess`, `settings.php` and `robots.txt` should be in your
`.gitignore`. That way each team member can have their own local
development setup.


##Usage

Set up the deployment folders and settings file:

    cap <stagename> deploy:setup

If all goes well, deploy:

    cap <stagename> deploy


