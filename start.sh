#! /usr/bin/env bash
RACK_ENV=production bundle exec rackup -s thin -p 64567 -o 0.0.0.0

