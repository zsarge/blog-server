class Comment < ApplicationRecord
  belongs_to :author
  has_rich_text :content
  validates :content, presence: true
  validates :author, presence: true
  validates :post_path, presence: true

  def author_attributes=(attributes)
	return if attributes.blank?
    self.author = Author.find_or_create_by(attributes)

	# Find existing author by email (case-insensitive)
    # if %i[email name website].all? {attributes[_1].present?}
      # email = attributes[:email].downcase.strip
	  # author = Author.find_by('LOWER(email) = ?', )
	# end

	# if author
	  # self.author = author
	# else # New author
	  # self.author = Author.new(attributes)
	# end
  end
end
