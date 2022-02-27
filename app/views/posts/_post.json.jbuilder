json.extract! post, :id, :title, :body, :up_votes, :down_votes, :send_date, :created_at, :updated_at
json.url post_url(post, format: :json)
