class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy upvote downvote]

  def index
    api = GetTwitterAPI.new(Apis.new("twitter.com"))
    @tweets = api.returnApi
    @posts = Post.all
    if session[:yourPost_ids]
      @yourPosts = Array.new
      for postId in session[:yourPost_ids] do
        @yourPosts.push(Post.find_by(id: postId))
      end
    end
  end

  def show
    irish_news = IrishNewsAPI.new(Apis.new("newsapi.org"))
    index = 0
    articles = Array.new
    irish_news.returnApi.each do |post|
      if index == 2
         post[1].each do |article|
           articles.push(article)
         end
      else
        index += 1
      end
    end
    @irishNewsArticles = articles
  end

  def new
    local_time = LocalTime.instance
    @post = Post.new(up_votes: 0, down_votes: 0, send_date:local_time.calculateTime)
  end

  def edit
  end

  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        if session[:yourPost_ids]
          session[:yourPost_ids] = session[:yourPost_ids].push(@post.id)
        else
          session[:yourPost_ids] = Array.[](@post.id)
        end
        format.html { redirect_to post_url(@post), notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to post_url(@post), notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    session[:yourPost_ids].delete(@post.id)
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Post was successfully deleted." }
      format.json { head :no_content }
    end
  end

  def upvote
    @post.upvote_from current_user
    redirect_to posts_path
  end

  def downvote
    @post.downvote_from current_user
    redirect_to posts_path
  end
  # Design Pattern Implementations
  class LocalTime
    include Singleton

    def calculateTime
      time = Time.new
      values = time.to_a
      @sendDate = "#{Time.utc(*values)}"
    end
  end

  class Apis
    def initialize(api_url)
      @api_url = api_url
    end
    def returnApi
      puts("Api request sent to URL: #{@api_url}")
    end
  end

  class ApiDecorator
    def initialize(real_api)
      @real_api = real_api
    end
    def returnApi
      @real_api.returnApi
    end
  end

  class GetTwitterAPI < ApiDecorator
    def initialize(api)
      super(api)
      @consumer_key = "62ipBXBp2j46sfc7o24ObDRhR"
      @consumer_secret = "XBfih8LSbV4HZmNfhQArIc2lLnGj298YHADfClnA7YRveOiJn1"
      @access_token = "2279402058-MjlA8FMoAOtjdFUAnleb0tjM4IoyUCGgFclGeLI"
      @access_secret = "1BJ06K2Kd6Yicw0MyPX1YkD50BSZsWEjKb1jgc8gsJu8Y"
    end

    def returnApi
      super
      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = @consumer_key
        config.consumer_secret     = @consumer_secret
        config.access_token        = @access_token
        config.access_token_secret = @access_secret
      end

      client.user_timeline('Education_Ire', count: 6)
    end
  end

  class IrishNewsAPI < ApiDecorator
    include HTTParty
    def initialize(api)
      super(api)
      self.class.base_uri "newsapi.org/"
    end

    def returnApi
      super
      self.class.get('/v2/top-headlines?apiKey=8346750eaa5c4a1393c80988f56a7521&country=ie')
    end
  end

  private
    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:title, :body, :up_votes, :down_votes, :send_date)
    end
end
