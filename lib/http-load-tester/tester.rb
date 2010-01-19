module HttpLoadTester
  class Tester
    attr_reader :request_limit

    def initialize
      @requests = 0
      @count = 0
      @request_limit = 100
    end
    
    def run
      time = Time.now
      
      threads =[]

      @blocks = []
      100.times do |i|
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
      if @requests == $blocks.length
        @start_time = Time.new
        puts
        puts "Starting"
      end

      if @requests == $blocks.length + @request_limit
        @stop_time = Time.new
        puts
        puts "Stopping"
      end
      
      if @requests >= $blocks.length && @count < @request_limit
        @count += 1
      end

      @requests += 1
    end
  end
end


$blocks = []

def scenario name, &block
  $blocks << block
end
