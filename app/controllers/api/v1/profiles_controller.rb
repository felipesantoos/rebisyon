# frozen_string_literal: true

module Api
  module V1
    class ProfilesController < BaseController
      before_action :set_profile, only: %i[show update destroy]

      # GET /api/v1/profiles
      def index
        result = paginate(current_user.profiles)
        render json: result
      end

      # GET /api/v1/profiles/:id
      def show
        render json: { data: @profile }
      end

      # POST /api/v1/profiles
      def create
        profile = current_user.profiles.build(profile_params)
        profile.save!
        render json: { data: profile }, status: :created
      end

      # PATCH /api/v1/profiles/:id
      def update
        @profile.update!(profile_params)
        render json: { data: @profile }
      end

      # DELETE /api/v1/profiles/:id
      def destroy
        @profile.soft_delete!
        head :no_content
      end

      private

      def set_profile
        @profile = current_user.profiles.find(params[:id])
      end

      def profile_params
        params.require(:profile).permit(:name, :ankiweb_sync_enabled, :ankiweb_username)
      end
    end
  end
end
