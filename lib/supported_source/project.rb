require File.dirname(__FILE__) + '/../supso/project'

module SupportedSource
  class Project
    def self.add(*args)
      Supso::Project.add(*args)
    end
  end
end
