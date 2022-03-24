class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    @tweets = getTwitterAPI
    @posts = Post.all
    if session[:yourPost_ids]
      @yourPosts = Array.new
      for postId in session[:yourPost_ids] do
        @yourPosts.push(Post.find_by(id: postId))
      end
    end
  end

  # GET /posts/1 or /posts/1.json
  def show
    irish_news = IrishNewsAPI.new
    index = 0
    articles = Array.new
    irish_news.posts.each do |post|
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

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
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

  # PATCH/PUT /posts/1 or /posts/1.json
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

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def getTwitterAPI
    @consumer_key = "62ipBXBp2j46sfc7o24ObDRhR"
    @consumer_secret = "XBfih8LSbV4HZmNfhQArIc2lLnGj298YHADfClnA7YRveOiJn1"
    @access_token = "2279402058-MjlA8FMoAOtjdFUAnleb0tjM4IoyUCGgFclGeLI"
    @access_secret = "1BJ06K2Kd6Yicw0MyPX1YkD50BSZsWEjKb1jgc8gsJu8Y"

    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = @consumer_key
      config.consumer_secret     = @consumer_secret
      config.access_token        = @access_token
      config.access_token_secret = @access_secret
    end

    client.user_timeline('Education_Ire', count: 6)
  end

  class IrishNewsAPI
    include HTTParty
    base_uri "newsapi.org/"

    def posts
      self.class.get('/v2/top-headlines?apiKey=8346750eaa5c4a1393c80988f56a7521&country=ie')
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :body, :up_votes, :down_votes, :send_date)
    end
end
