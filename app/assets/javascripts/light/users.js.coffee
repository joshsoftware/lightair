# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
  
window.initialize_filterjs_table = (div, data, template, data_url, search_fields, pagination_container = '#pagination', per_page_container = '#per_page', pagination_values = [ 10, 20, 25 ]) ->
  batch_size = 500

  mustache_template = $(template).html();
  view = (data) ->
    Mustache.to_html(mustache_template, data)

  fjs = FilterJS(data, div,
    template: template
    view: view
    criterias: [{
      field: 'sidekiq_status', 
      ele: '#user_status', 
      event: 'change', 
      selector: 'select'}],
    search:
      ele: '#searchbox'
      fields: ['username', 'email_id']
      start_length: 1
    pagination:
      container: pagination_container
      visiblePages: 5
      perPage:
        values: pagination_values
        container: per_page_container)
  fjs.setStreaming
    data_url: '/newsletter/users.json'
    stream_after: 1
    batch_size: batch_size
  fjs.addCallback 'beforeAddRecords', ->
    if (@recordsCount + batch_size)  >= total_count
      @stopStreaming()
    return
