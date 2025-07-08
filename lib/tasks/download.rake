require 'google_drive'

namespace :download do
  desc "Download Google Drive folder contents to local directory"
  task from_drive: :environment do
    # Configuration variables
    root_path = Rails.root
    destination_folder = ENV["LOCAL_BACKUP_FOLDER"] || File.join(Dir.home, "blog-server-cache")
    service_account_path = root_path.join('config', 'google-service-account.json')

    # Create destination folder if it doesn't exist
    FileUtils.mkdir_p(destination_folder) unless Dir.exist?(destination_folder)

    # Authenticate with Google Drive
    session = GoogleDrive::Session.from_service_account_key(service_account_path)
    folder = session.folder_by_url(ENV["GOOGLE_DRIVE_FOLDER_URL"]).subfolder_by_name("files")

    # Process files in the Google Drive folder
    download_folder(folder, destination_folder)

    puts "Download complete! Files saved to: #{destination_folder}"
  end
end

private

def download_folder(folder, destination_folder, descending_names=nil)
  begin # handle paging *all* files
	(files, page_token) = folder.files(page_token: page_token)
	files.each do |file|
	  local_dir = File.join(destination_folder, *descending_names)
	  local_path = File.join(local_dir, file.name)

	  if file.is_a?(GoogleDrive::Collection)
		FileUtils.mkdir_p(File.join(local_dir, file.name))
		download_folder(file, destination_folder, (descending_names || []) << file.name)
	  else
		process_file(file, local_dir)
	  end
	end
  end while page_token
end

TARGET_TYPES = %w(jpg avif webp)

def process_file(file, destination_folder) 
  # download the file
  local_path = File.join(destination_folder, file.name)
  unless File.exist?(local_path)
    puts "Downloading #{file.name}"
    File.open(local_path, 'wb') do |new_file|
      file.download_to_io(new_file)
    end
  end

  original_file_extension = File.extname(file.name)

  return unless original_file_extension.delete('.').in?(TARGET_TYPES)

  def convert_file(source_path, destination_path, format)
    return if File.exist?(destination_path)

	with_retry do # handle when image converison is killed by oom
	  ImageProcessing::MiniMagick
		.source(source_path)
		.convert(format)        # sets the output format (e.g. "jpg")
		.call(destination: destination_path)
	end
  end

  # convert the file
  TARGET_TYPES.each do |target_file_ext|
    next if target_file_ext == original_file_extension
    puts "Converting #{file.name} to #{target_file_ext}"
    basename = File.basename(file.name, original_file_extension)
    destination_path = File.join(destination_folder, [basename, '.', target_file_ext].join)
    convert_file(local_path, destination_path, target_file_ext)
  end
end

MAX_RETRIES = 5

def with_retry
  retries = 0

  begin
    yield
  rescue => e
    retries += 1
    if retries <= MAX_RETRIES
      sleep_time = 2 ** retries  # Exponential backoff (2s, 4s, 8s, ...)
      Rails.logger.warn("Retry ##{retries} after #{sleep_time}s due to error: #{e.message}")
      sleep(sleep_time)
      retry
    else
      Rails.logger.error("Max retries reached. Giving up. Last error: #{e.message}")
      raise
    end
  end
end

