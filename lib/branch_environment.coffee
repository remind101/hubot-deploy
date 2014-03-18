module.exports = (robot) ->
  brain = robot.brain

  # Public: A class for determining what branch should be deployed
  # for the given environment.
  class BranchEnvironment
    constructor: (@repo, @environment) ->
      @key   = "branch:#{@repo.nwo}:#{@environment}"

    # Public: Get the branch that should be deployed for the environment.
    #
    # Returns String.
    get: ->
      brain.get(@key) || @default()

    # Public: Set the branch that should be deployed for the environment.
    #
    # branch - String branch name.
    #
    # Returns nothing.
    set: (branch) ->
      brain.set(@key, branch)

    # Internal: The default branch mapping.
    # 
    # Returns String.
    default: ->
      switch @environment
        when 'staging' then 'develop'
        else 'master'

