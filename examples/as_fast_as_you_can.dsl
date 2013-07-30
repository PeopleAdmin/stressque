harness :as_fast_as_you_can do
  target_rate 1000000000
  queue :speedy do
    job :ultra do
      weight 1
      runtime_min 0.1
      runtime_max 0.1
    end
  end
end
