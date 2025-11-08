# frozen_string_literal: true

require "rexml/document"
require "hanami/middleware/body_parser"

require "securerandom"

class RandomMiddleware
  HEADER_PREFIX = "X-Random"
  private_constant :HEADER_PREFIX

  def self.headers_count(headers)
    headers.find_all { |header, _| header.start_with?(HEADER_PREFIX) }.count
  end

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    headers["#{HEADER_PREFIX}-#{random}"] = "1"

    [status, headers, body]
  end

  private

  def random
    SecureRandom.hex(8)
  end
end

class MyMiddleware
  def call(*)
  end
end

module Middleware
  class Runtime
    def call(*)
    end
  end

  class ClassMiddleware
    def self.call(*)
    end
  end

  class InstanceMiddleware
    def call(*)
    end
  end
end

class Action
  class Configuration
    attr_reader :name

    def initialize(name)
      @name = name
    end
  end

  attr_reader :configuration

  def initialize(configuration:)
    unless configuration.is_a?(Configuration)
      raise ArgumentError.new("invalid configuration for #{self.class.name}: #{configuration.inspect}")
    end

    @configuration = configuration
  end
end

module Web
  module Controllers
    module Home
      class Index < Action
        def call(*)
          [200, {}, ["Hello from Web::Controllers::Home::Index"]]
        end
      end
    end # Home

    module Dashboard
      class Index < Action
        def call(*)
          [200, {}, ["Hello from Web::Controllers::Dashboard::Index"]]
        end
      end
    end # Dashboard

    module Sessions
      class New < Action
        def call(*)
          [200, {}, ["Hello from Web::Controllers::Sessions::New"]]
        end
      end

      class Create < Action
        def call(*)
          [200, {}, ["Hello from Web::Controllers::Sessions::Create"]]
        end
      end
    end

    module Settings
      class Show < Action
        def call(*)
          [200, {}, ["Hello from Web::Controllers::Settings::Show"]]
        end
      end
    end

    module Users
      class Show < Action
        def call(*)
          [200, {}, ["Hello from Web::Controllers::Users::Show"]]
        end
      end
    end

    module Topics
      class Show < Action
        def call(*)
          [200, {}, ["Hello from Web::Controllers::Topics::Show"]]
        end
      end
    end
  end
end # Web

module Admin
  module Controllers
    module Home
      class Index < Action
        def call(*)
          [200, {}, ["Hello from Admin::Controllers::Home::Index"]]
        end
      end
    end # Home

    module Sessions
      class New < Action
        def call(*)
          [200, {}, ["Hello from Admin::Controllers::Sessions::New"]]
        end
      end

      class Create < Action
        def call(*)
          [200, {}, ["Hello from Admin::Controllers::Sessions::Create"]]
        end
      end
    end

    module Settings
      class Show < Action
        def call(*)
          [200, {}, ["Hello from Admin::Controllers::Settings::Show"]]
        end
      end
    end

    module Users
      class Show < Action
        def call(*)
          [200, {}, ["Hello from Admin::Controllers::Users::Show"]]
        end
      end
    end

    module Topics
      class Show < Action
        def call(*)
          [200, {}, ["Hello from Admin::Controllers::Topics::Show"]]
        end
      end
    end
  end
end

module Front
  class App
    def call(env)
      case env["PATH_INFO"]
      when "/home"
        [200, {}, ["front"]]
      else
        [404, {}, ["Not Found"]]
      end
    end
  end
end # Front

module Back
  class App
    def call(env)
      case env["PATH_INFO"]
      when "/home"
        [200, {}, ["back"]]
      else
        [404, {}, ["Not Found"]]
      end
    end
  end
end # Back

module Api
  class App
    def call(env)
      case env["PATH_INFO"]
      when "/"
        [200, {}, ["home"]]
      when "/articles"
        [200, {}, ["articles"]]
      else
        [404, {}, ["Not Found"]]
      end
    end
  end
end # Api

module Backend
  class App
    VERBS = %w[GET POST DELETE PUT PATCH TRACE OPTIONS LINK UNLINK].freeze
    def self.call(env)
      if VERBS.include? env["REQUEST_METHOD"]
        [200, {}, ["home"]]
      else
        [405, {}, ["Method Not Allowed"]]
      end
    end
  end
end # Backend

module Dashboard
  class Index
    def call(_env)
      [200, {}, ["dashboard"]]
    end
  end
end # Dashboard

class TestEndpoint
  def call(_env)
    "Hi from TestEndpoint!"
  end
end # TestEndpoint

module Test
  class Show
    def call(_env)
      "Hi from Test::Show!"
    end
  end
