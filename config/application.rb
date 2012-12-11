# encoding: utf-8
require File.expand_path('../boot', __FILE__)

module Rquest
  class App < Sinatra::Base
    set :sessions, true
    set :session_secret, "pull-request-meh-playlists"
    set :root, File.expand_path('../../app',  __FILE__)
    set :public_folder, File.expand_path('../../public',  __FILE__)
    set :erb, :layout => :'layouts/application'

    configure :development do
      register Sinatra::Reloader
    end

    get '/' do
      erb :index
    end

    get '/:username/playlists' do
      content_type :json
      rdio = ::Rdio

      user = rdio.search(query: params[:username], types: 'User')
      return nil if user['number_results'] == 0

      user = user['results'][0]
      playlists = rdio.playlists(user: user['key'])['owned']

      {
        user: user,
        playlists: playlists
      }.to_json
    end

    not_found do
      erb :'404'
    end

  end
end
