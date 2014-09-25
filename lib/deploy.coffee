module.exports = (robot) ->
  RepoBranch = require('./repo_branch')(robot)

  # Public: Service object for running a deploy.
  #
  # Examples
  #
  #   new Deploy('r101-api').deploy()
  #   new Deploy('r101-api', force: true).deploy()
  #
  class Deploy
    # The base url for the GitHub api.
    @base: 'https://api.github.com'

    # GitHub auth token. This token should have access to all repos
    # and should have the `deployment` scope.
    @token: process.env.GITHUB_TOKEN

    constructor: (repo, @options = {}) ->
      repoBranch = RepoBranch.parse(repo)

      @user   = @options.user
      @name   = repoBranch.name
      @branch = repoBranch.branch
      @repo   = repoBranch.repo

      @environment = @options.environment || 'production'
      @force       = !!(@options.force || false)

      @branch or= @repo.branch @environment

    # Public: Tell GitHub to deploy the repo.
    #
    # cb - A callback function that will be called on success or failure.
    #
    # Returns nothing.
    deploy: (cb) ->
      data =
        ref: @branch
        environment: @environment
        auto_merge: false
        required_contexts: if @force then [] else null
        payload:
          user: @user

      @_http("#{@constructor.base}/repos/#{@repo.nwo}/deployments")
        .post(JSON.stringify data) (err, res, body) ->
          cb err, res, JSON.parse(body)

      this

    # Internal: Make an http request.
    #
    # Returns a scoped http client.
    _http: ->
      auth = "Bearer #{@constructor.token}"

      robot.http.apply(robot.http, arguments)
        .header('Accept', 'application/vnd.github.cannonball-preview+json')
        .header('Content-Type', 'application/json')
        .header('Authorization', auth)
