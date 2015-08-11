class CreateEpisodes < ActiveRecord::Migration
  def change
    create_table :episodes do |t|
      t.text :title
      t.string :link
      t.date :pubDate
      t.text :agenda
      t.text :description
      t.time :duration
      t.string :no
      t.string :mp3

      t.timestamps null: false
    end
  end
end
