# frozen_string_literal: true

require "capybara/rspec"
require "capybara/cuprite"

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [ 1440, 900 ],
    browser_options: { "no-sandbox": nil },
    inspector: ENV["INSPECTOR"].present?,
    headless: !ENV["HEADLESS"].in?(%w[n 0 no false])
  )
end

Capybara.default_driver = :cuprite
Capybara.javascript_driver = :cuprite
Capybara.default_max_wait_time = 5
