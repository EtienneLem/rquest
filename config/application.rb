# encoding: utf-8
require File.expand_path('../boot', __FILE__)
require 'json'

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

    get %r{/(s\d+)-(p\d+)-(t\d+)(-(s\d+))?$} do
      user_key, playlist_key, song_key, requester_key = get_captures_variables
      request = ::Rdio.get(keys: params[:captures].join(','))

      @user = request[user_key]
      @playlist = request[playlist_key]
      @song = request[song_key]
      @requester = requester_key ? request[requester_key] : nil

      if error = params[:error]
        error = error.gsub('-', ' ')
        @error = error.slice(0, 1).capitalize + error.slice(1..-1)
      end

      @success = params[:success]

      erb :request
    end

    get %r{/(s\d+)-(p\d+)-(t\d+)(-(s\d+))?/add} do
      user_key, playlist_key, song_key, requester_key = get_captures_variables

      requester = requester_key ? "-#{requester_key}" : ''
      redirect_url = "#{user_key}-#{playlist_key}-#{song_key}#{requester}"

      return redirect "#{redirect_url}?error=please-log-in" if !logged_in?
      return redirect "#{redirect_url}?error=nice-try-#{current_user[:username]}" if current_user[:id] != user_key

      playlists = ::Rdio.playlists(user: current_user[:id])['owned']
      playlists.map! {|p| p['key'] }

      return redirect "#{redirect_url}?error=not-your-playlist" if !playlists.include?(playlist_key)

      request = ::Rdio.add_to_playlist(
        { playlist: playlist_key, tracks: song_key },
        { token: current_user[:token], token_secret: current_user[:token_secret] }
      )

      return redirect "#{redirect_url}?error=unknown-error-please-try-again" if !request
      redirect "#{redirect_url}?success=true"
    end

    get '/auth/rdio/callback' do
      log_user_in(request.env['omniauth.auth'])
      redirect request.env['omniauth.origin'].split('?')[0] || '/'
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

    private
    def get_captures_variables
      legnth_to_slice = params[:captures][3] ? 1 : 2
      params[:captures].slice!(3, legnth_to_slice)

      user_key = params[:captures][0]
      playlist_key = params[:captures][1]
      song_key = params[:captures][2]
      requester_key = params[:captures][3] ? params[:captures][3] : nil

      [user_key, playlist_key, song_key, requester_key]
    end

  end
end
