# frozen_string_literal: true

require "csv"

module Hanami
  class Router
    module Formatter
      # Renders a CSV representation of the routes, skipping HEAD routes.
      #
      # You can forward [CSV generation
      # options](https://ruby-doc.org/stdlib-3.1.0/libdoc/csv/rdoc/CSV.html#class-CSV-label-Options+for+Generating]
      # when calling it:
      #
      # ```
      # Hanami::Router::Formatter::CSV.new.call(router.routes, write_headers: false)
      # ```
      #
      # @api public
      # @since 2.0.0
      class CSV
        # @api private
        # @since 2.0.0
        DEFAULT_OPTIONS = {
          write_headers: true
        }.freeze

        # @api private
        # @since 2.0.0
        HEADERS = %w[METHOD PATH TO AS CONSTRAINTS].freeze

        # @param routes [Array<Hanami::Router::Route>]
        # @param csv_opts [Hash] options for `CSV.generate`
        #
        # @return [String]
        #
        # @api public
        # @since 2.0.0
        def call(routes, **csv_opts)
          ::CSV.generate(**DEFAULT_OPTIONS, **csv_opts) do |csv|
            csv << HEADERS if csv.write_headers?
            routes.reduce(csv) do |acc, route|
              route.head? ? acc : acc << row(route)
            end
          end
        end

        private

        def row(route)
          [
            route.http_method.to_s,
            route.path,
            route.inspect_to,
            route.as? ? route.inspect_as : "",
            route.constraints? ? route.inspect_constraints : ""
          ]
        end
      end
    end
  end
end
