# Description:
#   Deploy apps with Hubot and Shipr.
#
# Configuration:
#   SHIPR_BASE
#   SHIPR_GITHUB_ORG
#
# Commands:
#   hubot deploy <app> - Fuck it! We'll do it live!
#   hubot deploy <app> to <environment> - Deploy <app> to the <environment>
#   hubot deploy <app>! - Force deploy <app>
#   hubot deploy <app> to <environment>! - Force deploy <app> to the <environment>
#   hubot <branch> is the default <environment> branch for <app> - Set the branch that will be deployed when the <environment> is provided
#
# Author:
#   ejholmes

module.exports = (robot) ->
  Deploy = require('../lib/deploy')(robot)
  Repo   = require('../lib/repo')(robot)

  deploy = (msg, name, options = {}) ->
    d = new Deploy(name, options).deploy (err, res, body) ->
      msg.reply "Deploying #{d.name} to #{d.environment}: #{Deploy.base}/deploys/#{body.id}"

  robot.respond /deploy (\S+?)(!)?$/, (msg) ->
    name  = msg.match[1]
    force = msg.match[2]

    deploy msg, name, force: force

  robot.respond /deploy (\S+?) to (\S+?)(!)?$/, (msg) ->
    name        = msg.match[1]
    environment = msg.match[2]
    force       = msg.match[3]
    
    deploy msg, name, environment: environment, force: force

  robot.respond /(\S+?) is the default (\S+?) branch for (\S+)/, (msg) ->
    branch      = msg.match[1]
    environment = msg.match[2]
    name        = msg.match[3]
    repo        = new Repo(name)

    repo.setBranch environment, branch

    msg.reply "Ok, the default branch for #{name} when deployed to #{environment} is #{branch}"
