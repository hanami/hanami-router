# frozen_string_literal: true

require "rack/head"

RSpec.describe Hanami::Router do
  describe "HTTP: " do
    RSpec::Support::HTTP.mountable_verbs.each do |verb|
      context "##{verb}" do
        let(:router) do
          r = response

          described_class.new do
            __send__ verb, "/",                     to: ->(*) { r }
            __send__ verb, "/hanami",               to: ->(*) { r }
            __send__ verb, "/trailing/",            to: ->(*) { r }
            __send__ verb, "/hanami/:id",           to: ->(*) { r }
            __send__ verb, "/hanami/:id(.:format)", to: ->(*) { r }
            __send__ verb, "/hanami/*glob",         to: ->(*) { r }
            __send__ verb, "/books/:id",            to: ->(*) { r }, id: /\d+/
            __send__ verb, "/named_route",          to: ->(*) { r }, as: :"#{verb}_named_route"
            __send__ verb, "/named_:var",           to: ->(*) { r }, as: :"#{verb}_named_route_var"
            __send__(verb, "/block")                          { |*| r.body }
          end
        end

        let(:app) { Rack::MockRequest.new(router) }

        context "path recognition" do
          context "root trailing slash" do
            let(:response) { Rack::MockResponse.new(200, rack_headers({}), "Trailing root!") }

            it "recognizes" do
              expect(app.request(verb.upcase, "/", lint: true)).to eq_response(response)
            end
          end

          context "trailing slash" do
            let(:response) { Rack::MockResponse.new(200, rack_headers({}), "Trailing!") }

            it "recognizes" do
              expect(app.request(verb.upcase, "/trailing/", lint: true)).to eq_response(response)
            end
          end

          context "fixed string" do
            let(:response) { Rack::MockResponse.new(200, rack_headers({}), "Fixed!") }

            it "recognizes" do
              expect(app.request(verb.upcase, "/hanami", lint: true)).to eq_response(response)
            end
          end

          context "moving parts string" do
            let(:response) { Rack::MockResponse.new(200, rack_headers({}), "Moving!") }

            it "recognizes" do
              expect(app.request(verb.upcase, "/hanami/23", lint: true)).to eq_response(response)
            end
          end

          context "globbing string" do
            let(:response) { Rack::MockResponse.new(200, rack_headers({}), "Globbing!") }

            it "recognizes" do
              expect(app.request(verb.upcase, "/hanami/all", lint: true)).to eq_response(response)
            end
          end

          context "format string" do
            let(:response) { Rack::MockResponse.new(200, rack_headers({}), "Format!") }

            it "recognizes" do
              expect(app.request(verb.upcase, "/hanami/all.json", lint: true)).to eq_response(response)
            end
          end

          context "block" do
            let(:response) { Rack::MockResponse.new(200, block_content_length_headers("Block!"), "Block!") }

            it "recognizes" do
              expect(app.request(verb.upcase, "/block", lint: true)).to eq_response(response)
            end
          end
        end

        describe "constraints" do
          let(:response) { Rack::MockResponse.new(200, rack_headers({}), "Moving with constraints!") }

          it "recognize when called with matching constraints" do
            expect(app.request(verb.upcase, "/books/23", lint: true)).to eq_response(response)
            expect(app.request(verb.upcase, "/books/awdwror", lint: true).status).to eq(404)
          end
        end

        context "named routes" do
          context "symbol" do
            let(:response) { Rack::MockResponse.new(200, rack_headers({}), "Named route!") }

            it "recognizes by the given symbol" do
              expect(router.path(:"#{verb}_named_route")).to eq("/named_route")
              expect(router.url(:"#{verb}_named_route")).to  eq(URI("http://localhost/named_route"))
            end
          end

          context "compiled variables" do
            let(:response) { Rack::MockResponse.new(200, rack_headers({}), "Named %route!") }

            it "recognizes" do
              expect(router.path(:"#{verb}_named_route_var", var: "route")).to eq("/named_route")
              expect(router.url(:"#{verb}_named_route_var", var: "route")).to  eq(URI("http://localhost/named_route"))
            end
          end

          context "custom url parts" do
            let(:response) { Rack::MockResponse.new(200, rack_headers({}), "Named route with custom parts!") }

            it "recognizes" do
              r      = response
              router = Hanami::Router.new(base_url: "https://hanamirb.org") do
                __send__ verb, "/custom_named_route", to: ->(_) { r }, as: :"#{verb}_custom_named_route"
              end

              expect(router.url(:"#{verb}_custom_named_route")).to eq(URI("https://hanamirb.org/custom_named_route"))
            end
          end
        end

        context "#HEAD" do
          let(:app) { Rack::MockRequest.new(Rack::Head.new(router)) }
          let(:response) { Rack::MockResponse.new(405, rack_headers({"Content-Length" => "18", "Allow" => verb.upcase}), []) }

          context "path recognition" do
            context "fixed string" do
              it "recognizes" do
                expect(app.request("HEAD", "/hanami", lint: true)).to eq_response(response)
              end
            end

            context "moving parts string" do
              it "recognizes" do
                expect(app.request("HEAD", "/hanami/23", lint: true)).to eq_response(response)
              end
            end

            context "globbing string" do
              it "recognizes" do
                expect(app.request("HEAD", "/hanami/all", lint: true)).to eq_response(response)
              end
            end

            context "format string" do
              it "recognizes" do
                expect(app.request("HEAD", "/hanami/all.json", lint: true)).to eq_response(response)
              end
            end

            unless verb == "get"
              context "block" do
                it "recognizes" do
                  expect(app.request("HEAD", "/block", lint: true)).to eq_response(response)
                end
              end
            end
          end

          describe "constraints" do
            it "recognize when called with matching constraints" do
              expect(app.request("HEAD", "/books/23", lint: true)).to eq_response(response)
              expect(app.request("HEAD", "/books/awdwror", lint: true).status).to eq(404)
            end
          end
        end
      end
    end

    describe "#root" do
      context "path recognition" do
        let(:app) { Rack::MockRequest.new(router) }

        context "fixed string" do
          let(:router) do
            r = response

            described_class.new do
              root to: ->(_) { r }
            end
          end

          let(:response) { Rack::MockResponse.new(200, rack_headers({}), "Fixed!") }

          it "recognizes" do
            expect(app.request("GET", "/", lint: true)).to eq_response(response)
          end

          it "recognizes by :root" do
            expect(router.path(:root)).to eq("/")
            expect(router.url(:root)).to  eq(URI("http://localhost/"))
          end
        end

        context "block" do
          let(:router) do
            r = response

            described_class.new do
              root { |_| r.body }
            end
          end

          let(:response) { Rack::MockResponse.new(200, block_content_length_headers("Block!"), "Block!") }

          it "recognizes" do
            expect(app.request("GET", "/", lint: true)).to eq_response(response)
          end
        end
      end
    end

    def block_content_length_headers(body)
      if Hanami::Router.rack_3?
        rack_headers({})
      else
        rack_headers({"Content-Length" => body.length.to_s})
      end
    end
  end
end
