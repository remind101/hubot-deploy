module.exports =
  class Repo
    @organization: process.env.SHIPR_GITHUB_ORG

    constructor: (@name) ->
      @nwo = "#{@constructor.organization}/#{@name}"
      @git = "git@github.com:#{@nwo}.git"
