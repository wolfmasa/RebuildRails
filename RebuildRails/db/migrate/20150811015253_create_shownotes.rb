class CreateShownotes < ActiveRecord::Migration
  def change
    create_table :shownotes do |t|
      t.text :title
      t.text :link

      t.timestamps null: false
    end
  end
end
