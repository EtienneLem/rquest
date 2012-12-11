module Rdio
  class Error < StandardError; end

  include HTTParty

  base_uri 'http://api.rdio.com/1/?'

  def self.post(params)
    headers = {'Authorization' => oauth_header(__method__, base_uri, params)}
    super '', headers: headers, body: params
  end

  METHODS = {
    user: 'findUser',
    search: 'search',
    playlists: 'getPlaylists',
  }

  METHODS.each do |wrapper_method, api_method|
    define_singleton_method(wrapper_method) do |params = {}|
      result = post params.merge(method: api_method)
      raise Error, result['message'] if result['status'] == 'error'
      result['result']
    end
  end

private

  def self.oauth_header(method, url, params)
    SimpleOAuth::Header.new(method, url, params,
      consumer_key: ENV['RDIO_KEY'], consumer_secret: ENV['RDIO_SECRET']).to_s
  end
end
