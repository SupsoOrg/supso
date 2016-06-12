require 'fileutils'
require 'bundler'
require 'json'

module Supso
  module Util
    def Util.deep_merge(first, second)
      merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
      first.merge(second, &merger)
    end

    def Util.ensure_path_exists!(full_path)
      split_paths = full_path.split('/')
      just_file_path = split_paths.pop
      directory_path = split_paths.join('/')
      FileUtils.mkdir_p(directory_path)
      FileUtils.touch("#{ directory_path }/#{ just_file_path }")
    end

    def Util.http_get(url)
      json_headers = {
          "Content-Type" => "application/json",
          "Accept" => "application/json",
      }
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      if url.start_with?('https://')
        http.use_ssl = true
      end
      response = http.get(uri.path, json_headers)

      if response.code.to_i == 200
        return JSON.parse(response.body)
      else
        raise StandardError.new("Error #{ response } for #{ url }")
      end
    end

    def Util.http_post(url, data = {})
      json_headers = {
          "Content-Type" => "application/json",
          "Accept" => "application/json",
      }

      data[:version] = Supso::VERSION

      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      if url.start_with?('https://')
        http.use_ssl = true
      end
      response = http.post(uri.path, data.to_json, json_headers)

      if response.code.to_i == 200
        return JSON.parse(response.body)
      else
        raise StandardError.new("Error #{ response } for #{ url }")
      end
    end

    def Util.is_email?(email)
      !!/\A[^@]+@([^@\.]+\.)+[^@\.]+\z/.match(email)
    end

    def Util.pluralize(count, word)
      if count == 1
        word
      else
        "#{ word }s"
      end
    end

    def Util.require_all_gems!
      Bundler.require(:default, :development, :test, :production)
    end

    def Util.underscore_to_camelcase(str)
      str.split('_').map{ |chunk| chunk.capitalize }.join
    end

    def Util.camelcase_to_underscore(str)
      str.gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
          .gsub(/([a-z\d])([A-Z])/,'\1_\2')
          .tr("-", "_")
          .downcase
    end
  end
end
