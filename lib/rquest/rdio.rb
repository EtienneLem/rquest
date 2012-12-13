module Rdio
  class Error < StandardError; end

  include HTTParty

  base_uri 'http://api.rdio.com/1/?'

  def self.post(params, tokens)
    headers = {'Authorization' => oauth_header(__method__, base_uri, params, tokens)}
    super '', headers: headers, body: params
  end

  METHODS = {
    get: 'get',
    user: 'findUser',
    search: 'search',
    playlists: 'getPlaylists',
    add_to_playlist: 'addToPlaylist',
  }

  METHODS.each do |wrapper_method, api_method|
    define_singleton_method(wrapper_method) do |params = {}, tokens = {}|
      result = post params.merge(method: api_method), tokens
      raise Error, result['message'] if result['status'] == 'error'
      result['result']
    end
  end

private

  def self.oauth_header(method, url, params, user_tokens)
    tokens = { consumer_key: ENV['RDIO_KEY'], consumer_secret: ENV['RDIO_SECRET'] }
    tokens = tokens.merge(user_tokens)
    SimpleOAuth::Header.new(method, url, params, tokens).to_s
  end
end
