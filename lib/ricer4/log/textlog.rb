module Ricer4::Plugins::Log
  class Textlog
    
    def self.irc_message(object)
      input = !object.is_a?(Ricer4::Reply)
      message = input ? object : object.message
      text = input ? "#{sign(input)} #{message.raw}" : "#{sign(input)} #{object.text}"
      text = text.force_encoding('UTF-8')
      log_to_file(serverlog(message.server), text, false)
      log_to_file(userlog(message.sender), text, true) if message.from_user?
      log_to_file(channellog(message.target), text, true) if message.to_channel?
    end
    
    private

    def self.sign(input); input ? '<<' : '>>'; end

    def self.log_to_file(logger, text, close_logger)
      logger.formatter = proc do |severity, datetime, progname, msg| "[#{datetime}] #{msg}\n"; end
      logger.info text
      logger.close if close_logger
    end
    
    ##############
    ### Server ###
    ##############
    @@SERVERLOGS = {}
    def self.serverlog(server)
      @@SERVERLOGS[server] ||= bot.log.logger("#{server.id}.#{server.domain}.log".force_encoding('UTF-8'))
      @@SERVERLOGS[server]
    end

    #############
    ### Query ###
    #############
    def self.userlog(user)
      server = user.server
      username = user.name.gsub(/[^a-zA-Z0-9_]/, '!')
      bot.log.logger("#{server.id}.#{server.domain}/user/#{username}.log".force_encoding('UTF-8'))
    end

    ###############
    ### Channel ###
    ###############
    def self.channellog(channel)
      server = channel.server
      channelname = channel.name.gsub(/[^#a-zA-Z0-9]/, '_')
      bot.log.logger("#{server.id}.#{server.domain}/channel/#{channelname}.log".force_encoding('UTF-8'))
    end

  end
end
