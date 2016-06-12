module Supso
  class Config
    def self.load_config!
      configs_to_load = ["/config.json"]
      configs_to_load.each do |relative_path|
        config_path = Supso.project_supso_config_root + relative_path
        loaded_config = File.exist?(config_path) ? JSON.parse(File.read(config_path)) : {}
        Supso.config = Util.deep_merge(Supso.config, loaded_config)
      end
    end
  end
end