end # Test

class TestApp
  class TestEndpoint
    def call(_env)
      "Hi from TestApp::TestEndpoint!"
    end
  end

  module Test2
    class Show
      def call(_env)
        "Hi from TestApp::Test2::Show!"
      end
    end
  end
end # TestApp

module Controllers
  class Test
    class Show
      def call(_env)
        "Hi from Controllers::Test::Show!"
      end
    end
  end
end

module Avatar
  class New < Action
    def call(*)
      [200, {}, ["Avatar::New"]]
    end
  end

  class Create < Action
    def call(*)
      [200, {}, ["Avatar::Create"]]
    end
  end

  class Show < Action
    def call(*)
      [200, {}, ["Avatar::Show"]]
    end
  end

  class Edit < Action
    def call(*)
      [200, {}, ["Avatar::Edit"]]
    end
  end

  class Update < Action
    def call(*)
      [200, {}, ["Avatar::Update"]]
    end
  end

  class Destroy < Action
    def call(*)
      [200, {}, ["Avatar::Destroy"]]
    end
  end
end # Avatar

module Profile
  class Show < Action
    def call(*)
      [200, {}, ["Profile::Show"]]
    end
  end

  class New < Action
    def call(*)
      [200, {}, ["Profile::New"]]
    end
  end

  class Create < Action
    def call(*)
      [200, {}, ["Profile::Create"]]
    end
  end

  class Edit < Action
    def call(*)
      [200, {}, ["Profile::Edit"]]
    end
  end

  class Update < Action
    def call(*)
      [200, {}, ["Profile::Update"]]
    end
  end

  class Destroy < Action
    def call(*)
      [200, {}, ["Profile::Destroy"]]
    end
  end

  class Activate < Action
    def call(*)
      [200, {}, ["Profile::Activate"]]
    end
  end

  class Deactivate < Action
    def call(*)
      [200, {}, ["Profile::Deactivate"]]
    end
  end

  class Keys < Action
    def call(*)
      [200, {}, ["Profile::Keys"]]
    end
  end

  class Activities < Action
    def call(*)
      [200, {}, ["Profile::Activities"]]
    end
  end
end # Profile

module Flowers
  class Index < Action
    def call(*)
      [200, {}, ["Flowers::Index"]]
    end
  end

  class New < Action
    def call(*)
      [200, {}, ["Flowers::New"]]
    end
  end

  class Create < Action
    def call(*)
      [200, {}, ["Flowers::Create"]]
    end
  end

  class Show < Action
    def call(env)
      [200, {}, ["Flowers::Show #{env['router.params'][:id]}"]]
    end
  end

  class Edit < Action
    def call(env)
      [200, {}, ["Flowers::Edit #{env['router.params'][:id]}"]]
    end
  end

  class Update < Action
    def call(env)
      [200, {}, ["Flowers::Update #{env['router.params'][:id]}"]]
    end
  end

  class Destroy < Action
    def call(env)
      [200, {}, ["Flowers::Destroy #{env['router.params'][:id]}"]]
    end
  end
end # Flowers

module Keyboards
  class Index < Action
    def call(*)
      [200, {}, ["Keyboards::Index"]]
    end
  end

  class Create < Action
    def call(*)
      [200, {}, ["Keyboards::Create"]]
    end
  end

  class Edit < Action
    def call(env)
      [200, {}, ["Keyboards::Edit #{env['router.params'][:id]}"]]
    end
  end

  class Show < Action
    def call(env)
      [200, {}, ["Keyboards::Show #{env['router.params'][:id]}"]]
    end
  end

  class Search < Action
    def call(*)
      [200, {}, ["Keyboards::Search"]]
    end
  end

  class Screenshot < Action
    def call(env)
      [200, {}, ["Keyboards::Screenshot #{env['router.params'][:id]}"]]
    end
  end

  class Print < Action
    def call(env)
      [200, {}, ["Keyboards::Print #{env['router.params'][:id]}"]]
    end
  end

  class Characters < Action
    def call(*)
      [200, {}, ["Keyboards::Characters"]]
    end
  end
end # Keyboards

