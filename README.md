# Nucdawn

Simple IRC bot written in Elixir using the [Kaguya](https://github.com/Luminarys/Kaguya/) bot framework.
Work-in-progress! I put this together fairly quickly for use on a couple of
private channels and it has not been extensively tested, so all the standard
disclaimers apply. I didn't really have public distribution in mind (hence
the sparse docs); just putting it out there in case it can help someone else.

This is purely a utility bot -- there's no user handling at the moment.
Commands (might or might not be up-to-date):

* `+1 <user>`: Give karma. Currently the bot doesn't check if `<user>` is actually a nick present in the channel, so any word is accepted, however separate scores for users and arbitrary strings would be easy to implement. `.karma` shows top 5 (both receivers/givers) and `.karma <user>` shows stats for a specific user. Data is stored with [PersistentEts](https://github.com/michalmuskala/persistent_ets) ("Ets table backed by a persistence file"), so no external dependencies.
* `.cur <currency>`: Fetch currency ticker using [coinmarketcap.com's](https://coinmarketcap.com/) public API. btc, bch, eth are currently supported; add/change by editing `lib/nucdawn/currency.ex`.
* `.rand <low> <high>`: Random number between `<low>` and `<high>` (inclusive).
* `.w` (without arguments): Random article from English Wikipedia (title, extract and URL).
* `.w <title>`: Search English Wikipedia for `<title>`. If found, return title, extract and URL.
* `.xkcd` or `.xkcd random`: Random Xkcd cartoon (URL, title, alt-text).
* `.xkcd latest`: Latest Xkcd cartoon.
* `.xkcd <number>`: Specified Xkcd cartoon.
* `.weather [units] <location>`: Weather for the specified location using Darksky.net's API (API key necessary). `[units]` (optional) can be `si` or `us`; if left out, Darksky.net will choose units automatically depending on the weather location. Current temperature always shown in both °C and °F. E.g.: `.weather stockholm`, `.weather 90210`.

(Note: starting with `iex` (`iex -S mix`) makes it possible to recompile and reload modules without restarting the bot.
Say you make some changes to `lib/nucdawn/currency.ex`; in `iex` you can then just do `r Nucdawn.Currency`.
[ngircd](https://ngircd.barton.de/) is useful for local testing.)

### URL previews
The bot previews URLs by default. For now it just shows title + host; including descriptions might be too spammy. This can be disabled -- look for the `url_previews` configuration key in `config/config.exs`. Wikipedia.org URLs are detected and handled by the Wikipedia module.

### Weather
The weather module uses the Google Maps Geocoding API to figure out coordinates for a given location,
and then uses these coordinates to check the weather using [Darksky.net's](https://darksky.net) API (using the [Darkskyx](https://github.com/techgaun/darkskyx) module).

Darksky.net requires an API key. Sign up for a free account to get one, and then put the following
in `config/dev.secret.exs` and/or `config/prod.secret.exs`:

```
config :darkskyx,
  api_key: "YOUR_API_KEY_HERE"
```

### Credits
Inspiration/ideas: [Sopel](https://github.com/sopel-irc/sopel), [Roseline](https://github.com/DoumanAsh/Roseline), [twitch-kuma-elixir](https://github.com/KumaKaiNi/twitch-kuma-elixir).

The weather module borrows ideas from [hedwig_weather](https://github.com/ryanwinchester/hedwig_weather) by @ryanwinchester.
