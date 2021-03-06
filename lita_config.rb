Lita.configure do |config|
  # The name your robot will use.
  config.robot.name = "kloudbot"

  # The locale code for the language to use.
  # config.robot.locale = :en

  # The severity of messages to log. Options are:
  # :debug, :info, :warn, :error, :fatal
  # Messages at the selected level and above will be logged.
  config.robot.log_level = :info

  # An array of user IDs that are considered administrators. These users
  # the ability to add and remove other users from authorization groups.
  # What is considered a user ID will change depending on which adapter you use.
  config.robot.admins = [
    "U043SBPU9", # @jay
  ]

  if ENV["LITA_ENV"] == "production"
    config.redis[:url] = ENV.fetch("REDISTOGO_URL")
    config.http.port = ENV.fetch("PORT")
    config.robot.adapter = :slack
  else
    config.robot.adapter = :shell
  end

  config.adapters.slack.token = ENV.fetch("SLACK_TOKEN") { "NOPE" }

  normalized_karma_user_term = ->(user_id, user_name) {
    "@#{user_id} (#{user_name})" #=> @UUID (Liz Lemon)
  }
  
  config.handlers.giphy.api_key = "dc6zaTOxFJmzC"

  config.handlers.slack_karma_sync.user_term_normalizer = normalized_karma_user_term
  config.handlers.karma.cooldown = nil
  config.handlers.karma.link_karma_threshold = nil
  config.handlers.karma.term_pattern = /[<:][^>:]+[>:]|[\[\]\p{Word}\._|\{\}]{2,}/
  config.handlers.karma.term_normalizer = lambda do |full_term|
    term = full_term.to_s.strip.sub(/[<:]([^>:]+)[>:]/, '\1')
    user = Lita::User.fuzzy_find(term.sub(/\A@/, ''))

    if user
      normalized_karma_user_term.call(user.id, user.name)
    else
      term.downcase
    end
  end

  # config.handlers.memegen.command_only = false
  # config.handlers.memegen.username = ENV["MEMEGEN_USER"]
  # config.handlers.memegen.password = ENV["MEMEGEN_PASS"]
  # config.handlers.tinysong.api_key = ENV["TINYSONG_KEY"]
  # config.handlers.static_meme.mapping = {
    # /^where('| i)s #{config.robot.name}[?]?$/i => "There is no #{config.robot.name}. There is only Zuul.",
    # /^thank(s| ?you)\s#{config.robot.name}/i => "At your service.",
    # /top .* the mornin/i => "And the rest of the day to yourself.",
  # }
end
