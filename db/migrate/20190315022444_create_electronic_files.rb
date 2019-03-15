class CreateElectronicFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :electronic_files do |t|
      t.string :path

      t.timestamps
    end
  end
end
