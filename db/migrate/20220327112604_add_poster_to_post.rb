class AddPosterToPost < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :poster, :string
  end
end
