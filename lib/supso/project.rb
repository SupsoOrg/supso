require 'json'
require 'openssl'
require 'base64'

module Supso
  class Project
    attr_accessor :name, :api_token, :client_data, :client_token, :source, :aliases

    # Validities
    MISSING_DATA = :missing_token
    MISSING_TOKEN = :missing_token
    DIFFERENT_API_TOKEN = :different_api_token
    INVALID_TOKEN = :missing_token
    MISSING_ORGANIZATION = :missing_organization
    DIFFERENT_ORGANIZATION = :different_organization
    VALID = :valid

    def initialize(name, api_token, options = {})
      @name = name
      @api_token = api_token
      @options = options
      @client_data = self.load_client_data
      @client_token = self.load_client_token
      @source = options['source'] || options[:source]
      @aliases = options['aliases'] || options[:aliases] || []
    end

    def filename(filetype)
      "#{ Supso.project_supso_config_root }/projects/#{ self.name }.#{ filetype }"
    end

    def data_filename
      self.filename('json')
    end

    def identification_data
      {
          name: self.name,
          api_token: self.api_token,
          aliases: self.aliases,
          source: self.source,
      }
    end

    def puts_info
      puts "#{ self.name }"

      if self.source
        human_readable_source = self.source == 'add' ? 'add (ruby)' : self.source
        puts "  Source: #{ human_readable_source }"
      end

      if self.valid?
        puts "  Valid: Yes"
      else
        puts "  Valid: No"
        puts "  Reason: #{ self.validity_explanation }"
      end
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

    def organization_id
      self.client_data['organization_id']
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
      self.validity == :VALID
    end

    def validity
      if !self.client_token
        return MISSING_TOKEN
      end

      if !self.client_data
        return MISSING_DATA
      end

      if self.client_data['project_api_token'] != self.api_token
        return DIFFERENT_API_TOKEN
      end

      if !Organization.current_organization
        return MISSING_ORGANIZATION
      end

      if self.organization_id != Organization.current_organization.id
        return DIFFERENT_ORGANIZATION
      end

      public_key = OpenSSL::PKey::RSA.new File.read("#{ Supso.gem_root }/lib/other/supso2.pub")
      digest = OpenSSL::Digest::SHA256.new

      if !public_key.verify(digest, Base64.decode64(self.client_token), self.client_data.to_json)
        return INVALID_TOKEN
      end

      return VALID
    end

    def validity_explanation
      case self.validity
      when MISSING_TOKEN
        "Missing client token. Run `supso update` to update the token."
      when MISSING_DATA
        "Missing client data. Run `supso update` to update the data."
      when DIFFERENT_API_TOKEN
        "Different api token. The project's api token is different from the project api token listed in your client data. Make sure your projects are all up-to-date and you have the latest client token from `supso update`."
      when MISSING_ORGANIZATION
        "Missing organization. Run `supso update` to update your organization file."
      when DIFFERENT_ORGANIZATION
        "Different organization. The client token uses organization id #{ organization_id }, but " +
            "your current organization id is #{ Organization.current_organization['id'] } (#{ Organization.current_organization['name'] })."
      when INVALID_TOKEN
        "Invalid client token. Run `supso update` to update the token."
      when VALID
        "Valid."
      else
        "Invalid."
      end
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
      options['source'] ||= 'add'
      project = Project.new(name, api_token, options)
      self.projects << project
    end

    def self.detect_all_projects!
      Util.require_all_gems!
      Javascript.detect_all_projects!
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

    def self.aliases_match?(aliases1 = [], aliases2 = [])
      aliases2.each do |first_alias|
        if aliases1.any? { |second_alias| second_alias['name'] == first_alias['name'] &&
            second_alias['platform'] == first_alias['platform'] }
          return true
        end
      end

      false
    end
  end
end
