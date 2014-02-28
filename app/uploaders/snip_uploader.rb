# encoding: utf-8

class SnipUploader < CarrierWave::Uploader::Base
  storage :fog

  def store_dir
    "ss-api"
  end

  def cache_dir
    # should return path to cache dir
    Rails.root.join 'tmp/images'
  end
end
