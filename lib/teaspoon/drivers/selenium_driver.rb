require "selenium-webdriver"
require "teaspoon/runner"

module Teaspoon
  module Drivers
    class SeleniumDriver < BaseDriver

      def run_specs(suite, url, driver_cli_options = nil)
        runner = Teaspoon::Runner.new(suite)
        driver = Selenium::WebDriver.for(:firefox, parse_cli_options(driver_cli_options))
        driver.navigate.to(url)

        Selenium::WebDriver::Wait.new(timeout: 180, interval: 0.01, message: "Timed out").until do
          done = driver.execute_script("return window.Teaspoon && window.Teaspoon.finished")
          driver.execute_script("return window.Teaspoon && window.Teaspoon.getMessages() || []").each do |line|
            runner.process("#{line}\n")
          end
          done
        end

        runner.failure_count
      ensure
        driver.quit if driver
      end

      private

      # Naively convert command line options into a hash.
      def parse_cli_options(options_string)
        return {} unless options_string

        parsed_options = options_string.split(/\s+/).inject({}) do |opts, key_and_value|
          raw_key, value = key_and_value.split('=')
          key = raw_key.gsub(/\A-{1,2}/, '').to_sym
          opts[key] = value
          opts
        end
      end

    end
  end
end

