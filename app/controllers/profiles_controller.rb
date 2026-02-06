# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def index
    @profiles = helpers.mock_profiles
  end

  def show
    @profile = helpers.mock_profile_detail
  end

  def new; end
  def edit; end

  def create
    redirect_to profiles_path, notice: "Profile created."
  end

  def update
    redirect_to profiles_path, notice: "Profile updated."
  end

  def destroy
    redirect_to profiles_path, notice: "Profile deleted."
  end
end
