ENV['PADRINO_ENV'] = 'test'
PADRINO_ROOT = File.dirname(__FILE__) unless defined? PADRINO_ROOT

require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'rack'
require 'shoulda'
require 'thor/group'

# We try to load the vendored padrino-core if exist
%w(core gen helpers).each do |gem|
  if File.exist?(File.dirname(__FILE__) + "/../../padrino-#{gem}/lib")
    $:.unshift File.dirname(__FILE__) + "/../../padrino-#{gem}/lib"
  end
end


require 'padrino-core/support_lite'
require 'padrino-admin'

Padrino::Generators.load_components!

module Kernel
  # Silences the output by redirecting to stringIO
  # silence_logger { ...commands... } => "...output..."
  def silence_logger(&block)
    $stdout = $stderr = log_buffer = StringIO.new
    block.call
    $stdout = STDOUT
    $stderr = STDERR
    log_buffer.string
  end
  alias :silence_stdout :silence_logger

  def load_fixture(file)
    Object.send(:remove_const, :Account)  if defined?(Account)
    Object.send(:remove_const, :Category) if defined?(Category)
    file += ".rb" if file !~ /.rb$/
    silence_stdout { load File.join(File.dirname(__FILE__), "fixtures", file) }
  end
end

class Class
  # Allow assertions in request context
  include Test::Unit::Assertions
end

class Test::Unit::TestCase
  include Rack::Test::Methods

  # Sets up a Sinatra::Base subclass defined with the block
  # given. Used in setup or individual spec methods to establish
  # the application.
  def mock_app(base=Padrino::Application, &block)
    @app = Sinatra.new(base, &block)
    @app.send :include, Test::Unit::Assertions
    @app.use Rack::Session::Cookie if Sinatra::VERSION =~ /0\.9\.\d+/ # Need this because Sinatra 0.9.x have use Rack::Session::Cookie if sessions? && !test?
  end

  def app
    Rack::Lint.new(@app)
  end

  # Asserts that a file matches the pattern
  def assert_match_in_file(pattern, file)
    assert File.exist?(file), "File '#{file}' does not exist!"
    assert_match pattern, File.read(file)
  end

  # Assert_file_exists('/tmp/app')
  def assert_file_exists(file_path)
    assert File.exist?(file_path), "File at path '#{file_path}' does not exist!"
  end

  # Assert_no_file_exists('/tmp/app')
  def assert_no_file_exists(file_path)
    assert !File.exist?(file_path), "File should not exist at path '#{file_path}' but was found!"
  end

  # Asserts that a file matches the pattern
  def assert_match_in_file(pattern, file)
    File.exist?(file) ? assert_match(pattern, File.read(file)) : assert_file_exists(file)
  end

  def assert_no_match_in_file(pattern, file)
    File.exists?(file) ? !assert_match(pattern, File.read(file)) : assert_file_exists(file)
  end

  # Delegate other missing methods to response.
  def method_missing(name, *args, &block)
    if response && response.respond_to?(name)
      response.send(name, *args, &block)
    else
      super(name, *args, &block)
    end
  end

  alias :response :last_response
end