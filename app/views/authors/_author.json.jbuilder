json.extract! author, :id, :name, :website, :email, :created_at, :updated_at
json.url author_url(author, format: :json)
