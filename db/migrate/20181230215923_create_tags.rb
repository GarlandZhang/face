class CreateTags < ActiveRecord::Migration[5.1]
  def change
    create_table :tags do |t|
      t.belongs_to :user_image, index: true
      t.belongs_to :person, index: true
      t.timestamps
    end
  end
end
