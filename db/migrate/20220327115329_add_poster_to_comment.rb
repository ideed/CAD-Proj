class AddPosterToComment < ActiveRecord::Migration[6.1]
  def change
    add_column :comments, :poster, :string
  end
end
