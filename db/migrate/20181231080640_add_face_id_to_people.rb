class AddFaceIdToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :face_id, :string
  end
end
