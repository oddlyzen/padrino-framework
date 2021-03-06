module Padrino
  module Generators
    module Components
      module Mocks

        module RrGen
          def setup_mock
            require_dependencies 'rr', :group => 'test'
            case options[:test].to_s
              when 'rspec'
                inject_into_file 'spec/spec_helper.rb', "  conf.mock_with :rr\n", :after => "Spec::Runner.configure do |conf|\n"
              when 'riot'
                inject_into_file "test/test_config.rb","  Riot.rr\n", :after => "class Riot::Situation\n"
              else
                insert_mocking_include "RR::Adapters::RRMethods", :path => "test/test_config.rb"
            end
          end
        end # RrGen
      end # Mocks
    end # Components
  end # Generators
end # Padrino
