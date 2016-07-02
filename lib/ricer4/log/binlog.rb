module Ricer4::Plugins::Log
  class Binlog < ActiveRecord::Base
    
    arm_install do |m|
      m.create_table :binlogs do |t|
        t.integer  :user_id
        t.integer  :channel_id
        t.string   :input
        t.string   :output
        t.timestamp :created_at, :null => false
      end
    end

    def self.irc_message(object)
      input = object.is_a?(Ricer4::Message)
      message = input ? object : object.message
      create!({
        user_id: message.sender.id,
        channel_id: message.to_channel? ? message.target.id : nil,
        input: input ? message.raw : nil,
        output: input ? nil : object.text,
        created_at: input ? message.received_at : object.sent_at,
      })
    end

  end
end
