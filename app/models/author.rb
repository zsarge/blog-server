class Author < ApplicationRecord
  # https://stackoverflow.com/a/31062521
  validates_format_of :website, :with => /\A(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w\.-]*)*\/?\Z/i,
    allow_blank: true

  def display_name
    name.presence || "Anonymous"
  end
end
