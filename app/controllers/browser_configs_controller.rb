# frozen_string_literal: true

class BrowserConfigsController < ApplicationController
  before_action :authenticate_user!

  # GET /browser_config
  def show
    @browser_config = current_user.browser_config || current_user.create_browser_config!
  end

  # PATCH /browser_config
  def update
    @browser_config = current_user.browser_config || current_user.create_browser_config!

    if @browser_config.update(browser_config_params)
      redirect_to browser_config_path, notice: t("flash.update_success", resource: BrowserConfig.model_name.human)
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def browser_config_params
    params.require(:browser_config).permit(:sort_column, :sort_direction, visible_columns: [], column_widths: {})
  end
end
