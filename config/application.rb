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

    use OmniAuth::Builder do
      provider :rdio, ENV['RDIO_KEY'], ENV['RDIO_SECRET']
    end

    get '/' do
      erb :index
    end

    post '/create' do
      @user = JSON.parse(params[:user])
      @song = JSON.parse(params[:song])
      @playlist = JSON.parse(params[:playlists])

      erb :create
    end

    get '/create' do
      redirect '/'
    end

    get '/:username/playlists' do
      content_type :json
      rdio = ::Rdio

      user = rdio.user(vanityName: params[:username], extras: 'username')
      return nil unless user

      playlists = rdio.playlists(user: user['key'])['owned']

      {
        user: user,
        playlists: playlists
      }.to_json
    end

    get '/search/*' do
      content_type :json
      rdio = ::Rdio

      search = params[:splat][0].gsub('+', ' ')
      songs = rdio.search(query: search, types: 'Track', count: 5)
      songs.to_json
    end

    get %r{/(s\d+)-(p\d+)-(t\d+)(-(s\d+))?} do
      legnth_to_slice = params[:captures][3] ? 1 : 2
      params[:captures].slice!(3, legnth_to_slice)

      user_key = params[:captures][0]
      playlist_key = params[:captures][1]
      song_key = params[:captures][2]
      requester_key = params[:captures][3] ? params[:captures][3] : nil

      request = ::Rdio.get(keys: params[:captures].join(','))

      @user = request[user_key]
      @playlist = request[playlist_key]
      @song = request[song_key]
      @requester = requester_key ? request[requester_key] : nil

      erb :request
    end

    get '/auth/rdio/callback' do
      log_user_in(request.env['omniauth.auth'])
      redirect request.env['omniauth.origin'] || '/'
    end

    get '/auth/failure' do
      redirect '/'
    end

    get '/logout' do
      session.clear
      redirect '/'
    end

    not_found do
      erb :'404'
    end

  end
end
