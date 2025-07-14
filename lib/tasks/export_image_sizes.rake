# lib/tasks/backup.rake

require 'json'
require 'fastimage'

namespace :export do
  desc "Export sizes of downloaded images"
  task :image_sizes do
	cache_folder = File.join(Dir.home, "blog-server-cache")

	lookup = {}

	Dir.glob("#{cache_folder}/**/*") do |path|
      if File.file?(path) && File.extname(path).downcase.in?(%w(png jpeg jpg avif gif webp))
		filename = File.basename(path)
		puts "Found file: #{path} (#{filename})"
		width, height = FastImage.size(path)
		lookup[filename] = { "width" => width, "height" => height }
	  end
	end

	puts "Finished processing!"
	puts lookup.to_json
  end
end

