class Author < ApplicationRecord
  def display_name
    name.presence || "Anonymous"
  end
end