module Keys
  class Index < Action
    def call(*)
      [200, {}, ["Keys::Index"]]
    end
  end

  class New < Action
    def call(*)
      [200, {}, ["Keys::New"]]
    end
  end

  class Create < Action
    def call(*)
      [200, {}, ["Keys::Create"]]
    end
  end

  class Edit < Action
    def call(env)
      [200, {}, ["Keys::Edit #{env['router.params'][:id]}"]]
    end
  end

  class Update < Action
    def call(env)
      [200, {}, ["Keys::Update #{env['router.params'][:id]}"]]
    end
  end

  class Show < Action
    def call(env)
      [200, {}, ["Keys::Show #{env['router.params'][:id]}"]]
    end
  end

  class Destroy < Action
    def call(env)
      [200, {}, ["Keys::Destroy #{env['router.params'][:id]}"]]
    end
  end

  class Search < Action
    def call(*)
      [200, {}, ["Keys::Search"]]
    end
  end

  class Screenshot < Action
    def call(env)
      [200, {}, ["Keys::Screenshot #{env['router.params'][:id]}"]]
    end
  end
end # Keyboards

class XMLBodyParser < Hanami::Middleware::BodyParser::Parser
  def self.media_types = ["application/xml", "text/xml"]

  def parse(body, *)
    result = {}

    xml = REXML::Document.new(body)
    xml.elements.each("*") { |el| result[el.name] = el.text }

    result
  end
end

class RackMiddleware
  def self.call(_env)
    [200, {}, ["RackMiddleware"]]
  end
end

class RackMiddlewareInstanceMethod
  def call(_env)
    [200, {}, ["RackMiddlewareInstanceMethod"]]
  end
end

module Nested
  module Controllers
    module Users
      module Posts
        class Index
          def call(_env)
            [200, {}, ["Hello from Nested::Controllers::Users::Posts::Index"]]
          end
        end
      end

      module Avatar
        class Show
          def call(_env)
            [200, {}, ["Hello from Nested::Controllers::Users::Avatar::Show"]]
          end
        end
      end

      module Posts
        module Comments
          class Index
            def call(_env)
              [200, {}, ["Hello from Nested::Controllers::Users::Posts::Comments::Index"]]
            end
          end
        end
      end
    end

    module User
      module Comments
        class Index
          def call(_env)
            [200, {}, ["Hello from Nested::Controllers::User::Comments::Index"]]
          end
        end
      end

      module ApiKey
        class Show
          def call(_env)
            [200, {}, ["Hello from Nested::Controllers::User::ApiKey::Show"]]
          end
        end
      end
    end

    module Products
      module Variants
        class Index
          def call(_env)
            [200, {}, ["Hello from Nested::Controllers::Products::Variants::Index"]]
          end
        end

        class Show
          def call(_env)
            [200, {}, ["Hello from Nested::Controllers::Products::Variants::Show"]]
          end
        end
      end
    end
  end
end

# NESTED

# resource > resource > resource
module User
  class New < Action
    def call(*)
      [200, {}, ["User::New"]]
    end
  end

  class Create < Action
    def call(*)
      [200, {}, ["User::Create"]]
    end
  end

  class Show < Action
    def call(*)
      [200, {}, ["User::Show"]]
    end
  end

  class Edit < Action
    def call(*)
      [200, {}, ["User::Edit"]]
    end
  end

  class Update < Action
    def call(*)
      [200, {}, ["User::Update"]]
    end
  end

  class Destroy < Action
    def call(*)
      [200, {}, ["User::Destroy"]]
    end
  end

  module Post
    class New < Action
      def call(*)
        [200, {}, ["User::Post::New"]]
      end
    end

    class Create < Action
      def call(*)
        [200, {}, ["User::Post::Create"]]
      end
    end

    class Show < Action
      def call(*)
        [200, {}, ["User::Post::Show"]]
      end
    end

    class Edit < Action
      def call(*)
        [200, {}, ["User::Post::Edit"]]
      end
    end

    class Update < Action
      def call(*)
        [200, {}, ["User::Post::Update"]]
      end
    end

    class Destroy < Action
      def call(*)
        [200, {}, ["User::Post::Destroy"]]
      end
    end

    module Comment
      class New < Action
        def call(*)
          [200, {}, ["User::Post::Comment::New"]]
        end
      end

      class Create < Action
        def call(*)
          [200, {}, ["User::Post::Comment::Create"]]
        end
      end

      class Show < Action
        def call(*)
          [200, {}, ["User::Post::Comment::Show"]]
        end
      end

      class Edit < Action
        def call(*)
          [200, {}, ["User::Post::Comment::Edit"]]
        end
      end

      class Update < Action
        def call(*)
          [200, {}, ["User::Post::Comment::Update"]]
        end
      end

      class Destroy < Action
        def call(*)
          [200, {}, ["User::Post::Comment::Destroy"]]
        end
      end
    end
  end
end

