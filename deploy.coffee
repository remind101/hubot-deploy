module.exports = (robot) ->

  # Public: Service object for running a deploy.
  #
  # Examples
  #
  #   new Deploy('r101-api').deploy()
  #   new Deploy('r101-api', force: true).deploy()
  #
  class Deploy
    @base: process.env.SHIPR_BASE
    @endpoint: "#{@base}/api/deploys"
    @organization: process.env.SHIPR_GITHUB_ORG
    @delimiter: '#'

    constructor: (repo, @options = {}) ->
      components = repo.split(@constructor.delimiter)

      @name   = components[0]
      @branch = components[1]

      @environment = @options.environment || 'production'
      @branch      = if @environment == 'staging' then 'develop' else 'master'
      @force       = false
      @nwo         = "#{@constructor.organization}/#{@name}"
      @repo        = "git@github.com:#{@nwo}.git"

      @config = ENVIRONMENT: @environment
      @config.FORCE = '1' if @force

    # Public: Tell shipr to deploy the repo.
    #
    # cb - A callback function that will be called on success or failure.
    #
    # Returns nothing.
    deploy: (cb) ->
      data = JSON.stringify
        repo: @repo
        branch: @branch
        config: @config

      @_http(@constructor.endpoint)
        .post(data) (err, res, body) ->
          cb err, res, JSON.parse(body)

      this

    # Internal: Make an http request.
    #
    # Returns a scoped http client.
    _http: ->
      robot.http.apply(robot.http, arguments)
        .header('Accept', 'application/json')
        .header('Content-Type', 'application/json')
