module.exports = (robot) ->
  BranchEnvironment = require('./branch_environment')(robot)
  brain = robot.brain

  class Repo
    @organization: process.env.SHIPR_GITHUB_ORG

    constructor: (@name) ->
      @nwo      = "#{@constructor.organization}/#{@name}"
      @git      = "git@github.com:#{@nwo}.git"

    # Public: Gets the branch that should be deployed for the environment.
    #
    # environment - String environment where the repo will be deployed to.
    #
    # Returns String.
    branch: (environment) ->
      new BranchEnvironment(this, environment).get()

    # Public: Set the branch that should be deployed for the environment.
    #
    # environment - A String environment where the repo will be deployed to.
    setBranch: (environment, branch) ->
      new BranchEnvironment(this, environment).set(branch)

    lock: (environment, data) ->
      brain.set("#{@nwo}:#{environment}", data)

    unlock: (environment) ->
      brain.remove("#{@nwo}:#{environment}")

    locked: (environment) ->
      brain.get("#{@nwo}:#{environment}")

    getAttempts: (environment) ->
      brain.get("#{@name}:#{environment}:attempts")

    increaseAttempts: (environment) ->
      brain.incrby("#{@nwo}:#{environment}:attempts", 1)