# resource > resource > resources
module User
  module Post
    module Comments
      class Index < Action
        def call(*)
          [200, {}, ["User::Post::Comments::Index"]]
        end
      end

      class New < Action
        def call(*)
          [200, {}, ["User::Post::Comments::New"]]
        end
      end

      class Create < Action
        def call(*)
          [200, {}, ["User::Post::Comments::Create"]]
        end
      end

      class Show < Action
        def call(*)
          [200, {}, ["User::Post::Comments::Show"]]
        end
      end

      class Edit < Action
        def call(*)
          [200, {}, ["User::Post::Comments::Edit"]]
        end
      end

      class Update < Action
        def call(*)
          [200, {}, ["User::Post::Comments::Update"]]
        end
      end

      class Destroy < Action
        def call(*)
          [200, {}, ["User::Post::Comments::Destroy"]]
        end
      end
    end
  end
end

# resource > resources > resources
module User
  module Posts
    class Index < Action
      def call(*)
        [200, {}, ["User::Posts::Index"]]
      end
    end

    class New < Action
      def call(*)
        [200, {}, ["User::Posts::New"]]
      end
    end

    class Create < Action
      def call(*)
        [200, {}, ["User::Posts::Create"]]
      end
    end

    class Show < Action
      def call(*)
        [200, {}, ["User::Posts::Show"]]
      end
    end

    class Edit < Action
      def call(*)
        [200, {}, ["User::Posts::Edit"]]
      end
    end

    class Update < Action
      def call(*)
        [200, {}, ["User::Posts::Update"]]
      end
    end

    class Destroy < Action
      def call(*)
        [200, {}, ["User::Posts::Destroy"]]
      end
    end

    module Comments
      class Index < Action
        def call(*)
          [200, {}, ["User::Posts::Comments::Index"]]
        end
      end

      class New < Action
        def call(*)
          [200, {}, ["User::Posts::Comments::New"]]
        end
      end

      class Create < Action
        def call(*)
          [200, {}, ["User::Posts::Comments::Create"]]
        end
      end

      class Show < Action
        def call(*)
          [200, {}, ["User::Posts::Comments::Show"]]
        end
      end

      class Edit < Action
        def call(*)
          [200, {}, ["User::Posts::Comments::Edit"]]
        end
      end

      class Update < Action
        def call(*)
          [200, {}, ["User::Posts::Comments::Update"]]
        end
      end

      class Destroy < Action
        def call(*)
          [200, {}, ["User::Posts::Comments::Destroy"]]
        end
      end
    end
  end
end

# resource > resources > resource
module User
  module Posts
    module Comment
      class New < Action
        def call(*)
          [200, {}, ["User::Posts::Comment::New"]]
        end
      end

      class Create < Action
        def call(*)
          [200, {}, ["User::Posts::Comment::Create"]]
        end
      end

      class Show < Action
        def call(*)
          [200, {}, ["User::Posts::Comment::Show"]]
        end
      end

      class Edit < Action
        def call(*)
          [200, {}, ["User::Posts::Comment::Edit"]]
        end
      end

      class Update < Action
        def call(*)
          [200, {}, ["User::Posts::Comment::Update"]]
        end
      end

      class Destroy < Action
        def call(*)
          [200, {}, ["User::Posts::Comment::Destroy"]]
        end
      end
    end
  end
end

# resources > resources > resources
module Users
  class Index < Action
    def call(*)
      [200, {}, ["Users::Index"]]
    end
  end

  class New < Action
    def call(*)
      [200, {}, ["Users::New"]]
    end
  end

  class Create < Action
    def call(*)
      [200, {}, ["Users::Create"]]
    end
  end

  class Show < Action
    def call(*)
      [200, {}, ["Users::Show"]]
    end
  end

  class Edit < Action
    def call(*)
      [200, {}, ["Users::Edit"]]
    end
  end

  class Update < Action
    def call(*)
      [200, {}, ["Users::Update"]]
    end
  end

  class Destroy < Action
    def call(*)
      [200, {}, ["Users::Destroy"]]
    end
  end

  module Posts
    class Index < Action
      def call(*)
        [200, {}, ["Users::Posts::Index"]]
      end
    end

    class New < Action
      def call(*)
        [200, {}, ["Users::Posts::New"]]
      end
    end

    class Create < Action
      def call(*)
        [200, {}, ["Users::Posts::Create"]]
      end
    end

    class Show < Action
      def call(*)
        [200, {}, ["Users::Posts::Show"]]
      end
    end

    class Edit < Action
      def call(*)
        [200, {}, ["Users::Posts::Edit"]]
      end
    end

    class Update < Action
      def call(*)
        [200, {}, ["Users::Posts::Update"]]
      end
    end

    class Destroy < Action
      def call(*)
        [200, {}, ["Users::Posts::Destroy"]]
      end
    end

    module Comments
      class Index < Action
        def call(*)
          [200, {}, ["Users::Posts::Comments::Index"]]
        end
      end

      class New < Action
        def call(*)
          [200, {}, ["Users::Posts::Comments::New"]]
        end
      end

      class Create < Action
        def call(*)
          [200, {}, ["Users::Posts::Comments::Create"]]
        end
      end

      class Show < Action
        def call(*)
          [200, {}, ["Users::Posts::Comments::Show"]]
        end
      end

      class Edit < Action
        def call(*)
          [200, {}, ["Users::Posts::Comments::Edit"]]
        end
      end

      class Update < Action
        def call(*)
          [200, {}, ["Users::Posts::Comments::Update"]]
        end
      end

      class Destroy < Action
        def call(*)
          [200, {}, ["Users::Posts::Comments::Destroy"]]
        end
      end
    end
  end
