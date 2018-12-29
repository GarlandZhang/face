class CreateUserImages < ActiveRecord::Migration[5.1]
  def change
    create_table :user_images do |t|
      t.string :url
      t.references :user
      t.timestamps
    end
  end
end
