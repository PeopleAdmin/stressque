resque-stress
=============

Stress testing of resque workers

Usage
=====

```ruby
harness do
  queues do
    queue :email do
      job :fast_email do
        weight: 5
        runtime_min: 1
        runtime_max: 2
        error_rate: .1
      end
      job :slow_email do
        weight: 1
        runtime_min: 5
        runtime_max: 10
        error_rate: .2
      end
    end
    queue :reports do
      job :eeo do
        weight: 1
        error_rate: .05
      end
    end
  end
end
```
