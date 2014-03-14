process.env.SHIPR_BASE = 'http://shipr.test'
process.env.SHIPR_GITHUB_ORG = 'remind101'

{expect} = require 'chai'
init     = require './shipr'
nock     = require 'nock'

{Robot,TextMessage} = require('hubot')

shipr = nock(process.env.SHIPR_BASE).log(console.log)

TESTS =
  'deploy app to production':
    request:
      body:
        repo: 'git@github.com:remind101/app.git'
        branch: 'master'
        config:
          ENVIRONMENT: 'production'
    response:
      status: 201
      body:
        id: ':id'
    reply: "Deploying app to production: #{process.env.SHIPR_BASE}/deploys/:id"

  'deploy app':
    request:
      body:
        repo: 'git@github.com:remind101/app.git'
        branch: 'master'
        config:
          ENVIRONMENT: 'production'
    response:
      status: 201
      body:
        id: ':id'
    reply: "Deploying app to production: #{process.env.SHIPR_BASE}/deploys/:id"

  'deploy app to staging':
    request:
      body:
        repo: 'git@github.com:remind101/app.git'
        branch: 'develop'
        config:
          ENVIRONMENT: 'staging'
    response:
      status: 201
      body:
        id: ':id'
    reply: "Deploying app to staging: #{process.env.SHIPR_BASE}/deploys/:id"

  'deploy app#topic to staging':
    request:
      body:
        repo: 'git@github.com:remind101/app.git'
        branch: 'topic'
        config:
          ENVIRONMENT: 'staging'
    response:
      status: 201
      body:
        id: ':id'
    reply: "Deploying app to staging: #{process.env.SHIPR_BASE}/deploys/:id"

describe 'shipr', ->

  beforeEach (done) ->
    runRobot.call(this, done)

  afterEach ->
    nock.cleanAll()

  for command, test of TESTS
    do (command, test) =>
      describe command, ->

        beforeEach ->
          shipr
            .post('/api/deploys', test.request.body)
            .reply(test.response.status, test.response.body, { 'Content-Type': 'application/json' })

        it 'responds appropriately', (done) ->
          @adapter.on 'reply', (envelope, strings) ->
            expect(strings[0]).to.eq(test.reply)
            done()
          @adapter.receive(new TextMessage(@user, "hubot #{command}"))

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
