module GoodEnoughFormBuilder  
  class Builder < ActionView::Helpers::FormBuilder
    @@templates_path = "forms/"
    cattr_accessor :templates_path
    
    def wrapper(locals)
      type = locals[:type]
      body = locals[:body]
      
      begin
        @template.render :partial => template_name(type), :locals => locals
      rescue ActionView::MissingTemplate
        if type == 'field'
          body
        else
          begin
            @template.render :partial => template_name('field'), :locals => locals
          rescue ActionView::MissingTemplate
            body
          end
        end        
      end
    end
    
    def field(*args, &block)
      options = args.extract_options!
      locals = template_locals(options)
      locals.merge!({
        :method => nil,
        :type => 'field',
        :body => @template.capture(&block)
      })
      wrapper(locals)
    end
    
    ['text_field', 'file_field', 'password_field', 'text_area', 
      'select', 'collection_select', 'submit'].each do |name|
      define_method(name) do |method, *args|
        options = args.extract_options!
        plain = options.delete(:plain)
        return super if plain
        
        locals = template_locals(options)
        locals[:error] ||= @object.errors.on(method) if @object
        locals[:label_text] ||= false if name == 'submit'
        locals.merge!({
          :method => method,
          :type => name,
          :body => super
        })
        wrapper(locals)
      end
    end
        
    def fieldset(*args, &block)
      options = args.extract_options!
      body = ''
      body += @template.content_tag(:legend, options[:legend]) unless options[:legend].blank?
      body += @template.capture(&block)
      @template.content_tag(:fieldset, body, :class => options[:class])
    end
    
    def radio_select(method, choices, *args)
      options = args.extract_options!
      value = @object.send(method)
      separator = options.delete(:separator)
      body = ''
      for text,key in choices
        body << radio_button(method, key.to_s, :selected => (value == key)) + ' '
        body << @template.content_tag("label" , text, :for => "#{object_name}_#{method}_#{key.to_s}")
        body << separator unless separator.blank?
      end
      
      locals = template_locals(options)
      locals[:error] ||= @object.errors.on(method) if @object
      locals[:label_for] ||= false
      locals.merge!({
        :method => method,
        :type => 'radio_select',
        :body => body
      })
      wrapper(locals)
    end
    
    private
    
    def template_name(name)
      return "#{templates_path}#{name}"
    end
    
    def template_locals(options)
      {
        :builder => self,
        :object => @object,
        :object_name => @object_name,
        :method => options.delete(:method),
        :type => options.delete(:type),
        :body => options.delete(:body),
        :error => options.delete(:error),
        :required => options.delete(:required),
        :klass => options.delete(:class),
        :label_text => options.delete(:label),
        :label_for => options.delete(:label_for),
        :note => options.delete(:note),
        :help => options.delete(:help),
        :options => options
      }
    end
  end
end
