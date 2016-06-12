require 'json'
require 'openssl'
require 'base64'

module Supso
  class Project
    attr_accessor :name, :api_token, :client_data, :client_token

    def initialize(name, api_token, options = {})
      @name = name
      @api_token = api_token
      @options = options
      @client_data = self.load_client_data
      @client_token = self.load_client_token
    end

    def filename(filetype)
      "#{ Supso.project_supso_config_root }/projects/#{ self.name }.#{ filetype }"
    end

    def data_filename
      self.filename('json')
    end

    def puts_info
      puts "#{ self.name } (#{ self.valid? ? 'valid' : 'not valid' })\n"
    end

    def load_client_data
      if File.exist?(self.data_filename)
        JSON.parse(File.read(self.data_filename))
      else
        {}
      end
    end

    def load_client_token
      if self.token_file_exists?
        File.read(self.token_filename)
      else
        nil
      end
    end

    def token_filename
      self.filename('token')
    end

    def token_file_exists?
      File.exist?(self.token_filename)
    end

    def save_project_data!
      if self.client_data.empty?
        if File.exists?(self.data_filename)
          File.delete(self.data_filename)
        end
        if File.exists?(self.token_filename)
          File.delete(self.token_filename)
        end
      else
        Project.save_project_directory_readme!

        Util.ensure_path_exists!(self.data_filename)
        file = File.open(self.data_filename, 'w')
        file << self.client_data.to_json
        file.close

        Util.ensure_path_exists!(self.token_filename)
        file = File.open(self.token_filename, 'w')
        file << self.client_token
        file.close
      end
    end

    def valid?
      if !self.client_token || !self.client_data
        return false
      end

      if self.client_data['project_api_token'] != self.api_token
        return false
      end

      if !Organization.current_organization ||
          self.client_data['organization_id'] != Organization.current_organization.id
        return false
      end

      public_key = OpenSSL::PKey::RSA.new File.read("#{ Supso.gem_root }/lib/other/supso2.pub")
      digest = OpenSSL::Digest::SHA256.new

      public_key.verify(digest, Base64.decode64(self.client_token), self.client_data.to_json)
    end

    def save_data!
      self.save_project_data
    end

    class << self
      attr_accessor :projects
    end

    def self.projects
      @projects ||= []
    end

    def self.add(name, api_token, options = {})
      project = Project.new(name, api_token, options)
      self.projects << project
    end

    def self.save_project_directory_readme!
      readme_path = "#{ Supso.project_supso_config_root }/README.txt"
      if !File.exists?(readme_path)
        readme_contents = File.open("#{ Supso.gem_root }/lib/templates/project_dir_readme.txt", 'r').read
        Util.ensure_path_exists!(readme_path)
        file = File.open(readme_path, 'w')
        file << readme_contents
        file.close
      end
    end
  end
end
