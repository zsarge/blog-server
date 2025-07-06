class FilesController < ApplicationController
  def show
	# Require two parameters: file_name and collection
	params.require([:file_name, :collection])
	@file_name = params[:file_name]
	@collection = params[:collection]

	@path = "#{@collection}/#{@file_name}"
	@hash = Digest::SHA256.hexdigest(@path)

	image_data = Rails.cache.fetch(@hash) do
	  get_image_from_google_drive(@file_name, @collection)
	end

	send_data image_data,
	  type: Mime::Type.lookup_by_extension(File.extname(@file_name).delete('.')),
	  disposition: 'inline'
  end

  private

  def get_image_from_google_drive(file_name, collection_name)
	session = GoogleDrive::Session.from_service_account_key(Rails.root.join('config', 'google-service-account.json'))
	folder = session.folder_by_url(ENV["GOOGLE_DRIVE_FOLDER_URL"])
	  .subfolder_by_name("files") # must be in the files subdir

	# Find the subfolder with the collection name
	if collection_name.present?
	  collection_folder = folder.subfolder_by_name(collection_name)
	  unless collection_folder
		raise "Collection folder not found in Google Drive: #{collection_name}"
	  end
	else
	  collection_folder = folder
	end

	# Find the file in the collection folder
	file = collection_folder.files.find { |f| f.title == file_name }

	unless file
	  raise "File not found in Google Drive folder: #{file_name}"
	end

	# Return the file content
	file.download_to_string
  end
end
