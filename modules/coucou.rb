require 'botish/base'

module Botish
  class Coucou < Base
    def run(args)
      send_msg("PRIVMSG #{args[:channel]} :#{args[:user]}: coucou mon petit")
    end
  end
end
