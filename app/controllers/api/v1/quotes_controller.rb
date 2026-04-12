module Api
  module V1
    class QuotesController < ApplicationController
      def show
        quotes = QuoteFetcherService.new(params[:tag]).call
        render json: { quotes: quotes.map { |q| QuoteSerializer.new(q).as_json } }
      end
    end
  end
end
