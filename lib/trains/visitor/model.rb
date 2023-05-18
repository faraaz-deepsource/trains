# frozen_string_literal: true

require_relative '../dto/association'

module Trains
  module Visitor
    # Vistor for ActiveRecord model
    class Model < Base
      ASSOCIATION_METHODS = %i[
        has_many
        has_one
        belongs_to
        has_and_belongs_to
      ].freeze

      def initialize
        @associations = []
      end

      def on_class(node)
        class_name = node.identifier.const_name.to_s
        parent_class = node.parent_class.const_name.to_s
        return unless model?(parent_class)

        node.each_child(:send) do |send_node|
          next unless ASSOCIATION_METHODS.include? send_node.method_name

          @associations << Association.new(
            model_name: class_name,
            association: send_node.method_name,
            associated_to: send_node.arguments.first
          )
        end
      end

      def result
        @associations
      end

      private

      def model?(parent_class)
        parent_class == 'ApplicationRecord'
      end
    end
  end
end
