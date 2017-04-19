require 'botish/base'

module Botish
  module Plugin
    class Coucou < Base
      def run(args)
        send_msg("PRIVMSG #{args[:channel]} :#{args[:user]}: coucou mon petit")
      end
    end
  end
end
