module Ricer4::Plugins::Log
  class LogChannel < Ricer4::Plugin
    
    trigger_is :log
    scope_is :channel
    permission_is :operator
    
    has_setting name: :enabled, type: :boolean, scope: :channel, permission: :operator, default: true
    has_setting name: :logtype, type: :enum,    scope: :channel, permission: :owner,    default: :Textlog, enums:[:Binlog, :Textlog]

    def plugin_init
      arm_subscribe('ricer/receive') do |sender, message|
        log(message) if channel && setting(:enabled)
      end
      arm_subscribe('ricer/replying') do |sender, reply|
        log(reply) if channel && setting(:enabled)
      end
    end
    
    def log(object)
      case get_setting(:logtype)
      when :Binlog; Binlog.irc_message(object)
      when :Textlog; Textlog.irc_message(object)
      end
    end
    
    has_usage '<boolean>', function: :execute_set
    def execute_set(boolean)
      exec_line "confc log enabled #{boolean}"
    end
    
    has_usage '', function: :execute_show
    def execute_show
      rply :msg_show, channel:channel.display_name, state:show_setting(:enabled, :channel)
    end
    
  end
end
