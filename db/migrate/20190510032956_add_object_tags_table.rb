class AddObjectTagsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :object_tags do |t|
      t.string :name
      t.references :user_image, foreign_key: true
      t.timestamps
    end
  end
end
