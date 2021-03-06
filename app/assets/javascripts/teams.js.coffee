# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.

$ ->
  $("#ldap_users_search").autocomplete
    source: "/ldap_users",
    minLength: 4,
    select: ( event, ui ) ->
      if ui.item
        template = document.getElementById('user_template').innerHTML.
          replace(/%%name%%/g, ui.item.label).
          replace('%%username%%', ui.item.value)
        document.getElementById('users').innerHTML += template
        @value = ""
        false

  $('.list').on "click", "i.icon-remove", (event) ->
    event.preventDefault()
    $(this).parents('.inner_item').remove()
