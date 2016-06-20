require 'json'
require 'uri'
require 'net/http'

Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each do |file|
  require file
end

Dir[File.dirname(__FILE__) + '/supso/*.rb'].each do |file|
  require file
end

module Supso
  extend ModuleVars

  env = ENV['ENV'] || "development"
  create_module_var("environment", env)

  spec = Gem::Specification.find_by_name("supso")

  create_module_var("gem_root", spec.gem_dir)

  detect_project_root = Dir.getwd
  while true
    if detect_project_root == ""
      detect_project_root = nil
      break
    end

    if File.exist?(detect_project_root + '/Gemfile') ||
      File.exist?(detect_project_root + '/package.json')
      break
    end

    detect_project_root_splits = detect_project_root.split("/")
    detect_project_root_splits = detect_project_root_splits[0..detect_project_root_splits.length - 2]
    detect_project_root = detect_project_root_splits.join("/")
  end
  create_module_var("project_root", detect_project_root)
  create_module_var("project_supso_config_root", detect_project_root ? detect_project_root + '/.supso' : nil)
  create_module_var("user_supso_config_root", "#{ Dir.home }/.supso")
  FileUtils.mkdir_p(Supso.user_supso_config_root)
  create_module_var("supso_api_root", "https://supportedsource.org/api/v1/")

  create_module_var("config", {})

  Supso::Config.load_config!
end
