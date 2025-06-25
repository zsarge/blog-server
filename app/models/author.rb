class Author < ApplicationRecord
  # https://stackoverflow.com/a/31062521
  validates_format_of :website, :with => /\A(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w\.-]*)*\/?\Z/i,
    allow_blank: true
 
  # unscientific, but it feels like anything longer than these is more likely to be spam than valid
  validates :name, length: { maximum: 30 }
  validates :website, length: { maximum: 100 } 
  validates :email, length: { maximum: 100 }

  def display_name
    name.presence || "Anonymous"
  end
end
