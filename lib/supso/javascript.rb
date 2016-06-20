module Supso
  class Javascript
    def self.detect_all_projects!
      Javascript.detect_all_npm_projects!
    end

    def self.npm_list_command_response
      if Util.has_command?('npm')
        `npm list --json`
      end
    end

    def self.npm_list_json
      if !Util.has_command?('npm')
        return
      end

      npm_list = Javascript.npm_list_command_response
      npm_project_data = {}
      begin
        npm_project_data = JSON.parse(npm_list)
      rescue
        npm_project_data = {} # TODO maybe log this?
      end

      npm_project_data

    end

    def self.detect_all_npm_projects!
      if !Util.has_command?('npm')
        return
      end

      root_project = Javascript.npm_list_json
      Javascript.detect_npm_project!(root_project['name'], root_project)
    end

    def self.detect_npm_project!(name, project)
      if !project || !project['dependencies']
        return
      end

      dependencies = project['dependencies']
      dependencies.each_key do |dependency_name|
        if dependency_name == 'supported-source'
          Project.add(name, nil, {
                  aliases: [{name: name, platform: 'npm'}],
                  source: 'npm'
              })
        else
          Javascript.detect_npm_project!(dependency_name, dependencies[dependency_name])
        end
      end
    end
  end
end
