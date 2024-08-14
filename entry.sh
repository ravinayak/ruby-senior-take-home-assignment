#!/bin/bash

# If test parameter is passed, all Rspec tests will be executed
#
if [ "$1" = "test" ]; then
  APP_ENV=test bundle exec rspec
else
  APP_ENV=dev bundle exec rackup --host 0.0.0.0 -p 3087
fi
