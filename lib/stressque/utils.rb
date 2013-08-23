module Stressque
  module Utils
    def hard_sleep(length)
      exec_until(length) {}
    end

    def active_sleep(length, activity)
      slice = length / 100
      exec_until(length) do
        if rand < activity
          hard_sleep(slice)
        else
          sleep(slice)
        end
      end
    end

    def normalized_rand(range)
      (1..10).inject(0) {|e, memo| memo += rand(range)}/10
    end

    private
    def exec_until(length, &block)
      start = Time.now.utc
      while(true)
        block.call
        break if (Time.now.utc - start) > length
      end
    end
  end
end
