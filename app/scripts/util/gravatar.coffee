md5 = require('blueimp-md5').md5

gravatar = (email, size, fallback, forceDefault) ->
  "https://gravatar.com/avatar/#{md5(email)}?d=#{fallback}&s=#{size}&f=#{if forceDefault then 'y' else 'n'}"

gravatar.mm = (email, size = 80) -> gravatar email, size, 'mm', yes
gravatar.identicon = (email, size = 80) -> gravatar email, size, 'identicon', yes
gravatar.monsterid = (email, size = 80) -> gravatar email, size, 'monsterid', yes
gravatar.wavatar = (email, size = 80) -> gravatar email, size, 'wavatar', yes
gravatar.retro = (email, size = 80) -> gravatar email, size, 'retro', yes

module.exports = gravatar
