#!/bin/bash

echo "Install Gems."
bundle install

echo "Install dependencies via CocoaPods."
bundle exec pod install

echo "Bootstrap complete!"