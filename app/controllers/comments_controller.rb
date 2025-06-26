class CommentsController < ApplicationController
  include Recaptcha::Adapters::ViewMethods

  before_action :set_comment, only: %i[ show ]

  # GET /comments or /comments.json
  def index
    params.permit(:page)
    set_page
	@comments = Comment.all
                       .order(created_at: :desc)
                       .page(@page)
  end

  # GET /comments/1 or /comments/1.json
  def show
  end

  # GET /comments/new
  def new
	params.expect(:post_path)
	@comment = Comment.new
    set_post_and_path
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments or /comments.json
  def create
	@comment = Comment.new(comment_params)

	respond_to do |format|
      if verify_recaptcha(model: @comment) && @comment.save
        format.html { redirect_to @comment, notice: "Comment was successfully created." }
        format.json { render :show, status: :created, location: @comment }
      else
        set_post_and_path
        format.html { render :new, status: :unprocessable_entity, post_path: @post_path, parent_id: @parent_id }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # comments for a specific page
  # GET /comments/for?post_path=some/path
  def for
    params.permit(:post_path, :page).require(:post_path)
    @post_path = params[:post_path]
    set_page
    set_post_and_path

	if @post_path.blank?
	  respond_to do |format|
		format.html { redirect_to comments_path, alert: "post_path parameter is required." }
		format.json { render json: { error: "post_path parameter is required" }, status: :bad_request }
	  end
	  return
	end

    @comments = Comment.where(post_path: @post_path, parent_id: nil)
                       .order(created_at: :desc)
                       .page(@page)

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

  def set_post_and_path
    @post_path = @comment&.post_path || params[:post_path] || params.dig(:comment, :post_path)
    @parent_id = @comment&.parent_id || params[:parent_id] || params.dig(:comment, :parent_id)
  end

  # Only allow a list of trusted parameters through.
  def comment_params
    params.expect(comment: [ :content, :post_path, :parent_id, {author_attributes: [:id, :name, :email, :website] }])
  end

  def set_page 
    @page = params[:page] || 1
  end
end
