require 'json'

module Supso
  class Organization
    attr_accessor :name, :id

    @@current_organization = nil

    def initialize(name, id)
      @name = name
      @id = id
    end

    def save_to_file!
      Util.ensure_path_exists!(Organization.current_organization_filename)
      file = File.open(Organization.current_organization_filename, 'w')
      file << self.saved_data.to_json
      file.close
      Project.save_project_directory_readme!
    end

    def saved_data
      data = {}
      data['name'] = self.name if self.name
      data['id'] = self.id if self.id
      data
    end

    def self.current_organization_filename
      "#{ Supso.project_supso_config_root }/current_organization.json"
    end

    def self.current_organization_from_file
      organization_data = {}
      begin
        organization_data = JSON.parse(File.read(Organization.current_organization_filename))
        organization_data = {} if !organization_data.is_a?(Object)
      rescue
        organization_data = {}
      end

      if organization_data['id']
        Organization.new(organization_data['name'], organization_data['id'])
      else
        nil
      end
    end

    def self.current_organization
      @@current_organization ||= Organization.current_organization_from_file
    end

    def self.current_organization_or_fetch
      org = Organization.current_organization

      if !org
        Organization.fetch_current_organization!
        org = Organization.current_organization
        if !org
          raise StandardError.new('Could not find current organization')
        else
          org
        end
      end
    end

    def self.set_current_organization!(name, id)
      @@current_organization = Organization.new(name, id)
      @@current_organization.save_to_file!
    end

    def self.delete_current_organization!
      @@current_organization = nil
      if File.exists?(Organization.current_organization_from_file)
        File.delete(Organization.current_organization_from_file)
      end
    end

    def self.fetch_current_organization!
      user = User.current_user
      data = {
          auth_token: user.auth_token,
          user_id: user.id,
      }
      response = Util.http_post("#{ Supso.supso_api_root }users/me/current_organization", data)

      if response['success']
        org = response['organization']
        Organization.set_current_organization!(org['name'], org['id'])
      else
        puts response['reason']
      end
    end
  end
end
