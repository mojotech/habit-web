HabitsApp.module 'Views', (Views, App, Backbone, Marionette, $, _) ->
  Views.SignupView = Marionette.ItemView.extend
    template: "#signup"
    ui:
      email: "#email"
      password: "#password"
      signupButton: "#signup-btn"
    events:
      "click @ui.signupButton": "signup"
    signup: ->
      $.ajax
        url: 'http://localhost:3000/users'
        method: 'POST'
        data:
          user:
            email: @ui.email.val()
            password: @ui.password.val()
            password_confirmation: @ui.password.val()
        success: (data) =>
          HabitsApp.Util.authenticateUser(@ui.email.val(), @ui.password.val())
