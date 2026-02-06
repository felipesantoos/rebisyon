# frozen_string_literal: true

module Api
  module V1
    class FlagNamesController < BaseController
      before_action :set_flag_name, only: %i[update destroy]

      # GET /api/v1/flag_names
      def index
        result = paginate(current_user.flag_names.order(:flag_number))
        render json: result
      end

      # POST /api/v1/flag_names
      def create
        flag_name = current_user.flag_names.build(flag_name_params)
        flag_name.save!
        render json: { data: flag_name }, status: :created
      end

      # PATCH /api/v1/flag_names/:id
      def update
        @flag_name.update!(flag_name_params)
        render json: { data: @flag_name }
      end

      # DELETE /api/v1/flag_names/:id
      def destroy
        @flag_name.destroy
        head :no_content
      end

      private

      def set_flag_name
        @flag_name = current_user.flag_names.find(params[:id])
      end

      def flag_name_params
        params.require(:flag_name).permit(:flag_number, :name)
      end
    end
  end
end
