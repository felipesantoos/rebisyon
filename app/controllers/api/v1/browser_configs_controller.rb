# frozen_string_literal: true

module Api
  module V1
    class BrowserConfigsController < BaseController
      # GET /api/v1/browser_config
      def show
        browser_config = current_user.browser_config || current_user.create_browser_config!
        render json: { data: browser_config }
      end

      # PATCH /api/v1/browser_config
      def update
        browser_config = current_user.browser_config || current_user.create_browser_config!
        browser_config.update!(browser_config_params)
        render json: { data: browser_config }
      end

      private

      def browser_config_params
        params.require(:browser_config).permit(:sort_column, :sort_direction, visible_columns: [], column_widths: {})
      end
    end
  end
end
