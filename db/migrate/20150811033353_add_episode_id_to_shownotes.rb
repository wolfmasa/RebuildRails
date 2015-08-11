class AddEpisodeIdToShownotes < ActiveRecord::Migration
  def change
    add_column :shownotes, :episode_id, :integer
  end
end
