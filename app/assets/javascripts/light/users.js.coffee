# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

custom_function = ->
  template = Mustache.compile($.trim($("#template").html()))
  view_light = (record, index) ->
    
    if record.is_subscribed is true
      record.str = "success"
    else
      record.str = "warning"
    template
      record: record
      index: index

  if($("#stream_table_light").length)
    console.log data
    opts = {
      view: view_light
      data_url: '/newsletter/users.json'
      stream_after: 1
      fetch_data_limit: 500
      auto_sorting: true
    }
    $("#stream_table_light").stream_table(opts, data)

    $(".st_search").css("height",27)
    $(".st_search").css("margin-right",10)

$(document).ready(custom_function)
$(document).on 'page:load', custom_function

