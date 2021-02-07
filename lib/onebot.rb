# frozen_string_literal: true

require_relative "onebot/version"

module Onebot
  class Error < StandardError; end

  # Raised for valid response with 403 status code.
  class Forbidden < Error; end

  # Raised for valid response with 404 status code.
  class NotFound < Error; end

  autoload :Client, "onebot/client"
end
