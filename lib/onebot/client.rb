require "json"
require "excon"

module Onebot
  class Client
    require_relative "client/api_helper"
    include ApiHelper

    attr_reader :client, :server

    def initialize(host, token = nil, **options)
      @server = host || "http://localhost:5700"
      @token = token || options[:token]
      Excon.defaults[:headers].merge({ "Authorization" => "Bearer #{@token}" }) if @token
      @client = Excon.new(@server)
    end

    def request(action, body = {})
      pp body
      response = client.get(path: action, query: body)
      # raise self.class.error_for_response(response) if response.status >= 300
      JSON.parse(response.body)
    end
  end
end
