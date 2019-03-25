require 'aws-sdk'
Aws.config.update(
:access_key_id => ENV['AWS_S3_ACCESS_KEY_ID'],
:secret_access_key => ENV['AWS_S3_SECRET_ACCESS_KEY'])

# # Be sure to restart your server when you modify this file.

# # Configure AWS SDK for Ruby.
# Aws.config.update(Rails.application.config_for(:aws).symbolize_keys)