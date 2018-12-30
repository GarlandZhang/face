class CreateUserImages < ActiveRecord::Migration[5.1]
  def change
    create_table :user_images do |t|
      t.string :url,
      t.id :user_id,
      t.timestamps
    end
  end
end
