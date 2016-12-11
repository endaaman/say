axios = require 'axios'

host = 'http://localhost:4001'

comment = process.argv[2]
if not comment
  process.exit 0

userId = process.argv[3] or null
username = process.argv[4] or null

data = {comment, username, userId}
axios.post "#{host}/say", data
