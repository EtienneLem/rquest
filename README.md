# Rquest

> With great power, comes great responsibility

Lets face it, open collaboration to [Rdio](http://rdio.com/home) playlists is a little bit too permisive and we’re all afraid that someone will screw up our beloved list.
Fear no more for [Rquest](http://rquest.herokuapp.com) is the perfect playlists pull rquest — see what I did? — tool.

Send a request to anyone on Rdio to add a specific track to their playlists whether it’s open to collaboration **or not**.

## One step complete installation
```
git clone git@github.com:EtienneLem/rquest.git
cd rquest
bundle install && npm install
git submodule init && git submodule update
foreman start

```

## Contributors
- [@remiprev](https://github.com/remiprev)

## Credits
- [@rafBM](https://github.com/rafBM) - [Rdio API wrapper](https://github.com/EtienneLem/rquest/blob/master/lib/rquest/rdio.rb)
