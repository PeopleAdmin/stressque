module Utils
  def hard_sleep(length)
    start = Time.now.utc
    while(true) do
      break if (Time.now.utc - start) > length
    end
  end

  def normalized_rand(range)
    (1..10).inject(0) {|e, memo| memo += rand(range)}/10
  end
end
