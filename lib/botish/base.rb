module Botish
  class Base
    def initialize(connection)
      @connection = connection
    end

    def run(args) end

    private

    def send_msg(msg)
      log("-> #{msg}")
      @connection.puts(msg)
    end

    def log(msg)
      puts "#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%L')} #{msg}"
    end
  end
end
