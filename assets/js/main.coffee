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

habitsApp.service "AuthService", (Auth) ->
  @userAuthenticated = ->
    Auth.isAuthenticated()

  @signoutUser = ->
    Auth.logout().then (oldUser) ->
      window.location = "#/login"
    return
      
  @authenticateUser = (credentials) ->
    Auth.login(credentials).then (user) ->
      window.location = "#/habits"
      return
    return

  @registerUser = (credentials) =>
    Auth.register(credentials).then (registeredUser) =>
      window.location = "#/habits"
      @authenticateUser({ email: credentials.email, password: credentials.password })

  @authHeader = ->
    if Auth.isAuthenticated()
      user = Auth._currentUser
      "Token token=\"" + user.user_token + "\", user_email=\"" + user.user_email + "\""
    else
      ""
      
  return  


### Controllers ###

habitsApp.controller "HabitsController", [
  "$scope"
  "$http"
  "$routeParams"
  "AuthService"
  ($scope, $http, $routeParams, AuthService) ->
    fetchHabits = ->
      $http(
        url: 'http://localhost:3000/habits',
        method: 'GET',
        headers: { Authorization: AuthService.authHeader() }
      ).success (data) ->
        $scope.habits = data.habits
        $scope.habit = getHabit(parseInt($routeParams.id)) if $routeParams.id
        $scope.value = (habitId) ->
          _(data.checkins).filter((checkin) ->
            _.contains getHabit(habitId).checkin_ids, checkin.id
          ).map((checkin) ->
            checkin.value
          ).reduce((prev, curr, index, array) ->
            prev + curr
          ) or 0

    fetchHabits()

    getHabit = (habitId) ->
      _.find $scope.habits, { id: habitId }

    $scope.checkin = (habitId, value) ->
      $http(
        url: "http://localhost:3000/checkins"
        method: "POST"
        data: { habit_id: habitId, value: value }
        headers: { Authorization: AuthService.authHeader() }
      ).success (data) ->
        fetchHabits()

    $scope.createHabit = (title) ->
      $http(
        url: "http://localhost:3000/habits"
        method: "POST"
        data: { title: title }
        headers: { Authorization: AuthService.authHeader() }
      ).success (data) ->
        window.location = "#/habits"

    $scope.deleteHabit = (habitId) ->
      $http(
        url: "http://localhost:3000/habits/" + habitId
        method: "DELETE"
        headers:
          Authorization: AuthService.authHeader()
      ).success (data) ->
        window.location = "#/habits"

    $scope.userAuthenticated = ->
      AuthService.userAuthenticated()

    $scope.signoutUser = ->
      AuthService.signoutUser()

    return
]

habitsApp.controller "loginController", [
  "$scope"
  "AuthService"
  ($scope, AuthService) ->
    $scope.loginCredentials = { email: '', password: '' }

    $scope.authenticateUser = ->
      AuthService.authenticateUser $scope.loginCredentials

    return
]

habitsApp.controller "signupController", [
  "$scope"
  "AuthService"
  ($scope, AuthService) ->
    $scope.userInfo = { email: '', password: '' }

    $scope.signupUser = ->
      credentials =
        email: $scope.userInfo.email
        password: $scope.userInfo.password
        password_confirmation: $scope.userInfo.password
      AuthService.registerUser credentials

    return
]
