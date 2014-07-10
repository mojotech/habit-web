HabitsApp.module 'Views', (Views, App, Backbone, Marionette, $, _) ->
  Views.LoginView = Marionette.ItemView.extend
    template: "#login"
    ui:
      email: "#email"
      password: "#password"
      loginButton: "#login-btn"
    events:
      "click @ui.loginButton": "login"
    login: ->
      HabitsApp.Util.authenticateUser(@ui.email.val(), @ui.password.val())
