require 'fileutils'
require 'bundler'
require 'json'

module Supso
  module Util
    def Util.deep_merge(first, second)
      merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
      first.merge(second, &merger)
    end

    def Util.detect_project_root
      project_root = Dir.getwd
      while true
        if project_root == ""
          project_root = nil
          break
        end

        if Util.project_root?(project_root)
          break
        end

        detect_project_root_splits = project_root.split("/")
        detect_project_root_splits = detect_project_root_splits[0..detect_project_root_splits.length - 2]
        project_root = detect_project_root_splits.join("/")
      end
      
      if project_root == nil || project_root == ''
        project_root = Dir.getwd
      end

      project_root
    end

    def Util.project_root?(path)
      base_file_names = ['Gemfile', 'package.json', '.supso', 'environment.yml', 'requirements.txt', 'setup.py']
      for name in base_file_names
        if File.exist?(path + '/' + name)
          return true
        end
      end

      false
    end

    def Util.ensure_path_exists!(full_path)
      split_paths = full_path.split('/')
      just_file_path = split_paths.pop
      directory_path = split_paths.join('/')
      FileUtils.mkdir_p(directory_path)
      FileUtils.touch("#{ directory_path }/#{ just_file_path }")
    end

    def Util.has_command?(command)
      !!Util.which(command)
    end

    def Util.which(command)
      command = Util.sanitize_command(command)
      response = `which #{ command }`
      response && response.length > 0 ? response : nil
    end

    def Util.sanitize_command(command)
      command.gsub(/[^-_\w]/, '')
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
      begin
        Bundler.require(:default, :development, :test, :production)
      rescue Gem::LoadError, Bundler::GemfileNotFound
        # Keep going
      end
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
