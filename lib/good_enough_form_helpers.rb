module GoodEnoughFormBuilder
  module Helpers
    def ge_form_for(record_or_name_or_array, *args, &block)
      options = args.extract_options! || {}
      options[:builder] = GoodEnoughFormBuilder::Builder
      args << options
      form_for(record_or_name_or_array, *args, &block)
    end
  end
end