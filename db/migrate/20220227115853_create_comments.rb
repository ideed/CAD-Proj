class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :body
      t.integer :up_votes
      t.integer :down_votes
      t.datetime :send_date

      t.timestamps
    end
    create_table :comments do |t|
      t.integer :post_id
      t.integer :parent_id
      t.text :body
      t.integer :up_votes
      t.integer :down_votes
      t.datetime :send_date

      t.timestamps
    end
  end
end
