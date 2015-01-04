require 'hashie/mash'

module RestInMe
  class Engines::EntityBuilder
    def initialize(config)
      @config = ::Hashie::Mash.new config
    end

    def call
      config = @config

      klass = bootstrap_klass

      mix_in_fields klass

      klass
    end

    private

    def bootstrap_klass
      config = @config
      ::Class.new do
        include ::Mongoid::Document
        include ::Mongoid::Timestamps

        store_in collection: config.name

        define_singleton_method :name do
          config.name
        end
      end
    end

    def mix_in_fields(klass)
      @config.fields.map(&as_field_config)
        .each { |field| field.apply_on klass }
    end

    def as_field_config
      lambda { |field| FieldConfig.new(field) }
    end
  end

  class FieldConfig < ::OpenStruct
    def apply_on(klass)
      type_klass = ::Module.const_get type.capitalize
      field_name = proper_field_name
      klass.instance_eval do
        field field_name.to_sym, type: type_klass
      end
    end

    private

    def proper_field_name
      field_name.downcase.gsub /\s/, '_'
    end
  end
end