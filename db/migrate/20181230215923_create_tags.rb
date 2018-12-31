class CreateTags < ActiveRecord::Migration[5.1]
  def change
    create_table :tags do |t|
      t.references :user_image, index: true
      t.references :person, index: true
      t.timestamps
    end
  end
end
