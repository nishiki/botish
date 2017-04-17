module Botish
  class Coucou
    def initialize(connection, args)
      @connection = connection

      @connection.puts("PRIVMSG #{args[:channel]} :#{args[:user]}: coucou mon petit")
    end
  end
end
