request = require 'request'

host = 'http://localhost:4001'

rawComment = process.argv[2]
if not rawComment
    process.exit 0

username = process.argv[3] or null

comment = encodeURIComponent rawComment
request.post "#{host}/#{comment}"
