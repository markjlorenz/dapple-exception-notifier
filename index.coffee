module.exports = (emailOptions, sendgridOptions)->
  #emailOptions: {to:"to@example.com", from:"from@example.com", subject:"your subject"}
  #sendgridOptions: {username:"good for development", password:"$heroku config", onSendError:function(message){}}
  SendGrid = require('sendgrid').SendGrid
  sendgrid = new SendGrid process.env.SENDGRID_USERNAME || sendgridOptions["username"],  process.env.SENDGRID_PASSWORD || sendgridOptions["password"]

  objToString = (obj) ->
    str = ""
    for p of obj
      str += p + "::" + obj[p] + "\n"  if obj.hasOwnProperty(p)
    str

  errToHTML = (err)->
    stack = (err.stack || '')
    .split('\n').slice(1)
    .map (v)->
      '<li>' + v + '</li>'
    .join('')

  emailMe: (err, req, res, next)->
    sendgrid.send
      to: emailOptions["to"]
      from: emailOptions["from"]
      subject: emailOptions["subject"]
      html: "<h3>Error:</h3><pre>#{err}</pre><h3>Stack:</h3><pre>#{errToHTML err}</pre><h3>Request:</h3><pre>#{errToHTML {stack:objToString(req)}}</pre>"
    , (success, message)->
      if !success
        onSendError(message)
    next(err)
