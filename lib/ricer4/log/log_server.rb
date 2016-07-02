module Ricer4::Plugins::Log
  class LogServer < Ricer4::Plugin
    
    trigger_is :querylog
    permission_is :owner
    scope_is :user
    
    has_setting name: :enabled, type: :boolean, scope: :server, permission: :operator, default: true
    has_setting name: :logtype, type: :enum,    scope: :server, permission: :owner,    default: :Textlog, enums:[:Binlog, :Textlog]

    def plugin_init
      arm_subscribe('ricer/receive') do |sender, message|
        log(message) if get_setting(:enabled)
      end
      arm_subscribe('ricer/replying') do |sender, reply|
        log(reply) if get_setting(:enabled)
      end
    end
    
    def log(object)
      case get_setting(:logtype)
      when :Binlog; Binlog.irc_message(object)
      when :Textlog; Textlog.irc_message(object)
      end
    end
    
    has_usage  '<boolean>', function: :execute_set
    def execute_set(boolean)
      exec_line "confs querylog enabled #{boolean}"
    end
    
    has_usage '', function: :execute_show
    def execute_show
      rplyp :msg_show_server, server:server.display_name, state:show_setting(:enabled, :server)
    end
    
  end
end
