# frozen_string_literal: true

class UserPreferencesController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user_preference = current_user.preference
  end

  def update
    @user_preference = current_user.preference

    if @user_preference.update(user_preference_params)
      redirect_to edit_user_preferences_path, notice: t("flash.update_success", resource: UserPreference.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_preference_params
    params.require(:user_preference).permit(
      :language, :theme, :auto_sync, :next_day_starts_at,
      :learn_ahead_limit, :timebox_time_limit, :video_driver,
      :ui_size, :minimalist_mode, :reduce_motion,
      :paste_strips_formatting, :paste_images_as_png,
      :default_deck_behavior, :show_play_buttons,
      :interrupt_audio_on_answer, :show_remaining_count,
      :show_next_review_time, :spacebar_answers_card,
      :ignore_accents_in_search, :default_search_text,
      :sync_audio_and_images, :periodically_sync_media,
      :force_one_way_sync, :self_hosted_sync_server_url
    )
  end
end
