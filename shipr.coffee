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

      @branch      = 'master'
      @environment = @options.environment || 'production'
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

  robot.respond /deploy (\S+?) to (\S+?)(!)?/, (msg) ->
    repo        = msg.match[1]
    environment = msg.match[2]
    force       = msg.match[3]
    
    deploy = new Deploy(repo).deploy (err, res, body) ->
      msg.reply "Deploying #{deploy.name} to #{deploy.environment}: #{Deploy.base}/deploys/#{body.id}"

  robot.respond /deploy (\S+) to (\S+)/, (msg) ->
