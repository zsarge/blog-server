class Comment < ApplicationRecord
  belongs_to :author
  belongs_to :parent, class_name: 'Comment', optional: true
  has_many :replies, class_name: 'Comment', foreign_key: 'parent_id', dependent: :destroy

  validates :content, presence: true
  validates :author, presence: true
  validates :post_path, presence: true

  accepts_nested_attributes_for :author

  def is_reply?
    self.parent_id.present?
  end
end

