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
    # The base url where shipr is running.
    @base: process.env.SHIPR_BASE

    # Basic authentication credentials for shipr.
    @auth: process.env.SHIPR_AUTH

    # The deployment endpoint.
    @endpoint: "#{@base}/api/deploys"

    constructor: (repo, @options = {}) ->
      repoBranch = RepoBranch.parse(repo)

      @user   = @options.user
      @name   = repoBranch.name
      @branch = repoBranch.branch
      @repo   = repoBranch.repo

      @environment = @options.environment || 'production'
      @force       = @options.force || false

      @branch or= @repo.branch @environment

    # Public: Tell shipr to deploy the repo.
    #
    # cb - A callback function that will be called on success or failure.
    #
    # Returns nothing.
    deploy: (cb) ->
      data =
        name: @repo.nwo
        ref: @branch
        payload:
          environment: @environment
          user: @user

      data.force = true if @force

      @_http(@constructor.endpoint)
        .post(JSON.stringify data) (err, res, body) ->
          cb err, res, JSON.parse(body)

      this

    # Internal: Make an http request.
    #
    # Returns a scoped http client.
    _http: ->
      auth = "Basic #{new Buffer(@constructor.auth).toString('base64')}"

      robot.http.apply(robot.http, arguments)
        .header('Accept', 'application/json')
        .header('Content-Type', 'application/json')
        .header('Authorization', auth)
