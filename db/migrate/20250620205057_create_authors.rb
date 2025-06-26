class CreateAuthors < ActiveRecord::Migration[8.0]
  def change
    create_table :authors do |t|
      t.string :name
      t.string :website
      t.string :email

      t.timestamps
    end
  end
end
