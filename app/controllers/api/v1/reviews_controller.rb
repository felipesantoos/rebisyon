# frozen_string_literal: true

module Api
  module V1
    class ReviewsController < BaseController
      before_action :set_review, only: :show

      # GET /api/v1/reviews
      def index
        reviews = Review.joins(card: :note).where(notes: { user_id: current_user.id })
        reviews = reviews.where(card_id: params[:card_id]) if params[:card_id].present?
        result = paginate(reviews)
        render json: result
      end

      # GET /api/v1/reviews/:id
      def show
        render json: { data: @review }
      end

      private

      def set_review
        @review = Review.joins(card: :note).where(notes: { user_id: current_user.id }).find(params[:id])
      end
    end
  end
end
