require 'yaml'

module Supso
  class User
    attr_accessor :email, :name, :id, :auth_token

    @@current_user = nil

    def initialize(email, name, id, auth_token = nil)
      @email = email
      @name = name
      @id = id
      @auth_token = auth_token
    end

    def save_to_file!
      Util.ensure_path_exists!(User.current_user_filename)
      file = File.open(User.current_user_filename, 'w')
      file << self.saved_data.to_json
      file.close
      User.save_user_supso_readme!
    end

    def saved_data
      data = {
          'email' => self.email
      }
      data['name'] = self.name if self.name
      data['id'] = self.id if self.id
      data['auth_token'] = self.auth_token if self.auth_token
      data
    end

    def self.current_user_filename
      "#{ Supso.user_supso_config_root }/current_user.json"
    end

    def self.readme_filename
      "#{ Supso.user_supso_config_root }/README.txt"
    end

    def self.current_user_from_file
      if !File.exist?(User.current_user_filename)
        return nil
      end

      user_data = {}
      begin
        user_data = JSON.parse(File.read(User.current_user_filename))
        user_data = {} if !user_data.is_a?(Object)
      rescue JSON::ParserError => err
        user_data = {}
      end

      if user_data['email'] || user_data['auth_token']
        User.new(user_data['email'], user_data['name'], user_data['id'], user_data['auth_token'])
      else
        nil
      end
    end

    def self.current_user
      @@current_user ||= User.current_user_from_file
    end

    def self.set_current_user!(email, name, id, auth_token = nil)
      @@current_user = User.new(email, name, id, auth_token)
      @@current_user.save_to_file!
    end

    def self.attach_to_email!(email)
      data = {
          email: email,
      }

      response = Util.http_post("#{ Supso.supso_api_root }users/attach", data)

      if response['success']
        User.set_current_user!(response['user']['email'], response['user']['name'],
            response['user']['id'])
      else
        puts response['reason']
        # Anything here needed?
      end
    end

    def self.log_in_with_password!(email, password)
      data = {
          email: email,
          password: password,
      }

      response = Util.http_post("#{ Supso.supso_api_root }sign_in", data)

      if response['success']
        User.set_current_user!(response['user']['email'], response['user']['name'],
            response['user']['id'], response['auth_token'])
        if Organization.current_organization.nil?
          Organization.set_current_organization!(response['organization']['name'], response['organization']['id'])
        end
        [true, nil]
      else
        [false, response['reason']]
      end
    end

    def self.log_in_with_confirmation_token!(email, confirmation_token)
      data = {
          email: email,
          confirmation_token: confirmation_token,
      }

      response = Util.http_post("#{ Supso.supso_api_root }users/confirm", data)

      if response['success']
        User.set_current_user!(response['user']['email'], response['user']['name'],
            response['user']['id'], response['auth_token'])
        if Organization.current_organization.nil?
          Organization.set_current_organization!(response['organization']['name'], response['organization']['id'])
        end
        [true, nil]
      else
        [false, response['reason']]
      end
    end

    def self.log_out!
      if File.exists?(User.current_user_filename)
        user = User.current_user
        if user && user.auth_token
          data = {
              version: Supso::VERSION,
              auth_token: user.auth_token,
              user_id: user.id,
          }

          response = Util.http_post("#{ Supso.supso_api_root }sign_out", data)

          if response['success']
            # No need to say anything like 'logout succeeded'
          else
            puts response['reason']
          end
        end

        File.delete(User.current_user_filename)
        @@current_user = nil
      end
    end

    def self.save_user_supso_readme!
      if !File.exists?(User.readme_filename)
        readme_contents = File.open("#{ Supso.gem_root }/lib/templates/user_dir_readme.txt", 'r').read
        Util.ensure_path_exists!(User.readme_filename)
        file = File.open(User.readme_filename, 'w')
        file << readme_contents
        file.close
      end
    end
  end
end
