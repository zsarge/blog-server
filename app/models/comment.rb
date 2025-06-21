class Comment < ApplicationRecord
  belongs_to :author
  validates :content, presence: true
  validates :author, presence: true
  validates :post_path, presence: true
  accepts_nested_attributes_for :author
end
