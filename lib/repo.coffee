module.exports = (robot) ->
  BranchEnvironment = require('./branch_environment')(robot)

  class Repo
    @defaultOrganization: process.env.GITHUB_ORG

    constructor: (@name) ->
      @nwo = "#{@constructor.defaultOrganization}/#{@name}"
      @nwo = @name if @name.indexOf('/') > -1
      @git = "git@github.com:#{@nwo}.git"

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
