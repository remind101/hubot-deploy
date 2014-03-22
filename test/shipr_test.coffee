process.env.NODE_ENV = 'test'
process.env.SHIPR_BASE = 'http://shipr.test'
process.env.SHIPR_GITHUB_ORG = 'remind101'
process.env.SHIPR_AUTH = ':apikey'

{expect} = require 'chai'
init     = require '../scripts/shipr'
nock     = require 'nock'

{Robot,TextMessage} = require('hubot')

shipr = nock(process.env.SHIPR_BASE).log(console.log)

TESTS =
  'deploy app to production':
    request:
      body:
        name: 'remind101/app'
        ref: 'master'
        payload:
          environment: 'production'
          user: 'eric'
    response:
      status: 201
      body:
        id: ':id'

  'deploy app':
    request:
      body:
        name: 'remind101/app'
        ref: 'master'
        payload:
          environment: 'production'
          user: 'eric'
    response:
      status: 201
      body:
        id: ':id'

  'deploy app':
    request:
      body:
        name: 'remind101/app'
        ref: 'master'
        payload:
          environment: 'production'
          user: 'eric'
    response:
      status: 422
      body:
        message: 'No ref found for develop'
    reply: "No ref found for develop"

  'deploy app to staging':
    request:
      body:
        name: 'remind101/app'
        ref: 'develop'
        payload:
          environment: 'staging'
          user: 'eric'
    response:
      status: 201
      body:
        id: ':id'

  'deploy app#topic to staging':
    request:
      body:
        name: 'remind101/app'
        ref: 'topic'
        payload:
          environment: 'staging'
          user: 'eric'
    response:
      status: 201
      body:
        id: ':id'

  'deploy app!':
    request:
      body:
        name: 'remind101/app'
        ref: 'master'
        payload:
          environment: 'production'
          user: 'eric'
        force: true
    response:
      status: 201
      body:
        id: ':id'

  'deploy app to staging!':
    request:
      body:
        name: 'remind101/app'
        ref: 'develop'
        payload:
          environment: 'staging'
          user: 'eric'
        force: true
    response:
      status: 201
      body:
        id: ':id'

  'deploy app to staging':
    beforeEach: (done) ->
      @adapter.once 'reply', -> done()
      @adapter.receive(new TextMessage(@user, "hubot foo is the default staging branch for app"))
    request:
      body:
        name: 'remind101/app'
        ref: 'foo'
        payload:
          environment: 'staging'
          user: 'eric'
    response:
      status: 201
      body:
        id: ':id'

describe 'shipr', ->

  beforeEach (done) ->
    runRobot.call(this, done)

  afterEach ->
    nock.cleanAll()

  describe 'deployment commands', ->

    for command, test of TESTS
      do (command, test) =>
        describe command, ->

          beforeEach test.beforeEach if test.beforeEach

          beforeEach ->
            shipr
              .post('/api/deploys', test.request.body, 'Authorization': 'Basic OmFwaWtleQ==')
              .reply(test.response.status, test.response.body, { 'Content-Type': 'application/json' })

          it 'responds appropriately', (done) ->
            @adapter.on 'reply', (envelope, strings) ->
              expect(strings[0]).to.eq(test.reply) if test.reply?
              done()
            @adapter.receive(new TextMessage(@user, "hubot #{command}"))

  describe '<branch> is the <environment> branch for <name>', ->

    it 'sets the branch for the app', (done) ->
      @adapter.on 'reply', (envelope, strings) ->
        expect(strings[0]).to.eq('Ok, the default branch for r101-api when deployed to staging is foo')
        done()
      @adapter.receive(new TextMessage(@user, "hubot foo is the default staging branch for r101-api"))

# Run the robot.
#
# cb - Callback to call when done.
#
# Returns nothing
runRobot = (cb) ->
  robot = new Robot(null, 'mock-adapter', false, 'hubot')
  robot.adapter.on 'connected', =>
    @user = robot.brain.userForId('1', name: 'eric', room: 'Neckbeards')
    init(robot)
    @adapter = robot.adapter
    cb()
  robot.run()
