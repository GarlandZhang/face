class CreateRelationships < ActiveRecord::Migration[5.1]
  def change
    create_table :relationships do |t|
      t.references :main, index: true
      t.references :friend, index: true
      t.timestamps
    end
  end
end