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
#   hubot deploy <app> to <environment> and lock <feature> - Deploy <app> to the <environment> and lock this environment
#
# Author:
#   ejholmes

module.exports = (robot) ->
  Deploy = require('../lib/deploy')(robot)
  Repo   = require('../lib/repo')(robot)

  deploy = (msg, name, options = {}) ->
    d = new Deploy(name, options)
    if d.deployable
      d.deploy (err, res, body) ->
        if options.lock
          msg.reply "Deploying and locking #{d.name} to #{d.environment}: #{Deploy.base}/deploys/#{body.id}"
        else
          msg.reply "Deploying #{d.name} to #{d.environment}: #{Deploy.base}/deploys/#{body.id}"
    else
      msg.reply "Blablabla still in use"

  robot.respond /deploy (\S+?)(!)?$/, (msg) ->
    name  = msg.match[1]
    force = msg.match[2]

    deploy msg, name, force: force

  robot.respond /deploy (\S+?) to (\S+?)(!)?$/, (msg) ->
    name        = msg.match[1]
    environment = msg.match[2]
    force       = msg.match[3]

    deploy msg, name, environment: environment, force: force

  robot.respond /deploy (\S+?) to (\S+?)(!)? and lock (\S+?)/, (msg) ->
    name        = msg.match[1]
    environment = msg.match[2]
    force       = msg.match[3]
    feature     = msg.match[4]

    deploy msg, name, environment: environment, force: force, lock: true, feature: feature, sender: "#{msg.message.user.name}"

  robot.respond /unlock (\S+?) on (\S+?)/, (msg) ->
    name        = msg.match[1]
    environment = msg.match[2]
    repo        = new Repo(name)

    repo.unlock(environment)
    msg.reply "Ok, #{name} on #{environment} is unlocked. Ship it!"


  robot.respond /(\S+?) is the default (\S+?) branch for (\S+)/, (msg) ->
    branch      = msg.match[1]
    environment = msg.match[2]
    name        = msg.match[3]
    repo        = new Repo(name)

    repo.setBranch environment, branch

    msg.reply "Ok, the default branch for #{name} when deployed to #{environment} is #{branch}"
