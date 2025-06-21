class Comment < ApplicationRecord
  belongs_to :author
  validates :content, presence: true
  validates :author, presence: true
  validates :post_path, presence: true

  def author_attributes=(attributes)
	return if attributes.blank?
    self.author = Author.find_or_create_by(attributes)
  end
end
