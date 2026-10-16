# frozen_string_literal: true

module Hanami
  class Router
    # Renders a human friendly representation of the routes
    #
    # @api private
    # @since 2.0.0
    module Formatter
      class HumanFriendly
        # @api private
        # @since 2.0.0
        NEW_LINE = $/
        private_constant :NEW_LINE

        # @api private
        # @since 2.0.0
        SMALL_STRING_JUSTIFY_AMOUNT = 8
        private_constant :SMALL_STRING_JUSTIFY_AMOUNT

        # @api private
        # @since 2.0.0
        MEDIUM_STRING_JUSTIFY_AMOUNT = 20
        private_constant :MEDIUM_STRING_JUSTIFY_AMOUNT

        # @api private
        # @since 2.0.0
        LARGE_STRING_JUSTIFY_AMOUNT = 30
        private_constant :LARGE_STRING_JUSTIFY_AMOUNT

        # @api private
        # @since 2.0.0
        EXTRA_LARGE_STRING_JUSTIFY_AMOUNT = 40
        private_constant :EXTRA_LARGE_STRING_JUSTIFY_AMOUNT

        # @api private
        # @since 2.0.0
        COLUMN_SPACING = 5
        private_constant :COLUMN_SPACING

        # @api private
        # @since 2.0.0
        def call(routes)
          filtered_routes = routes.reject(&:head?)
          return "" if filtered_routes.empty?

          column_widths = calculate_column_widths(filtered_routes)
          filtered_routes.map { |route| format_route(route, column_widths) }.join(NEW_LINE)
        end

        private

        def calculate_column_widths(routes)
          path_width = LARGE_STRING_JUSTIFY_AMOUNT
          inspect_to_width = LARGE_STRING_JUSTIFY_AMOUNT
          as_width = MEDIUM_STRING_JUSTIFY_AMOUNT
          constraints_width = EXTRA_LARGE_STRING_JUSTIFY_AMOUNT

          routes.each do |route|
            path_width = [path_width, route.path.length].max
            inspect_to_width = [inspect_to_width, route.inspect_to.length].max
            as_width = [as_width, route.as? ? "as #{route.inspect_as}".length : 0].max
            constraints_width = [constraints_width,
                                 route.constraints? ? "(#{route.inspect_constraints})".length : 0].max
          end

          # Include spacing in the widths
          [path_width + COLUMN_SPACING, inspect_to_width + COLUMN_SPACING, as_width + COLUMN_SPACING, constraints_width]
        end

        def format_route(route, column_widths)
          path_width, inspect_to_width, as_width, constraints_width = column_widths

          [
            route.http_method.to_s.ljust(SMALL_STRING_JUSTIFY_AMOUNT),
            route.path.ljust(path_width),
            route.inspect_to.ljust(inspect_to_width),
            route.as? ? "as #{route.inspect_as}".ljust(as_width) : "",
            route.constraints? ? "(#{route.inspect_constraints})".ljust(constraints_width) : ""
          ].join
        end
      end
    end
  end
end
