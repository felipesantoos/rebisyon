# frozen_string_literal: true

require "simplecov"

SimpleCov.start "rails" do
  add_filter "/spec/"
  add_filter "/config/"
  add_filter "/vendor/"

  add_group "Controllers", "app/controllers"
  add_group "Models", "app/models"
  add_group "Services", "app/services"
  add_group "Jobs", "app/jobs"
  add_group "Mailers", "app/mailers"
end
