class RenameCommentColumnName < ActiveRecord::Migration[8.0]
  def change
    rename_column :comments, :url, :post_path
  end
end
