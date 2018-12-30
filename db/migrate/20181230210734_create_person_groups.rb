class CreatePersonGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :person_groups do |t|
      t.string :name
      t.string :azure_id
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
