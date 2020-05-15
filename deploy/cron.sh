#!/bin/sh
DEPLOY_DIR="/CHANGE/ME/"

set -e

export GEM_HOME=$(ruby -e 'puts Gem.user_dir')
PATH="$GEM_HOME/bin:$PATH"

export RUBYOPT=-EUTF-8

cd "$DEPLOY_DIR"
bundle exec update.rb || true
bundle exec middleman build
