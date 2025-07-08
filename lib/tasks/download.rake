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
  folder.files.each do |file|
		local_dir = File.join(destination_folder, *descending_names)
    local_path = File.join(local_dir, file.name)

    if file.is_a?(GoogleDrive::Collection)
			FileUtils.mkdir_p(File.join(local_dir, file.name))
      download_folder(file, destination_folder, (descending_names || []) << file.name)
    else
      if File.exist?(local_path)
        puts "Skipping existing file: #{file.name}"
      else
        puts "Downloading: #{file.name}"
        File.open(local_path, 'wb') do |new_file|
					file.download_to_io(new_file)
        end
      end
    end
  end
end

