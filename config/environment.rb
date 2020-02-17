# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

Paperclip.options[:image_magick_path] = "/opt/ImageMagick/bin"
Paperclip.options[:command_path] = "/opt/ImageMagick/bin"

Paperclip.options[:command_path] = "/usr/local/bin/"
