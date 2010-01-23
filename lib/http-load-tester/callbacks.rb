module HttpLoadTester
  module Callbacks
    def callback(*names)
      names.each do |name|
        class_eval <<-EOF
          def #{name}(*args, &block)
            if block
              @#{name} = block
            elsif @#{name}
              @#{name}.call(*args)
            end
          end
        EOF
      end
    end
  end
end
