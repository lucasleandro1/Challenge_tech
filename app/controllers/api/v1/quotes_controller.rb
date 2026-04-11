module Api
  module V1
    class QuotesController < ApplicationController
      def show
        quotes = QuoteFetcherService.new(params[:tag]).call
        render json: { quotes: quotes }
      end
    end
  end
end
