class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ show ]

  # GET /comments or /comments.json
  def index
	@comments = Comment.all
  end

  # GET /comments/1 or /comments/1.json
  def show
  end

  # GET /comments/new
  def new
	params.expect(:post_path)
	@comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments or /comments.json
  def create
	@comment = Comment.new(comment_params)

    puts "----"
	puts "params = #{params}"
	puts "comment_params = #{comment_params}"
    puts "----"

	respond_to do |format|
	  if @comment.save
		format.html { redirect_to @comment, notice: "Comment was successfully created." }
		format.json { render :show, status: :created, location: @comment }
	  else
		@comment.post_path ||= params.dig(:comment, :post_path)
		format.html { render :new, status: :unprocessable_entity }
		format.json { render json: @comment.errors, status: :unprocessable_entity }
	  end
	end
  end

  # comments for a specific page
  # GET /comments/for?post_path=some/path
  def for
	@post_path = for_params
	if @post_path.blank?
	  respond_to do |format|
		format.html { redirect_to comments_path, alert: "post_path parameter is required." }
		format.json { render json: { error: "post_path parameter is required" }, status: :bad_request }
	  end
	  return
	end

	@comments = Comment.where(post_path: @post_path)
    comments_map = @comments.index_by(&:id)

	@comments.each do |comment|
      if comment.is_reply?
        comments_map[comment.parent_id].replies << comment
      end
	end

    @comments = @comments.reject{|comment| comment.is_reply?}

	respond_to do |format|
	  format.html # renders app/views/comments/for.html.erb
	  format.json { render json: @comments }
	end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_comment
	@comment = Comment.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def comment_params
    params.expect(comment: [ :content, :post_path, :parent_id, {author_attributes: [:id, :name, :email, :website] }])
  end

  def for_params
	params.expect(:post_path)
  end
end
