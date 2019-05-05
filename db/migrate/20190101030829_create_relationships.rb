class CreateRelationships < ActiveRecord::Migration[5.1]
  def change
    create_table :relationships do |t|
      t.references :main
      t.references :friend
      t.timestamps
    end
  end
end
