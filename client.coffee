request = require 'request'

# サーバーに合わせて設定してください
host = 'http://localhost:4001'

raw = process.argv[2]
if not raw
    process.exit 0

message = encodeURIComponent raw
request.post "#{host}/#{message}"
