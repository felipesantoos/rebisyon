# frozen_string_literal: true

class SavedSearchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_saved_search, only: %i[edit update destroy]

  # GET /saved_searches
  def index
    @saved_searches = current_user.saved_searches.ordered
  end

  # GET /saved_searches/new
  def new
    @saved_search = current_user.saved_searches.build
  end

  # POST /saved_searches
  def create
    @saved_search = current_user.saved_searches.build(saved_search_params)

    if @saved_search.save
      redirect_to saved_searches_path, notice: t("flash.create_success", resource: SavedSearch.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /saved_searches/:id/edit
  def edit
  end

  # PATCH /saved_searches/:id
  def update
    if @saved_search.update(saved_search_params)
      redirect_to saved_searches_path, notice: t("flash.update_success", resource: SavedSearch.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /saved_searches/:id
  def destroy
    @saved_search.soft_delete!
    redirect_to saved_searches_path, notice: t("flash.destroy_success", resource: SavedSearch.model_name.human)
  end

  private

  def set_saved_search
    @saved_search = current_user.saved_searches.find(params[:id])
  end

  def saved_search_params
    params.require(:saved_search).permit(:name, :search_query)
  end
end
