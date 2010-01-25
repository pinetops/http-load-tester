require 'thread'

module HttpLoadTester
  PROCS = 10
  REQUESTS = 500

  class Tester
    include MonitorMixin

    attr_reader :request_limit
    
    class << self
      def run file
        load file
        instance.run
      end

      def instance
        @@tester ||= self.new
      end
    end

    def initialize
      @requests = 0
      @count = 0
      @request_limit = REQUESTS
      @mutex = Mutex.new
    end

    def scenarios
      @scenarios ||= []
    end
    
    def processes
      processes = []
      PROCS.times do |i|
        processes[i] = scenarios[rand(scenarios.length)]
      end
      processes
    end

    def run
      puts "Warming up"

      run_scenarios
      print_summary
    end

    def run_scenarios
      processes.collect do |block|
        Thread.new(block) do |b|
          begin
            while true
              scenario_instance = b.new(self)
              scenario_instance.on_start do
                rand(5).times do
                  raise CompletedException.new if @count >= request_limit
                  sleep 1
                end
              end

              scenario_instance.on_completion do
                show_progress
                increment
              end
              scenario_instance.execute
            end
          rescue CompletedException
          end  
        end
      end.each do |t|
        t.join
      end
    end
    
    def print_summary
      puts
      x = @stop_time - @start_time
      puts "#{@count} request in #{x} seconds"
      puts "#{@count/x} requests per second"
    end
      
    def show_progress
      STDOUT.print "."
      STDOUT.flush
    end

    def increment
      @mutex.synchronize do
        if @requests == PROCS
          @start_time = Time.new
          puts
          puts "Starting"
        end
        
        if @requests == PROCS + @request_limit
          @stop_time = Time.new
          puts
          puts "Stopping"
        end
      
        if @requests >= PROCS && @count < @request_limit
          @count += 1
        end
        
        @requests += 1
      end
    end
  end
end

include HttpLoadTester::DSL::Main
