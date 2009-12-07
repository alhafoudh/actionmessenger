module ActionMessenger
  module Messengers
    class Xmpp4rMessenger < ActionMessenger::Messenger
      def initialize(config_hash = {})
        super(config_hash)
        @config = config_hash

        Jabber::debug = @config['debug'] || false

        @jid = Jabber::JID.new(@config['jid'])

        @client = Jabber::Client.new(@jid)
        @client.connect(@config['host'] || nil, @config['port'] || 5022)
        @client.auth(@config['password']) 

        set_presence

        @client.add_message_callback do |msg|
          message = ActionMessenger::Message.new
          message.kind = msg.type # !!!
          message.to = msg.to.to_s
          message.from = msg.from.to_s
          message.body = msg.body
          message.subject = msg.subject
          message_received(message)
        end

      end

      def set_presence
        @client.send(Jabber::Presence.new)
      end
    
      def send_message(msg)
        message = Jabber::Message.new
        message.type = msg.kind # !!!
        message.to = msg.to
        message.to = Jabber::JID.new(msg.to) unless msg.to.is_a?(Jabber::JID)
        message.subject = msg.subject
        message.body = msg.body

        @client.send(message)
      end
      
      def shutdown
        unless @client.nil?
          @client.close
          @client = nil
        end
      end
    end
  end
end
