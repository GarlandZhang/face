class CreatePeople < ActiveRecord::Migration[5.1]
  def change
    create_table :people do |t|
      t.string :name
      t.references :person_group, foreign_key: true
      t.timestamps
    end
  end
end
