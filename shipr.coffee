module.exports = (robot) ->
  Deploy = require('./deploy')(robot)

  perform = (msg, name, options = {}) ->
    deploy = new Deploy(name, options).deploy (err, res, body) ->
      msg.reply "Deploying #{deploy.name} to #{deploy.environment}: #{Deploy.base}/deploys/#{body.id}"

  robot.respond /deploy (\S+?)(!)?$/, (msg) ->
    name  = msg.match[1]
    force = msg.match[2]

    perform msg, name, force: force

  robot.respond /deploy (\S+?) to (\S+?)(!)?$/, (msg) ->
    name        = msg.match[1]
    environment = msg.match[2]
    force       = msg.match[3]
    
    perform msg, name, environment: environment, force: force
