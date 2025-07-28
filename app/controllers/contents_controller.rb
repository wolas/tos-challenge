class ContentsController < ApplicationController
  def index
    contents = Rails.cache.fetch("contents/#{params[:country]}/#{params[:type]}", expires_in: 24.hours) do
      ContentJsonIndexQuery.new(params[:country], params[:type]).call
    end

    render json: contents
  end

  private

  def contents_params
    params.require(:country)
  end
end
