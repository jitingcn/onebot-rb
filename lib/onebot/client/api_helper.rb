require "json"

module Onebot
  class Client
    module ApiHelper
      attr_accessor :func_list

      METHODS_LIST_FILE = File.expand_path("api.json", __dir__)

      class << self
        def methods_list(file = METHODS_LIST_FILE)
          @func_list = JSON.parse(File.read(file))
        end

        def get_default(str)
          str.sub!(/^`(.+)`$/, '\1')
          return str.to_i if str =~ /^[+-]?\d+$/
          return true if str == "true"
          return false if str == "false"

          m = str.match(/^\s*(\d+)\s*\*\s*(\d+)\s*/)
          return m[1].to_i * m[2].to_i if m

          str
        end

        def parse_param(input)
          return nil unless input

          output = ""

          params = input.map do |param, extra|
            default = case extra["default"]
                      when "空" then ""
                      when "-" then nil
                      when nil then nil
                      else get_default extra["default"]
                      end

            next param if default.nil?

            { "#{param}": default }
          end

          params.each do |param|
            output << if param.instance_of?(Hash)
                        if param.values[0].instance_of?(String)
                          "#{param.keys[0]}: '#{param.values[0]}'"
                        else
                          "#{param.keys[0]}: #{param.values[0]}"
                        end
                      else
                        "#{param}:nil"
                      end
            output << ","
          end
          output.delete_suffix!(",")
          output.to_s
        end

        # Defines method with underscored name to post to specific endpoint:
        #
        #   define_method :send_private_msg
        def define_helpers(list)
          list.each do |method_name, method_info|
            # puts "define #{method_name}"
            params = parse_param(method_info["params"])
            if method_name[0] == "."
              class_eval %(
                private def #{method_name[1..-1]} (params = { #{params} })
                  request("#{method_name}", params)
                end
              ), __FILE__, __LINE__ - 4
            else
              class_eval %(
                def #{method_name} (params = { #{params} })
                  request("#{method_name}", params)
                end
              ), __FILE__, __LINE__ - 4
            end
          end
        end
      end

      methods_list
      define_helpers(@func_list)
    end
  end
end
