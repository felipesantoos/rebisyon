# frozen_string_literal: true

module Api
  module V1
    class AddOnsController < BaseController
      before_action :set_add_on, only: %i[show update destroy]

      # GET /api/v1/add_ons
      def index
        result = paginate(current_user.add_ons)
        render json: result
      end

      # GET /api/v1/add_ons/:id
      def show
        render json: { data: @add_on }
      end

      # POST /api/v1/add_ons
      def create
        add_on = current_user.add_ons.build(add_on_params)
        add_on.save!
        render json: { data: add_on }, status: :created
      end

      # PATCH /api/v1/add_ons/:id
      def update
        @add_on.update!(add_on_params)
        render json: { data: @add_on }
      end

      # DELETE /api/v1/add_ons/:id
      def destroy
        @add_on.destroy
        head :no_content
      end

      private

      def set_add_on
        @add_on = current_user.add_ons.find(params[:id])
      end

      def add_on_params
        params.require(:add_on).permit(:code, :name, :version, :enabled, config_json: {})
      end
    end
  end
end
