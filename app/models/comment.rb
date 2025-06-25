class Comment < ApplicationRecord
  belongs_to :author
  belongs_to :parent, class_name: 'Comment', optional: true
  has_many :replies, class_name: 'Comment', foreign_key: 'parent_id', dependent: :destroy

  MAXIMUM_COMMENT_LENGTH = 10_000 # characters

  validates :content, presence: true, length: { maximum: MAXIMUM_COMMENT_LENGTH }
  validates :author, presence: true
  validates :post_path, presence: true

  accepts_nested_attributes_for :author

  def is_reply?
    self.parent_id.present?
  end
end

