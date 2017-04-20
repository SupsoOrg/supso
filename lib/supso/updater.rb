module Supso
  module Updater
    def Updater.update(project_references = [])
      user = User.current_user
      if user && user.auth_token
        Updater.update_returning_user(user, project_references)
      else
        Updater.update_first_time_user(project_references)
      end
    end

    def Updater.update_first_time_user(project_references = [])
      puts "Super Source lets you subscribe to projects, so that you can receive urgent security announcements, important new versions, and other information via email."

      Project.detect_all_projects!

      if project_references.length == 0
        puts "You are using the following projects with Super Source:"
        Project.projects.each do |project|
          puts "  #{ project.name }"
        end
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

      projects = Project.get_from_references(project_references)
      Updater.update_projects!(projects)
    end

    def Updater.update_returning_user(user, project_references)
      org = Organization.current_organization_or_fetch
      Project.detect_all_projects!
      projects = Project.get_from_references(project_references)
      Updater.update_projects!(projects)
    end

    def Updater.update_projects!(projects = [])
      if projects.nil? || projects.length == 0
        projects = Project.projects
      end

      if projects.length == 0
        puts "No projects in list to update."
        return
      end

      if projects.length == 1
        puts "Updating 1 project (#{ projects.first.name })..."
      else
        puts "Updating #{ projects.length } projects..."
      end

      user = User.current_user
      organization = Organization.current_organization

      data = {
          auth_token: user.auth_token,
          user_id: user.id,
          projects: projects.map { |project| project.identification_data },
      }

      response = Util.http_post("#{ Supso.supso_api_root }organizations/#{ organization.id }/client_tokens", data)

      if response['success']
        response['projects'].each do |project_response|
          client_data = project_response['client_data']
          client_token = project_response['client_token']
          api_token = client_data['project_api_token']
          aliases = client_data['project_aliases'] || []
          project = projects.find { |find_project| find_project.api_token == api_token }
          if project.nil?
            project = projects.find { |find_project| Project.aliases_match?(find_project.aliases, aliases) }

            if project.nil?
              next # Could log warning
            end
          end
          project.client_data = client_data
          project.client_token = client_token
          project.aliases = aliases
          project.save_project_data!
        end
      else
        puts response['reason']
      end
    end
  end
end
