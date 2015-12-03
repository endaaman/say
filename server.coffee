path = require 'path'
fs = require 'fs'
koa = require 'koa'
Router = require 'koa-router'

exec = (require 'child-process-promise').exec

settingsFilename = path.join __dirname, 'settings.json'

saveSettings = ->
    fs.writeFileSync settingsFilename, JSON.stringify settings, 2, 2

loadSettings = ->
    try
        JSON.parse fs.readFileSync settingsFilename, 'utf8'
    catch
        replaces: []

try
    fs.mkdirSync '/tmp/voices'
settings = do loadSettings


defaultVoiceType = 'normal'
voiceTypes =
    ossan: '/usr/share/hts-voice/nitech-jp-atr503-m001/nitech_jp_atr503_m001.htsvoice'
    normal: '~/voices/mei_normal.htsvoice'
    happy: '~/voices/mei_happy.htsvoice'
    sad: '~/voices/mei_sad.htsvoice'
    bashful: '~/voices/mei_bashful.htsvoice'
    angry: '~/voices/mei_angry.htsvoice'



cursor = 0
voiceDir = '/tmp/say-server'

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

say = (message)->
    ->
        cursor = cursor + 1

        message = parseMessage message

        for i in settings.replaces
            reg = new RegExp i.reg, 'ig'
            message =  message.replace reg, i.replacer

        voiceFile = voiceTypes[defaultVoiceType]
        wavFilename = path.join voiceDir, cursor + '.wav'
        cmd = [
            "echo \"#{message}\" | open_jtalk \\"
            "-m #{voiceFile} \\"
            '-x /var/lib/mecab/dic/open-jtalk/naist-jdic \\'
            "-ow #{wavFilename} && \\"
            "aplay --quiet #{wavFilename}"
        ].join ''

        exec cmd
        .then ->
            fs.unlink wavFilename


app = koa()
router = new Router

router.post '/:message', (next)->
    @status = 200
    console.log @params.message

    yield next

    current = current.then say @params.message

app.use router.routes()
app.listen 4001

console.info 'start listening at 4001'
