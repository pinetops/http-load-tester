module HttpLoadTester
  module DSL
    module Main
      def scenario name, &block
        HttpLoadTester::ScenarioFactory.create_scenario(&block)
      end
    end
  end
end
