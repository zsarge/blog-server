# lib/tasks/backup.rake

require 'json'
require 'fastimage'

namespace :export do
  desc "Export sizes of downloaded images"
  task to_drive: :environment do
	cache_folder = File.join(Dir.root, "blog-server-cache")

	lookup = {}

	Dir.glob("#{cache_folder}/**/*") do |path|
	  if File.file?(path)
		filename = Dir.basename(path)
		puts "Found file: #{path} (#{filename})"
		dimensions = FastImage.size(path)
		lookup[filename] = dimensions
	  end
	end

	puts "Finished processing!"
	puts lookup.to_json
  end
end

