# lib/tasks/backup.rake

require 'google_drive'

namespace :backup do
  desc "Upload sqlite3 file to Google Drive"
  task to_drive: :environment do
	root_path = Rails.root
	session = GoogleDrive::Session.from_service_account_key(root_path.join('config', 'google-service-account.json'))
	folder = session.folder_by_url(ENV["GOOGLE_DRIVE_FOLDER_URL"])

	file_name = ActiveRecord::Base.connection_db_config.database.gsub('storage/', '')
	file_path = root_path.join("storage", file_name).to_s

	# Replace if exists, otherwise upload
	existing = folder.files(q: ["name = ?", file_name]).first
	if existing
	  existing.update_from_file(file_path)
	else
	  folder.upload_from_file(file_path, file_name, convert: false)
	end

	puts "Backup complete: #{file_name} uploaded to Google Drive"
  end
end

