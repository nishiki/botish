require 'json'
require 'net/http'
require 'botish/base'

module Botish
  module Plugin
    class Wikipedia < Base
      def run(args)
        params = {
          format:   'json',
          action:   'query',
          list:     'search',
          utf8:      true,
          srsearch:  args[:args]
        }
        uri       = URI('https://fr.wikipedia.org/w/api.php')
        uri.query = URI.encode_www_form(params)

        data      = JSON.parse(Net::HTTP.get(uri))['query']['search'][0]
        title     = data['title']
        url       = URI.encode("https://fr.wikipedia.org/wiki/#{title.tr(' ', '_')}")

        send_msg("PRIVMSG #{args[:channel]} :#{args[:user]}: #{data['title']} => #{url}")
      end
    end
  end
end
