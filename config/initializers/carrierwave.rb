CarrierWave.configure do |config|
  #config.root = Rails.root.join('tmp')
  #config.cache_dir = 'carrierwave'
  
  if Rails.env.development?
    config.grid_fs_connection = Mongoid.database
    config.storage = :grid_fs
    # config.grid_fs_access_url = Setting.upload_url
  elsif Rails.env.production?
    config.root = Rails.root.join('tmp') # adding these...
    config.cache_dir = 'carrierwave' # ...two lines    
    config.s3_access_key_id = ENV['AWS_ACCESS_KEY_ID']
    config.s3_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    config.s3_bucket = 'brandbuddee-production'
  end
end

# require File.join(Rails.root, "lib", "delayed_image_processing")
# Mongoid::Document::ClassMethods.send(:include, DelayedImageProcessing)

module CarrierWave
  # http://sleeplesscoding.blogspot.com/2011/09/recreate-single-version-of.html
  # Note: is_processing_delayed should be set before calling recreate_version! if the version depends on it.
  module Uploader
    module Versions
      def recreate_version!(version)
        already_cached = cached?
        cache_stored_file! if !already_cached
        send(version).store!
        if !already_cached && @cache_id
          tmp_dir = File.expand_path(File.join(cache_dir, cache_id), CarrierWave.root)
          FileUtils.rm_rf(tmp_dir)
        end
      end
    end
  end
  
  # Avoid overwriting original filename in delayed-processing.
  module Mount
    class Mounter
      def write_identifier
        if remove?
          record.write_uploader(serialization_column, '')
        elsif uploader.identifier.present? &&
          (!uploader.respond_to?(:is_processing_immediate?) || uploader.is_processing_immediate?)
          record.write_uploader(serialization_column, uploader.identifier)
        end
      end
    end
  end
end