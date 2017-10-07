(($) ->

  $.fn.editable = (options) ->
    @defaults = new Array
    return this.each ->
      new Editable(this, options)

  $.fn.editable.defaults = {
    theme: 'BS4'
  }

  class Editable
    constructor: (el, options)->
      self = @
      @options = options
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
            field = new EditableTextField($el, options, self)
          when "textarea"
            field = new EditableTextArea($el, options, self)
          when "date"
            field = new EditableDateField($el, options, self)
          else console.log('There is no dataType registered for ' + type)
        field = field.render()
        field.focus()
        unless type == 'date'
          field.blur ->
            self.save(field.val())
            field.remove()
            $el.show()

    save: (val)->
      ajax_options = @options['ajaxOptions'] || {}
      ajax_options['url'] = @el.data('url')
      ajax_options['data'] = { pk: @el.data('pk'), name: @el.attr('id'), value: val }
      el = @el
      ajax_options['success'] = ->
        el.text(val)
      $.ajax(ajax_options)

  class EditableField
    constructor: (el, options, editable) ->
      @el = el
      @options = options
      @editable = editable
    render: ->
      # need to be overriden

  class EditableTextField extends EditableField
    render: ->
      editable = @editable
      wrapper = $(editable.theme.text_field)
      @el.after(wrapper)
      @el.hide()
      input = wrapper.find('input')
      return input

  class EditableTextArea extends EditableField
    render: ->
      editable = @editable
      wrapper = $(editable.theme.text_area)
      @el.after(wrapper)
      @el.hide()
      input = wrapper.find('input')
      return input

  class EditableDateField extends EditableField
    render: ->
      editable = @editable
      wrapper = $(editable.theme.date_field)
      @el.after(wrapper)
      @el.hide()
      input = wrapper.find('input')
      @options['autoclose'] = true
      $(input).datepicker(@options).on 'hide', (e) ->
        editable.save(input.val())
        editable.el.show()
        input.remove()
      return input

  class BS4Theme
    @text_field = '<div class="form-group"><input type="text" class"form-control" /></div>'
    @date_field = @text_field
    @text_area = '<div class="form-group"><textarea class="form-control"></textarea></div>'

) jQuery
