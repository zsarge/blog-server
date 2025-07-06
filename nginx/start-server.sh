#!/bin/env bash

# precompile assets
RAILS_ENV=production /home/blog-server/blog-server/bin/rails assets:precompile

# deploy to production
RAILS_ENV=production /home/blog-server/.asdf/shims/bundle exec puma -C config/puma.rb

