"""
  Dyno Custom Commands compiler
"""

ARGUMENT_INDEX = /\$[0-9]+\+?/g
USER_PROPERTYS = ['id', 'name', 'username', 'discriminator', 'nick', 'game', 'avatar', 'mention', 'createdAt', 'joinedAt']
USER_IDENTIFYER = new RegExp("{user\\.?(#{USER_PROPERTYS.join('|')})?}", 'g')
SERVER_PROPERTYS = ['id', 'name', 'icon', 'memberCount', 'ownerId', 'createdAt', 'region']
SERVRE_IDENTIFYER = new RegExp("{server\\.?(#{SERVER_PROPERTYS.join('|')})?}", 'g')
CHANNEL_PROPERTYS = ['id', 'name', 'mention']
CHANNEL_IDENTIFYER = new RegExp("{channel\\.?(#{CHANNEL_PROPERTYS.join('|')})?}", 'g')

BITS = ['time', 'time12', 'date', 'datetime', 'datetime12']
TIME_OR_DATE = new RegExp("{(#{BITS.join('|')})}", 'g')
MENTIONS = /{(@|#|&)[^}]*}/g
SERVER_MENTIONS = /{(everyone|here)}/g
NO_EVERYONE = /{noeveryone}/g

DEFAULT_DATA = 
  args: []
  user: null
  server: null
  channel: null
  mentionValidator: (type, name) -> "#{name}"

class Compiler
  constructor: (data) -> 
    @__checkData data
    @data = Object.assign DEFAULT_DATA, data or {}
    @_allowEveryOne = true

  compile: (str) ->
    return '' if not str

    self = @
    # replace "$1" to the argument index
    return str.replace(ARGUMENT_INDEX, (_) -> 
      indexList = _.slice(1)
      getIndex = () -> if +indexList - 1 <= 0 then 0 else +indexList - 1
      isMore = indexList[indexList.length-1] is '+'

      return if isMore then self.data.args.slice(getIndex()).join(' ') else self.data.args[getIndex()]
    )
    # replace "{user...}" to user data
    .replace(USER_IDENTIFYER, (_) -> 
      content = _.slice(1, -1)
      return "<@!#{self.data.user.id}>" if content is 'user'
      userFindArgument = content.split('.')[1]

      validfrom = ['id', 'username', 'discriminator', 'avatar', 'createdAt', 'joinedAt']
      return self.data.user[userFindArgument] if validfrom.includes(userFindArgument)

      return nick or "#{self.data.user.username}##{self.data.user.discriminator}" if userFindArgument is 'nick'
      return "#{self.data.user.username}##{self.data.user.discriminator}" if userFindArgument is 'name'
      return "<@#{self.data.user.id}>" if userFindArgument is 'mention'
      return self.data.user.game or 'None' if userFindArgument is 'game'

      return ''
    )
      # replace "{server...}" to server data
    .replace(SERVRE_IDENTIFYER, (_) -> 
      content = _.slice(1, -1)
      return self.data.server.name if content is 'server'
      serverFindArgument = content.split('.')[1]

      self.data.server[serverFindArgument]
    )
      # replace "{channel...}" to channel data
    .replace(CHANNEL_IDENTIFYER, (_) -> 
      content = _.slice(1, -1)
      channelFindArgument = content.split('.')[1]
      return "<##{self.data.channel.id}>" if content is 'channel' or channelFindArgument is 'mention'

      return self.data.channel[channelFindArgument]
    )
    # mentions parseing
    .replace(MENTIONS, (_) -> 
      content = _.slice(1, -1)
      first = content[0]
      type = 'role' if first is '&'
      type = 'user' if first is '@'
      type = 'channel' if first is '#'
      self.data.mentionValidator type, content.slice(1)
    )
    # time data
    .replace(TIME_OR_DATE, (_) -> 
      content = _.slice(1, -1)
      return new Date().toTimeString().split(' ')[0] if content is 'time'
      return new Date().toLocaleTimeString() if content is 'time12'
      return new Date().toLocaleDateString() if content is 'date'
      return "#{new Date().toLocaleDateString()} #{new Date().toTimeString().split(' ')[0]}" if content is 'datetime'
      return "#{new Date().toLocaleDateString()} #{new Date().toLocaleTimeString()}" if content is 'datetime12'
    )
    # Disable server mentions
    .replace(NO_EVERYONE, ->
      self._allowEveryOne = false
      return ""
    )
    # server mentions
    .replace(SERVER_MENTIONS, (_) -> if self._allowEveryOne then "@#{_.slice(1, -1)}" else '')

  __checkData: (data) ->
    has = Object.prototype.hasOwnProperty

    throw new TypeError('"Data" not valid type. expected object') if typeof data isnt 'object'
    throw new TypeError('"mentionValidator" not valid type. expected function') if data.mentionValidator and typeof data.mentionValidator isnt 'function'
    throw new TypeError('"mentionValidator" not valid return type. expected string') if data.mentionValidator && typeof data.mentionValidator('channel', 'general') isnt 'string'

    throw new TypeError('"args" not valid type. expected string Array') if not data.args or not (Array.isArray(data.args) and data.args.every((k) -> typeof k is 'string'))
    throw new TypeError('"server" not valid type. expected object') if typeof data.server isnt 'object'
    throw new TypeError('"user" not valid type. expected object') if typeof data.server isnt 'object'
    throw new TypeError('"channel" not valid type. expected object') if typeof data.server isnt 'object'

    (throw new TypeError("\"server.#{prop}\" not valid type.") if !has.call(data.server, prop)) for prop in ['id', 'name', 'icon', 'memberCount', 'ownerId', 'region']
    (throw new TypeError("\"user.#{prop}\" not valid type.") if !has.call(data.user, prop)) for prop in ['id', 'discriminator', 'username', 'nick', 'nick', 'avatar', 'createdAt', 'joinedAt']
    (throw new TypeError("\"channel.#{prop}\" not valid type.") if !has.call(data.channel, prop)) for prop in ['id', 'name']
    

module.exports = Compiler
