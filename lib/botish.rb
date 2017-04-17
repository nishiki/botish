#!/usr/bin/ruby

require 'socket'

class Botish
  HOST = 'irc.freenode.net'
  PORT = 6667
  USERNAME = 'botish'
  CHANNEL = '#testnishiki'

  def initialize
    @connection = TCPSocket.open(HOST, PORT)

    send("NICK #{USERNAME}")
    send("USER #{USERNAME} localhost * :#{USERNAME}")
    Kernel.loop do
      msg = @connection.gets
      log("<- #{msg}")
      break if msg.include?('End of /MOTD command.')
    end
    send("JOIN #{CHANNEL}")
    send("PRIVMSG #{CHANNEL} :Je suis là :')")
  end

  def listen
    Kernel.loop do
      msg = @connection.gets
      log("<- #{msg}")
      parse(msg)
    end
  end

  private

  def parse(msg)
    case msg
    when /^PING (?<host>.+)/
      send("PONG #{Regexp.last_match('host')}")
    when /^:(?<user>[[:alpha:]]+)([^ ]+)? PRIVMSG #{CHANNEL} :#{USERNAME}: ping/
      send("PRIVMSG #{CHANNEL} :#{Regexp.last_match('user')}: pong")
    end
  end

  def send(msg)
    log("-> #{msg}")
    @connection.puts(msg)
  end

  def log(msg)
    puts "#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%L')} #{msg}"
  end
end
