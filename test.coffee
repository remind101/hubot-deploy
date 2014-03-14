process.env.SHIPR_BASE = 'http://shipr.test'
process.env.SHIPR_GITHUB_ORG = 'remind101'

{expect} = require 'chai'
init     = require './shipr'
nock     = require 'nock'

{Robot,TextMessage} = require('hubot')

shipr = nock(process.env.SHIPR_BASE).log(console.log)

describe 'shipr', ->

  beforeEach (done) ->
    runRobot.call(this, done)

  afterEach ->
    nock.cleanAll()

  describe 'deploy <repo> to <environment>', ->

    beforeEach ->
      shipr
        .post('/api/deploys',
          repo: 'git@github.com:remind101/app.git',
          branch: 'master',
          config:
            ENVIRONMENT: 'production'
        )
        .reply(201, { id: ':id' }, { 'Content-Type': 'application/json' })

    it 'deploys the repo', (done) ->
      @adapter.on 'reply', (envelope, strings) ->
        expect(strings[0]).to.eq("Deploying app to production: #{process.env.SHIPR_BASE}/deploys/:id")
        done()

      @adapter.receive(new TextMessage(@user, 'hubot deploy app to production'))

# Run the robot.
#
# cb - Callback to call when done.
#
# Returns nothing
runRobot = (cb) ->
  robot = new Robot(null, 'mock-adapter', false, 'hubot')
  robot.adapter.on 'connected', =>
    @user = robot.brain.userForId('1', name: 'eric', room: 'Neckbeards')
    require('./shipr')(robot)
    @adapter = robot.adapter
    cb()
  robot.run()
