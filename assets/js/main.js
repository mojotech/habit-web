// Generated by CoffeeScript 1.7.1
(function() {
  var API_SERVER, require, _checkin;

  API_SERVER = "" + location.protocol + "//" + location.hostname + ":3000";

  this.App = Ember.Application.create();

  App.ApplicationSerializer = DS.ActiveModelSerializer;

  Ember.SimpleAuth.Authenticators.Devise.reopen({
    serverTokenEndpoint: "" + API_SERVER + "/users/sign_in"
  });

  Ember.Application.initializer({
    name: 'authentication',
    initialize: function(container, application) {
      return Ember.SimpleAuth.setup(container, application, {
        authorizerFactory: 'ember-simple-auth-authorizer:devise',
        crossOriginWhitelist: [API_SERVER]
      });
    }
  });

  DS.RESTAdapter.reopen({
    host: API_SERVER
  });

  require = function(resource, fn) {
    var asArray;
    asArray = resource.toArray();
    if (asArray.length) {
      return fn(asArray);
    } else {
      return 0;
    }
  };

  App.Habit = DS.Model.extend({
    title: DS.attr('string'),
    unit: DS.attr('string'),
    checkins: DS.hasMany('checkin'),
    newCheckinValue: 1,
    value: Ember.computed('checkins', function() {
      return this.get('checkins').reduce((function(memo, c) {
        return memo += +c.get('value');
      }), 0);
    }),
    maxCheckin: Ember.computed('checkins', function() {
      return require(this.get('checkins'), function(checkins) {
        return _.max(checkins, function(checkin) {
          return checkin.get('value');
        }).get('value');
      });
    }),
    minCheckin: Ember.computed('checkins', function() {
      return require(this.get('checkins'), function(checkins) {
        return _.min(checkins, function(checkin) {
          return checkin.get('value');
        }).get('value');
      });
    }),
    lastCheckin: Ember.computed('checkins', function() {
      return require(this.get('checkins'), function(checkins) {
        return _.last(checkins).get('value');
      });
    })
  });

  App.Checkin = DS.Model.extend({
    habit: DS.belongsTo('habit'),
    value: DS.attr('number')
  });

  App.User = DS.Model.extend({
    habits: DS.hasMany('habits'),
    email: DS.attr('string'),
    password: DS.attr('string')
  });

  App.ApplicationRoute = Ember.Route.extend(Ember.SimpleAuth.ApplicationRouteMixin);

  App.Router.map(function() {
    this.route('login');
    this.route('signup');
    this.resource('habits');
    this.resource('habits.new', {
      path: '/habits/new'
    });
    this.resource('habit', {
      path: '/habits/:habit_id'
    });
    return this.resource('habits.edit', {
      path: '/habits/:habit_id/edit'
    });
  });

  App.LoginController = Ember.Controller.extend(Ember.SimpleAuth.LoginControllerMixin, {
    authenticatorFactory: 'ember-simple-auth-authenticator:devise'
  });

  App.SignupRoute = Ember.Route.extend({
    model: function() {
      return {};
    },
    actions: {
      signUp: function() {
        var user;
        user = this.store.createRecord('user', {
          email: this.currentModel.identification,
          password: this.currentModel.password
        });
        return user.save().then((function(_this) {
          return function(success) {
            return _this.get('session').authenticate("ember-simple-auth-authenticator:devise", {
              identification: _this.currentModel.identification,
              password: _this.currentModel.password
            });
          };
        })(this));
      }
    }
  });

  _checkin = function(value) {
    return function(habit) {
      var checkin;
      checkin = this.store.createRecord('checkin', {
        value: value,
        habit: habit
      });
      habit.notifyPropertyChange('checkins');
      return checkin.save();
    };
  };

  App.HabitsRoute = Ember.Route.extend(Ember.SimpleAuth.AuthenticatedRouteMixin, {
    afterModel: function(habits) {
      if (habits.content.length === 0) {
        return this.transitionTo('habits.new');
      }
    },
    model: function() {
      return this.store.find('habit');
    },
    actions: {
      plusOne: _checkin(1),
      minusOne: _checkin(-1)
    }
  });

  App.HabitsNewRoute = Ember.Route.extend(Ember.SimpleAuth.AuthenticatedRouteMixin, {
    model: function() {
      return this.store.createRecord('habit');
    },
    actions: {
      save: function() {
        return this.modelFor('habits.new').save().then((function(_this) {
          return function() {
            return _this.transitionTo('habits');
          };
        })(this));
      }
    }
  });

  App.HabitsEditRoute = Ember.Route.extend(Ember.SimpleAuth.AuthenticatedRouteMixin, {
    model: function(params) {
      return this.store.find('habit', params.habit_id);
    },
    actions: {
      save: function() {
        return this.currentModel.save().then((function(_this) {
          return function() {
            return _this.transitionTo('habits');
          };
        })(this));
      }
    }
  });

  App.HabitRoute = Ember.Route.extend(Ember.SimpleAuth.AuthenticatedRouteMixin, {
    model: function(params) {
      return this.store.find('habit', params.hab);
    },
    actions: {
      removeHabit: function() {
        return this.modelFor('habit').destroyRecord().then((function(_this) {
          return function() {
            return _this.transitionTo('habits');
          };
        })(this));
      },
      editHabit: function() {
        return this.transitionTo('habits.edit', this.currentModel);
      },
      checkin: function(habit, direction) {
        var value;
        value = direction === 'plus' ? habit.newCheckinValue : -habit.newCheckinValue;
        return _checkin.call(this, value).call(this, habit);
      }
    }
  });

  App.IndexRoute = Ember.Route.extend({
    redirect: function() {
      return this.transitionTo('habits');
    }
  });

}).call(this);