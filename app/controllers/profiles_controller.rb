# frozen_string_literal: true

class ProfilesController < ApplicationController
  include Paginatable

  before_action :authenticate_user!
  before_action :set_profile, only: %i[show edit update destroy]

  def index
    @pagy, @profiles = paginate(current_user.profiles.ordered)
  end

  def show
  end

  def new
    @profile = current_user.profiles.build
  end

  def edit
  end

  def create
    @profile = current_user.profiles.build(profile_params)
    if @profile.save
      redirect_to @profile, notice: "Profile created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @profile.update(profile_params)
      redirect_to @profile, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @profile.soft_delete!
    redirect_to profiles_path, notice: "Profile deleted."
  end

  private

  def set_profile
    @profile = current_user.profiles.find(params[:id])
  end

  def profile_params
    params.require(:profile).permit(:name, :ankiweb_sync_enabled, :ankiweb_username)
  end
end