end # User

# resources > resources > resource
module Users
  module Posts
    module Comment
      class New < Action
        def call(*)
          [200, {}, ["Users::Posts::Comment::New"]]
        end
      end

      class Create < Action
        def call(*)
          [200, {}, ["Users::Posts::Comment::Create"]]
        end
      end

      class Show < Action
        def call(*)
          [200, {}, ["Users::Posts::Comment::Show"]]
        end
      end

      class Edit < Action
        def call(*)
          [200, {}, ["Users::Posts::Comment::Edit"]]
        end
      end

      class Update < Action
        def call(*)
          [200, {}, ["Users::Posts::Comment::Update"]]
        end
      end

      class Destroy < Action
        def call(*)
          [200, {}, ["Users::Posts::Comment::Destroy"]]
        end
      end
    end
  end
end

# resources > resource > resources
module Users
  module Post
    class New < Action
      def call(*)
        [200, {}, ["Users::Post::New"]]
      end
    end

    class Create < Action
      def call(*)
        [200, {}, ["Users::Post::Create"]]
      end
    end

    class Show < Action
      def call(*)
        [200, {}, ["Users::Post::Show"]]
      end
    end

    class Edit < Action
      def call(*)
        [200, {}, ["Users::Post::Edit"]]
      end
    end

    class Update < Action
      def call(*)
        [200, {}, ["Users::Post::Update"]]
      end
    end

    class Destroy < Action
      def call(*)
        [200, {}, ["Users::Post::Destroy"]]
      end
    end

    class Search < Action
      def call(*)
        [200, {}, ["Users::Post::Search"]]
      end
    end

    class Screenshot < Action
      def call(*)
        [200, {}, ["Users::Post::Screenshot"]]
      end
    end

    module Comments
      class Index < Action
        def call(*)
          [200, {}, ["Users::Post::Comments::Index"]]
        end
      end

      class New < Action
        def call(*)
          [200, {}, ["Users::Post::Comments::New"]]
        end
      end

      class Create < Action
        def call(*)
          [200, {}, ["Users::Post::Comments::Create"]]
        end
      end

      class Show < Action
        def call(*)
          [200, {}, ["Users::Post::Comments::Show"]]
        end
      end

      class Edit < Action
        def call(*)
          [200, {}, ["Users::Post::Comments::Edit"]]
        end
      end

      class Update < Action
        def call(*)
          [200, {}, ["Users::Post::Comments::Update"]]
        end
      end

      class Destroy < Action
        def call(*)
          [200, {}, ["Users::Post::Comments::Destroy"]]
        end
      end

      class Search < Action
        def call(*)
          [200, {}, ["Users::Post::Comments::Search"]]
        end
      end

      class Screenshot < Action
        def call(*)
          [200, {}, ["Users::Post::Comments::Screenshot"]]
        end
      end
    end
  end
end

# resources > resource > resource
module Users
  module Post
    module Comment
      class New < Action
        def call(*)
          [200, {}, ["Users::Post::Comment::New"]]
        end
      end

      class Create < Action
        def call(*)
          [200, {}, ["Users::Post::Comment::Create"]]
        end
      end

      class Show < Action
        def call(*)
          [200, {}, ["Users::Post::Comment::Show"]]
        end
      end

      class Edit < Action
        def call(*)
          [200, {}, ["Users::Post::Comment::Edit"]]
        end
      end

      class Update < Action
        def call(*)
          [200, {}, ["Users::Post::Comment::Update"]]
        end
      end

      class Destroy < Action
        def call(*)
          [200, {}, ["Users::Post::Comment::Destroy"]]
        end
      end
    end
  end
end
