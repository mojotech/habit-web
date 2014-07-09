### Main App ###

habitsApp = angular.module("habitsApp", 
  ["ngRoute", "Devise"]
).config (AuthProvider) ->
  AuthProvider.loginPath "http://localhost:3000/users/sign_in"
  AuthProvider.registerPath "http://localhost:3000/users"
  AuthProvider.logoutPath "http://localhost:3000/users/sign_out"


### Routes ###

loginRequired = ($location, $q, Auth) ->
  deferred = $q.defer()
  unless Auth.isAuthenticated()
    deferred.reject()
    $location.path "login"
  else
    deferred.resolve()
  deferred.promise

habitsApp.config ["$routeProvider", ($routeProvider) ->
  $routeProvider.when("/habits",
    templateUrl: "habits"
    controller: "HabitsController"
    resolve: { loginRequired: loginRequired }
  ).when("/habits/new",
    templateUrl: "habits/new"
    controller: "HabitsController"
    resolve: { loginRequired: loginRequired }
  ).when("/habit/:id",
    templateUrl: "habit"
    controller: "HabitsController"
    resolve: { loginRequired: loginRequired }
  ).when("/login",
    templateUrl: "login"
    controller: "loginController"
  ).when("/signup",
    templateUrl: "signup"
    controller: "signupController"
  ).otherwise({ redirectTo: '/habits' });
]


### Services ###

habitsApp.service "auth", (Auth, $location) ->
  @signoutUser = ->
    Auth.logout().then (oldUser) ->
      $location.path "login"
    return
      
  @authenticateUser = (credentials) ->
    Auth.login(credentials).then (user) ->
      $location.path "habits"
    return

  @registerUser = (credentials) =>
    Auth.register(credentials).then (registeredUser) =>
      @authenticateUser { email: credentials.email, password: credentials.password }

  @authHeader = ->
    if Auth.isAuthenticated()
      user = Auth._currentUser
      "Token token=\"#{user.user_token}\", user_email=\"#{user.user_email}\""
    else
      ""
      
  return  

habitsApp.service "api", ($location) ->
  protocol = $location.protocol()
  host = $location.host()
  (path) ->
    "#{protocol}://#{host}:3000/#{path}"

habitsApp.service "habitsService", ($http, auth, api, $location) ->
  @create = (title) ->
    $http(
      url: api('habits')
      method: "POST"
      data: { title: title }
      headers: { Authorization: auth.authHeader() }
    ).success (data) ->
      $location.path "habits"

  @destroy = (id) ->
    $http(
      url: api("habits/#{id}")
      method: "DELETE"
      headers: { Authorization: auth.authHeader() }
    ).success (data) ->
      $location.path "habits"

  @checkin = (id, value, callback) ->
    $http(
      url: api("checkins")
      method: "POST"
      data: { habit_id: id, value: value }
      headers: { Authorization: auth.authHeader() }
    ).success (data) ->
      callback data.habits

  @getHabits = (callback) =>
    $http(
      url: api("habits")
      method: 'GET'
      headers: { Authorization: auth.authHeader() }
    ).success (data) =>
      _.map(data.habits, (habit) =>
        @checkins(habit.id, (value) ->
          habit.checkins = value
        )
      )
      callback data.habits

  @getHabit = (id, callback) ->
    $http(
      url: api("habits/#{id}")
      method: "GET"
      headers: { Authorization: auth.authHeader() }
    ).success (data) ->
      callback data.habit

  @checkins = (id, callback) =>
    $http(
      url: api("habits")
      method: 'GET'
      headers: { Authorization: auth.authHeader() }
    ).success (data) =>
      @getHabit(id, (habit) ->
        callback(
          _(data.checkins).filter((checkin) =>
            _.contains habit.checkin_ids, checkin.id
          ).map((checkin) ->
            checkin.value
          ).reduce((prev, curr, index, array) ->
            prev + curr
          ) or 0
        )
      )
  return


### Controllers ###

habitsApp.controller "HabitsController", [
  "$scope"
  "$routeParams"
  "auth"
  "habitsService"
  ($scope, $routeParams, auth, habitsService) ->
    habitsService.getHabits (habits) ->
      $scope.habits = habits

    if $routeParams.id
      habitsService.getHabit(parseInt($routeParams.id), (habit) ->
        $scope.habit = habit
      )

    $scope.checkin = (habitId, value) ->
      habitsService.checkin(habitId, value, ->
        habitsService.getHabits (habits) ->
          $scope.habits = habits
      )

    $scope.createHabit = (title) ->
      habitsService.create title

    $scope.deleteHabit = (habitId) ->
      habitsService.destroy habitId

    $scope.signoutUser = ->
      auth.signoutUser()

    return
]

habitsApp.controller "loginController", [
  "$scope"
  "auth"
  ($scope, auth) ->
    $scope.loginCredentials = { email: '', password: '' }

    $scope.authenticateUser = ->
      auth.authenticateUser $scope.loginCredentials

    return
]

habitsApp.controller "signupController", [
  "$scope"
  "auth"
  ($scope, auth) ->
    $scope.userInfo = { email: '', password: '' }

    $scope.signupUser = ->
      credentials =
        email: $scope.userInfo.email
        password: $scope.userInfo.password
        password_confirmation: $scope.userInfo.password
      auth.registerUser credentials

    return
]
