require "observer"

module HttpLoadTester
  class ScenarioFactory
    class << self
      def create_scenario(&block)
        scenario_class = Class.new
        scenario_class.class_eval do
          include Scenario
          include Observable
          extend Callbacks

          callback :on_completion
          callback :on_start
    
          define_method :execute, block
        end
        
        ::HttpLoadTester::Tester.instance.scenario_classes << scenario_class
      end
    end
  end
end
