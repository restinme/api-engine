require "active_support/core_ext/object/blank"

module Validators
  Presence = Struct.new(:field) do
    def with?(value, _ = nil)
      value.present?
    end

    def error_message
      "can't be blank"
    end
  end

  Uniqueness = Struct.new(:field) do
    def with?(value, context)
      return true unless value

      context.where("data -> ? = ?", field, value).none?
    end

    def error_message
      "has already been taken"
    end
  end

  Size = Struct.new(:field, :size) do
    def with?(value, _ = nil)
      value.present? && value.size >= size
    end

    def error_message
      "can't be smaller than #{size}"
    end
  end
end
