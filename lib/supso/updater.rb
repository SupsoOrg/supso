module Supso
  module Updater
    def Updater.update
      user = User.current_user
      if user && user.auth_token
        Updater.update_returning_user(user)
      else
        Updater.update_first_time_user
      end
    end

    def Updater.update_first_time_user
      puts "Supported Source lets you subscribe to projects, so that you can receive urgent security announcements, important new versions, and other information via email."

      Util.require_all_gems!
      puts "You are using the following projects with Supported Source:"
      Project.projects.each do |project|
        puts "  #{ project.name }"
      end

      puts "You can opt-out if you wish, however you must provide a valid email, in order to receive the confirmation token."

      email = Commands.prompt_email
      User.attach_to_email!(email)

      succeeded = false
      while !succeeded
        token = Commands.prompt_confirmation_token(email)
        succeeded, reason = User.log_in_with_confirmation_token!(email, token)
        if !succeeded && reason
          puts reason
        end
      end

      Updater.update_projects!
    end

    def Updater.update_returning_user(user)
      org = Organization.current_organization_or_fetch
      Util.require_all_gems!
      Updater.update_projects!
    end

    def Updater.update_projects!(projects = nil)
      if projects.nil?
        projects = Project.projects
      end

      if projects.length == 0
        puts "No projects in list to update."
        return
      end

      puts "Updating #{ Util.pluralize(projects.length, 'project') }..."

      user = User.current_user
      organization = Organization.current_organization
      project_api_tokens = projects.map { |project| project.api_token }

      data = {
          auth_token: user.auth_token,
          user_id: user.id,
          project_api_tokens: project_api_tokens,
      }

      response = Util.http_post("#{ Supso.supso_api_root }organizations/#{ organization.id }/client_tokens", data)

      if response['success']
        response['projects'].each do |project_response|
          client_data = project_response['client_data']
          client_token = project_response['client_token']
          api_token = client_data['project_api_token']
          project = projects.find { |project| project.api_token == api_token }
          if project.nil?
            next
          end
          project.client_data = client_data
          project.client_token = client_token
          project.save_project_data!
        end
      else
        puts response['reason']
      end
    end
  end
end
