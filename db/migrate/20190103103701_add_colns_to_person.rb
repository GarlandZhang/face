class AddColnsToPerson < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :face_width, :integer
    add_column :people, :face_height, :integer
    add_column :people, :face_offset_x, :integer
    add_column :people, :face_offset_y, :integer
  end
end
