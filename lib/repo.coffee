BranchEnvironment = require './branch_environment'

module.exports =
  class Repo
    @organization: process.env.SHIPR_GITHUB_ORG

    constructor: (@name) ->
      @nwo = "#{@constructor.organization}/#{@name}"
      @git = "git@github.com:#{@nwo}.git"

    # Public: Gets the branch that should be deployed for the environment.
    #
    # environment - String environment where the repo will be deployed to.
    # brain       - A Hubot brain.
    #
    # Returns String.
    branch: (environment, brain) ->
      new BranchEnvironment(this, environment, brain: brain).get()

    # Public: Set the branch that should be deployed for the environment.
    #
    # environment - A String environment where the repo will be deployed to.
    # brain       - A Hubot brain.
    setBranch: (environment, branch, brain) ->
      new BranchEnvironment(this, environment, brain: brain).set(branch)
