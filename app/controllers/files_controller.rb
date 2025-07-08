class FilesController < ApplicationController
  # The cache strategy here relys on the files being represented as strings in memory.
  # I'm going to assume this sucks for performance, compared to any appropraite streaming approach.
  # This really makes me wish for Go's reader/writer interfaces.
  # It might be worth investigating streaming approaches, 
  # but Ruby's cache implementation seems to store in-memory results only?

  # There are seperate caches for converting and fetching from Google Drive,
  # so ideally we only fetch from Google Drive once (although cache misses
  # will always have to make a request, necessitating nginx to protect from dirb).

  def show_collection
    params.permit(:convert_to, :file_name, :collection).require([:file_name, :collection])
    @file_name = params[:file_name]
    @collection = params[:collection]
    @convert_to = params[:convert_to]
    validate_convert_to!

    send_image_data
  end

  def show_image
    params.permit(:convert_to, :file_name).require(:file_name)
    @file_name = params[:file_name]
    @convert_to = params[:convert_to]
    validate_convert_to!

    send_image_data
  end

  private

  def get_converted_image
	  hash = Digest::SHA256.hexdigest("get_converted_image #{@collection}/#{@file_name}/#{@convert_to}")

	  Rails.cache.fetch(hash) do
		Rails.logger.info(["converter cache miss", @file_name, @collection, @convert_to])
		convert_image(get_image)
	  end
  end

  def convert_image(image_data)
	binary_data = Tempfile.create do |tempfile|
	  # Write binary data safely
	  tempfile.binmode
	  tempfile.write(image_data)
	  tempfile.close  # Ensure data is flushed to disk

	  # Process the image using the temporary file
	  new_image = ImageProcessing::MiniMagick
		.source(tempfile.path)
		.convert!(@convert_to)

	  File.binread(new_image.path)
	end

	binary_data # explicit return
  end

  def send_image_data
	if @convert_to.present?
	  image_data = get_converted_image
	else
	  image_data = get_image
	end

    if image_data == IMAGE_NOT_FOUND
      render json: { error: "Image Not Found", file_name: @file_name, collection: @collection }, status: :not_found
      return
    end

    file_ext = @convert_to || File.extname(@file_name).delete('.')

    send_data image_data,
      type: Mime::Type.lookup_by_extension(file_ext),
      disposition: 'inline',
      filename: @file_name
  end

  # we make sure to return a non-nil result, such that
  # errors are cached and not expensively retried
  IMAGE_NOT_FOUND = :image_not_found

  CONVERTABLE_FORMATS = %w(jpg webp avif)

  # attempt to get the image from the cache, then get it from google drive
  def get_image
    hash = Digest::SHA256.hexdigest("get_image #{@collection}/#{@file_name}")

	Rails.cache.fetch(hash) do
	  Rails.logger.info(["file cache miss", @file_name, @collection])
      get_image_from_google_drive(@file_name, @collection)
    end
  end

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
  rescue RuntimeError => e
    Rails.logger.error "Google Drive Error: #{e.class} - #{e.message}"
    Rails.logger.debug "Backtrace:\n#{e.backtrace.join("\n")}" if e.backtrace

    if "File not found".in? e.message
      return IMAGE_NOT_FOUND
    else
      raise e
    end
  end

  def validate_convert_to!
    return if @convert_to.blank?
    return if @convert_to.in? CONVERTABLE_FORMATS

    raise ActionController::BadRequest, "Invalid convert_to param: #{@convert_to}"
  end
end
