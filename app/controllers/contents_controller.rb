class ContentsController < ApplicationController
  def index
    contents = ContentJsonIndexQuery.new(params[:country], params[:type]).call

    render json: contents
  end

  private

  def contents_params
    params.require(:country)
  end
end
