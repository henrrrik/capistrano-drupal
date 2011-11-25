# Capistrano deployment scripts for Drupal

##Getting started

You need capistrano itself, capistrano-ext for multistage deployment and
railsless-deploy for convenient overrides.

    gem install capistrano capistrano-ext railsless-deploy

##Configuration

`config/deploy.rb` - general configuration settings

`config/deploy/<stagename>.rb` - stage-specific settings

##Usage

Set up the deployment folders and settings file:

    cap <stagename> deploy:setup

If all goes well, deploy:

    cap <stagename> deploy


