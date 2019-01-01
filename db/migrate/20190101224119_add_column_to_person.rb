class AddColumnToPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :last_face_id, :string
  end
end
