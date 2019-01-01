class CreateUserImages < ActiveRecord::Migration[5.1]
  def change
    create_table :user_images do |t|
      t.string :url
      t.int :user_val
      t.timestamps
    end
  end
end
