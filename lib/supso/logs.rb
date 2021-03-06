require 'logger'

module Supso
  module Logs
    @@ONE_MB_IN_BYTES = 1048576

    @@logger = nil

    def Logs.log_target
      (Supso.project_root || Supso.user_supso_config_root) + '/log/supso.log'
    end

    def Logs.ensure_logger_exists!
      log_file_path =  Logs.log_target
      Supso::Util.ensure_path_exists!(log_file_path)
      @@logger ||= Logger.new(log_file_path, shift_age = 100, shift_size = 100 * @@ONE_MB_IN_BYTES)
    end

    def Logs.debug(message)
      self.ensure_logger_exists!

      puts "[DEBUG] #{ message }"
      @@logger.debug(message)
    end

    def Logs.info(message)
      self.ensure_logger_exists!

      puts "[INFO] #{ message }"
      @@logger.info(message)
    end

    def Logs.warn(message)
      self.ensure_logger_exists!

      puts "[WARN] #{ message }"
      @@logger.warn(message)
    end

    def Logs.error(err, message = nil)
      self.ensure_logger_exists!
      message = err.to_s unless message

      puts "[ERROR] #{ message }"
      puts err.backtrace.join("\n")
      @@logger.error(message)
    end
  end
end
