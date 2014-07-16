# Setup
API_SERVER = "#{location.protocol}//#{location.hostname}:3000"

@App = Ember.Application.create()
App.ApplicationSerializer = DS.ActiveModelSerializer

Ember.SimpleAuth.Authenticators.Devise.reopen
  serverTokenEndpoint: "#{API_SERVER}/users/sign_in"

Ember.Application.initializer
  name: 'authentication',
  initialize: (container, application) ->
    Ember.SimpleAuth.setup container, application,
      authorizerFactory: 'ember-simple-auth-authorizer:devise'
      crossOriginWhitelist: [API_SERVER]

DS.RESTAdapter.reopen
  host: API_SERVER

require = (resource, fn) ->
  asArray = resource.toArray()
  if asArray.length
    fn(asArray)
  else
    0

# Models
App.Habit = DS.Model.extend
  title: DS.attr 'string'
  unit: DS.attr 'string'
  checkins: DS.hasMany 'checkin'
  newCheckinValue: 1
  value: Ember.computed 'checkins', ->
    @get('checkins')
      .reduce ((memo, c) ->
        memo += +c.get 'value' ), 0
  maxCheckin: Ember.computed 'checkins', ->
    require @get('checkins'), (checkins) ->
      _.max(checkins, (checkin) ->
        checkin.get('value')).get('value')
  minCheckin: Ember.computed 'checkins', ->
    require @get('checkins'), (checkins) ->
      _.min(checkins, (checkin) ->
        checkin.get('value')).get('value')
  lastCheckin: Ember.computed 'checkins', ->
    require @get('checkins'), (checkins) ->
      _.last(checkins).get('value')

App.Checkin = DS.Model.extend
  habit: DS.belongsTo 'habit'
  value: DS.attr 'number'

App.User = DS.Model.extend
  habits: DS.hasMany 'habits'
  email: DS.attr 'string'
  password: DS.attr 'string'

# Routes

App.ApplicationRoute = Ember.Route.extend Ember.SimpleAuth.ApplicationRouteMixin

App.Router.map ->
  @route 'login'
  @route 'signup'
  @resource 'habits'
  @resource 'habits.new', path: '/habits/new'
  @resource 'habit', path: '/habits/:habit_id'

App.LoginController = Ember.Controller.extend Ember.SimpleAuth.LoginControllerMixin,
  authenticatorFactory: 'ember-simple-auth-authenticator:devise'

App.SignupRoute = Ember.Route.extend
  model: -> {}
  actions:
    signUp: ->
      user = @store.createRecord 'user',
        email: @currentModel.identification
        password: @currentModel.password
      user.save().then (success) =>
        @get('session')
          .authenticate "ember-simple-auth-authenticator:devise",
            identification: @currentModel.identification
            password: @currentModel.password

_checkin = (value) ->
  (habit) ->
    checkin = @store.createRecord 'checkin',
      value: value
      habit: habit
    habit.notifyPropertyChange 'checkins'
    checkin.save()

App.HabitsRoute = Ember.Route.extend Ember.SimpleAuth.AuthenticatedRouteMixin,
  afterModel: (habits) ->
    if habits.content.length is 0
      @transitionTo 'habits.new'
  model: -> @store.find 'habit'
  actions:
    plusOne: _checkin(1)
    minusOne: _checkin(-1)

App.HabitsNewRoute = Ember.Route.extend Ember.SimpleAuth.AuthenticatedRouteMixin,
  model: -> @store.createRecord 'habit'
  actions:
    save: ->
      @modelFor('habits.new').save().then =>
        @transitionTo 'habits'

App.HabitRoute = Ember.Route.extend Ember.SimpleAuth.AuthenticatedRouteMixin,
  model: (params) ->
    @store.find 'habit', params.habit_id
  actions:
    removeHabit: ->
      @modelFor('habit').destroyRecord().then =>
        @transitionTo 'habits'
    checkin: (habit, direction) ->
      value = if direction is 'plus' then habit.newCheckinValue else -habit.newCheckinValue
      _checkin.call(this, value).call(this, habit)

App.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'habits'
