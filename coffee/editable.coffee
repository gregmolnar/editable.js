(($) ->

  $.fn.editable = (options) ->
    @defaults = new Array
    return this.each ->
      new Editable(this, options)

  $.fn.editable.defaults = {
    theme: 'BS4',
    ajaxOptions: {}
  }

  class Editable
    constructor: (el, options = {})->
      self = @
      @options = options
      @options.ajaxOptions = $.fn.editable.defaults.ajaxOptions unless options.ajaxOptions
      $el = $(el)
      @el = $el
      $el.text('Empty') if $el.text() == ''

      switch $.fn.editable.defaults.theme
        when 'BS4' then @theme = BS4Theme
        else console.log('There is no theme registered for ' + $.fn.editable.defaults.theme)

      type = $el.data('type')

      $el.click (event) ->
        event.preventDefault()
        switch type
          when "text"
            field = new TextField($el, options, self)
          when "textarea"
            field = new TextArea($el, options, self)
          when "date"
            field = new DateField($el, options, self)
          when "chosen"
            field = new ChosenField($el, options, self)
          else console.log('There is no dataType registered for ' + type)
        field = field.render()
        field.focus()
        unless type == 'date' || type == 'chosen'
          field.blur ->
            self.save(field.val())
            field.remove()
            $el.show()

    save: (val)->
      ajax_options = @options['ajaxOptions'] || {}
      ajax_options['url'] = @el.data('url')
      ajax_options['data'] = { pk: @el.data('pk'), name: @el.attr('id'), value: val }
      el = @el
      editable = @
      ajax_options['success'] = ->
        el.text(val)
        console.log el.data('callback')
        window[el.data('callback')](editable) if el.data('callback')
      $.ajax(ajax_options)

  class EditableField
    constructor: (el, options, editable) ->
      @el = el
      @options = options
      @editable = editable
    render: ->
      # need to be overriden

  class TextField extends EditableField
    render: ->
      editable = @editable
      wrapper = $(editable.theme.text_field)
      @el.after(wrapper)
      @el.hide()
      input = wrapper.find('input')
      input.val(@editable.el.text())
      return input

  class TextArea extends EditableField
    render: ->
      editable = @editable
      wrapper = $(editable.theme.text_area)
      @el.after(wrapper)
      @el.hide()
      input = wrapper.find('input')
      input.val(@editable.el.text())
      return input

  class DateField extends EditableField
    render: ->
      editable = @editable
      wrapper = $(editable.theme.date_field)
      @el.after(wrapper)
      @el.hide()
      input = wrapper.find('input')
      input.val(@editable.el.text())
      @options['autoclose'] = true
      $(input).datepicker(@options).on 'hide', (e) ->
        editable.save(input.val())
        editable.el.show()
        input.remove()
      return input

  class ChosenField extends EditableField
    render: ->
      editable = @editable
      wrapper = $(editable.theme.multi_select_field)
      @el.after(wrapper)
      @el.hide()
      input = wrapper.find('select')
      wrapper.find('a').click ->
        editable.save(input.val())
        input.chosen("destroy");
        wrapper.remove()
        editable.el.show()
      selected_options = @el.data('selected')
      $.each @el.data('source'), (value, text) ->
        input.append($('<option />', {value: value, text: text, selected: (selected_options.indexOf(parseInt(value)) != -1)}))
      input.chosen()

      return input

  class BS4Theme
    @text_field = '<div class="form-group"><input type="text" class"form-control" /></div>'
    @date_field = @text_field
    @text_area = '<div class="form-group"><textarea class="form-control"></textarea></div>'
    @multi_select_field = '<div class="form-group"><select class="form-control" multiple="true"></select><a href="javascript:void(0)" class="fa fa-check-square fa-2x"></a></div>'

) jQuery
