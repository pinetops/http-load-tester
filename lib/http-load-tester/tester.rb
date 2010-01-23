module HttpLoadTester
  PROCS = 10
  REQUESTS = 500
  
  class Tester
    attr_reader :request_limit
    
    def self.run file
      load file
      self.new.run
    end

    def initialize
      @requests = 0
      @count = 0
      @request_limit = REQUESTS
    end

    def self.scenario name, &block
      $blocks << block
    end
    
    def run
      time = Time.now
      
      threads =[]

      @blocks = []
      PROCS.times do |i|
        @blocks[i] = $blocks[rand($blocks.length)]
      end

      puts "Warming up"
      @blocks.each do |block|
        threads << Thread.new(block) do |b|
          begin
            while true
              client = Client.new(self)
              b.call(client) 
            end
          rescue CompletedException
          end  
        end
      end
      
      threads.each do |t|
        t.join
      end
      
      puts
      puts "#{@count}"
      x = @stop_time - @start_time
      puts "#{@count} request in #{x} seconds"
      puts "#{@count/x} requests per second"
    end

    def feedback
      STDOUT.print "."
      STDOUT.flush
    end

    def increment
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


$blocks = []

def self.scenario name, &block
  $blocks << block
end
