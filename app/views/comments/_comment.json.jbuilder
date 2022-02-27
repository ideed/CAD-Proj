json.extract! comment, :id, :post_id, :parent_id, :body, :up_votes, :down_votes, :send_date, :created_at, :updated_at
json.url comment_url(comment, format: :json)
