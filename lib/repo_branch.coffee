Repo = require './repo'

module.exports =
  # Public: A value object for splitting a repo#branch combination.
  #
  # Examples
  #
  #   repoBranch = RepoBranch.parse('r101-api#master')
  #
  #   repoBranch.name
  #   # => r101-api
  #   
  #   repoBranch.branch
  #   # => master
  #
  #   repoBranch.repo
  #   # => Repo
  class RepoBranch

    # Public: Delimiter that separates the repo from the branch.
    @delimiter: '#'

    # Public: Takes a string in the format:
    #
    # Returns a RepoBranch instance.
    @parse: (string) ->
      components = string.split(@delimiter)

      new RepoBranch(components[0], components[1])

    constructor: (@name, @branch) ->
      @repo = new Repo(@name)
