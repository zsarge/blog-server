#!/bin/env bash

RAILS_ENV=production /home/blog-server/.asdf/shims/bundle exec puma -C config/puma.rb

