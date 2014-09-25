process.env.NODE_ENV = 'test'
process.env.GITHUB_ORG = 'remind101'
process.env.GITHUB_TOKEN = '1234'

{expect} = require 'chai'
init     = require '../scripts/deploy'
nock     = require 'nock'

{Robot,TextMessage} = require('hubot')

api = nock('https://api.github.com').log(console.log)

TESTS =
  'deploy app to production':
    request:
      body:
        ref: 'master'
        environment: 'production'
        auto_merge: false
        required_contexts: null
        payload:
          user: 'eric'
    response:
      status: 201
      body:
        id: ':id'

  'deploy app':
    request:
      body:
        ref: 'master'
        environment: 'production'
        auto_merge: false
        required_contexts: null
        payload:
          user: 'eric'
    response:
      status: 201
      body:
        id: ':id'

  'deploy app':
    request:
      body:
        ref: 'master'
        environment: 'production'
        auto_merge: false
        required_contexts: null
        payload:
          user: 'eric'
    response:
      status: 422
      body:
        message: 'No ref found for develop'
    reply: "No ref found for develop"

  'deploy app to staging':
    request:
      body:
        ref: 'develop'
        environment: 'staging'
        auto_merge: false
        required_contexts: null
        payload:
          user: 'eric'
    response:
      status: 201
      body:
        id: ':id'

  'deploy app#topic to staging':
    request:
      body:
        ref: 'topic'
        environment: 'staging'
        auto_merge: false
        required_contexts: null
        payload:
          user: 'eric'
    response:
      status: 201
      body:
        id: ':id'

  'deploy app!':
    request:
      body:
        ref: 'master'
        environment: 'production'
        auto_merge: false
        required_contexts: []
        payload:
          user: 'eric'
    response:
      status: 201
      body:
        id: ':id'

  'deploy app to staging!':
    request:
      body:
        ref: 'develop'
        environment: 'staging'
        auto_merge: false
        required_contexts: []
        payload:
          user: 'eric'
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
        ref: 'foo'
        environment: 'staging'
        auto_merge: false
        required_contexts: null
        payload:
          user: 'eric'
    response:
      status: 201
      body:
        id: ':id'

describe 'deploy', ->

  beforeEach (done) ->
    runRobot.call(this, done)

  afterEach ->
    nock.cleanAll()

  describe 'deployment commands', ->

    for command, test of TESTS
      do (command, test) =>
        describe '"' + command + '"', ->

          beforeEach test.beforeEach if test.beforeEach

          beforeEach ->
            api
              .post('/repos/remind101/app/deployments', test.request.body, 'Authorization': 'Bearer 1234')
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
