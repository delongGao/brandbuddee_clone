# encoding: utf-8

class CampaignImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file if Rails.env.development?
  storage :s3 if Rails.env.production?

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{mounted_as}/#{model.id}"
  end

  version :large do
    resize_to_fit(600, 600)
  end

  version :square, :from_version => :large do
    resize_to_fill(296, 270)
  end
  
  version :standard do
  	process :crop
    resize_to_fill(260, 180)
  end

  version :email do
    resize_to_fill(600, 300)
  end

  def crop
  	if model.crop_x.present?
  		resize_to_fit(600, 600)
  		manipulate! do |img|
  			x = model.crop_x.to_i
  			y = model.crop_y.to_i
  			w = model.crop_w.to_i
  			h = model.crop_h.to_i
  			img.crop!(x, y, w, h)
  		end
  	end
  end


  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
