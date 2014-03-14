module.exports = (robot) ->
  Deploy = require('./deploy')(robot)

  robot.respond /deploy (\S+?) to (\S+?)(!)?/, (msg) ->
    repo        = msg.match[1]
    environment = msg.match[2]
    force       = msg.match[3]
    
    deploy = new Deploy(repo).deploy (err, res, body) ->
      msg.reply "Deploying #{deploy.name} to #{deploy.environment}: #{Deploy.base}/deploys/#{body.id}"
