class Rquest

  GENDERS =
    m: 'his'
    f: 'her'

  constructor: ->
    @html = $('html')

    this.initGender()
    this.initUsername()
    this.initPlaylists()

  # Gender management
  initGender: ->
    @genderSpan = $('#gender')
    @currentGender = GENDERS.m

  updateGender: (genderKey) ->
    gender = GENDERS[genderKey]

    return if gender is @currentGender
    @currentGender = gender

    @genderSpan.html(gender)

  # Username management
  initUsername: ->
    @currentUsername = ''
    @usernameInput = $('input[name="username"]')

    @usernameInput.on 'blur', (e) =>
      username = @usernameInput.val().toLowerCase()

      return if username is @currentUsername
      @currentUsername = username
      @html.addClass('loading')
      @playlistsSelect.attr('disabled', true)

      $.ajax
        url: "/#{username}/playlists"
        success: (data) =>
          @html.removeClass('loading')
          return unless data

          data = JSON.parse(data)

          this.updateGender(data.user.gender)
          this.updatePlaylists(data.playlists)

  # Playlists management
  initPlaylists: ->
    @playlistsSelect = $('select[name="playlists"]')

  updatePlaylists: (playlists) ->
    playlistsHtml = ''

    for playlist, i in playlists
      playlistsHtml += """<option value="#{playlist.key}">#{playlist.name}</option>"""

    @playlistsSelect.removeAttr('disabled')
    @playlistsSelect.html(playlistsHtml)


# Initialization
new Rquest
