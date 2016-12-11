path = require 'path'
fs = require 'fs'
koa = require 'koa'
bodyParser = require 'koa-bodyparser'
Router = require 'koa-router'
notifier = require 'node-notifier'

exec = (require 'child-process-promise').exec

voiceDir = '/tmp/say-server'

settingsFilename = path.join __dirname, 'settings.json'

saveSettings = ->
  fs.writeFileSync settingsFilename, JSON.stringify settings, 2, 2

loadSettings = ->
  try
    JSON.parse fs.readFileSync settingsFilename, 'utf8'
  catch
    replaces: []

try
  fs.mkdirSync voiceDir
settings = do loadSettings


defaultVoiceType = 'normal'
voiceTypes =
  ossan: '/usr/share/hts-voice/nitech-jp-atr503-m001/nitech_jp_atr503_m001.htsvoice'
  normal: path.join __dirname, 'voices/mei_normal.htsvoice'
  happy: path.join __dirname, 'voices/mei_happy.htsvoice'
  sad: path.join __dirname, 'voices/mei_sad.htsvoice'
  bashful: path.join __dirname, 'voices/mei_bashful.htsvoice'
  angry: path.join __dirname, 'voices/mei_angry.htsvoice'


cursor = 0

current = new Promise (r)-> do r

commands = [
  reg:  /^(add|teach|調教)$/i
  sub: (message, matched, chunked)->
    if not chunked[1] and not chunked[2]
      return 'よく分からない'

    reg = chunked[1].toLowerCase()
    for i, rule of settings.replaces
      if rule.reg is reg
        return 'もう知ってる'

    settings.replaces.push
      reg: reg
      replacer: chunked[2]

    do saveSettings
    "#{chunked[2]}の読み方を教えてもらいました"
,
  reg:  /^(remove|forget|忘却)$/i
  sub: (message, matched, chunked)->
    reg = chunked[1].toLowerCase()
    for i, rule of settings.replaces
      if rule.reg is reg
        settings.replaces.splice i, 1
        do saveSettings
        return "#{chunked[1]}の読み方を忘れました"

    "#{chunked[1]}の読み方をそもそもしらない"
]



parseMessage = (message)->
  chunked = message.split ' '
  for cmd in commands
    matched = chunked[0].match cmd.reg
    if matched
      message = cmd.sub message, matched, chunked
      break
  message

say = (rawMessage, title)->
  ->
    cursor = cursor + 1

    message = parseMessage rawMessage
    replaces = settings.replaces.concat([])
    replaces.reverse()
    for i in replaces
      reg = new RegExp i.reg, 'ig'
      message =  message.replace reg, i.replacer

    voiceFile = voiceTypes[defaultVoiceType]
    wavFilename = path.join voiceDir, cursor + '.wav'
    cmd = [
      "echo \"#{message}\" | open_jtalk \\"
      "-m #{voiceFile} \\"
      '-x naist-jdic \\'
      "-ow #{wavFilename} && \\"
      "play -q #{wavFilename}"
    ].join ''

    # notify
    notifier.notify
      title: title
      message: rawMessage

    exec cmd
    .then ->
      fs.unlink wavFilename
    , (e)->
      console.warn e

port = 4001

app = koa()
app.use bodyParser()
router = new Router
router.post '/say', (next)->
  @status = 200
  { comment, username, userId } = @request.body

  yield next
  p = say comment, username or userId or ' '
  current = current.then p, p

app.use router.routes()
app.listen port

console.info "start listening at #{port}"
