CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => ENV['AWS_KEY'],
    :aws_secret_access_key  => ENV['AWS_SECRET'],
  }
  config.fog_public = true
  config.fog_directory  = ENV['AWS_S3_DIRECTORY']
end