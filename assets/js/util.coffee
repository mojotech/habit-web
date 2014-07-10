HabitsApp.module 'Util', (Util, App, Backbone, Marionette, $, _) ->
  @authHeader = ->
    "Token token=\"#{App.authToken}\", user_email=\"#{App.userEmail}\""

  @authenticateUser = (email, password) ->
    $.ajax
      url: 'http://localhost:3000/users/sign_in'
      method: 'POST'
      data:
        user: 
          email: email
          password: password
      success: (data) ->
        App.authToken = data.user_token
        App.userEmail = data.user_email
        App.router.navigate("habits", trigger: true)

  @fetchHabits = (callback) ->
    HabitsApp.habits.fetch
      beforeSend: (xhr) ->
        xhr.setRequestHeader('Authorization', "Token token=\"#{App.authToken}\", user_email=\"#{App.userEmail}\"")
      success: (data) ->
        callback(data)
