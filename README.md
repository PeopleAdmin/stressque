stressque
=============
Stressque allows stress testing of Resque workers using simulated load.  This
is useful to do longevity testing when

* Changing job/queue assignments
* Changing worker server hardware
* Changing worker server topology

Using it in a representative test environment with a performance measurement
tool like [resque clues](https://github.com/PeopleAdmin/resque-clues) will
allow you to get some idea of approximate change in production prior to making
those potentially disruptive changes.

Usage
-----
Basic usage is to:

1. Define a test harness using the provided DSL.
2. Wire stressque into your app so that it redefines your workers using the
harness definition.
3. Fire up Resque.
4. Run stressque.

The following walkthrough is from the examples/rails_demo app.  If you have the
following jobs defined...

```ruby
class SalesReportJob
  @queue = :reports

  def self.perform(customer_id, start_date, end_date)
  # a bunch of really complicated stuff.
  end
end

class InventoryReportJob
  @queue = :reports

  def self.perform(customer_id, start_date, end_date)
  # a bunch of really complicated stuff.
  end
end

class ImportJob
  @queue = :import_export

  def self.perform(customer_id, file)
  # a bunch of really complicated stuff.
  end
end

class ExportJob
  @queue = :import_export

  def self.perform(customer_id, file)
  # a bunch of really complicated stuff.
  end
end

```

You can define a test harness using the stressque DSL...

```ruby
harness :rails_demo do
  target_rate 10

  queue :reports do
    job :sales_report_job do
      volume 41
      runtime_min 1
      runtime_max 2
      activity 0.5
      error_rate 0.1
    end

    job :inventory_report_job do
      volume 39
      runtime_min 0.5
      runtime_max 1.0
      activity 0.5
      error_rate 0.2
    end
  end

  queue :import_export do
    job :import_job do
      volume 9
      runtime_min 3
      runtime_max 4
      activity 0.5
      error_rate 0.3
    end
    job :export_job do
      volume 11
      runtime_min 3
      runtime_max 4
      activity 0.5
      error_rate 0.3
    end
  end
end
```

Which should be initialized within your app to redefine your workers for stress
testing.  If you are using rails, this is handled by a railtie, otherwise you
can explicitly do this with...

```ruby
harness = Stressque::DSL.eval_file(path)
harness.freeze_classes!
```

Now you can run Resque to pick up any jobs...

```
STRESSQUE=config/stressque.dsl QUEUES=* VERBOSE=1 bundle exec rake resque:work
```

And the test harness to perform injections according to your definition... If you have a redis running on a different box use `-r <IP> <PORT>`.

```bundle exec stressque -c examples/demo.dsl```

And watch the injections stream by...

![Output](http://i.imgur.com/cOrQiaR.png)

You can see the full diff for the commit to enable this in the rails_demo
app here: [https://github.com/lwoodson/stressque/commit/c8ba8fad7ab63f1f0b1a25a81311db96454015ac](https://github.com/lwoodson/stressque/commit/c8ba8fad7ab63f1f0b1a25a81311db96454015ac)

DSL
---
The examples/demo.dsl file has comments describing the dsl in details.

```ruby
# the top-level harness block defines a test
# harness.
harness :my_load_scenario do
  # target_rate defines the target rate of jobs
  # enqueued per second.
  target_rate 10

  # queue blocks define a queue within the stress
  # test
  queue :email do

    # job blocks define a job type to be created
    # that will be enqueued to the parent queue.
    # The name specified here will be camelcased
    # (fast_email will become FastEmail)
    job :fast_email do

      # The volume of the job within the overall
      # pool of jobs.  The likelihood a job is
      # to be enqueued is its volume / sum of all
      # job volumes.  Defaults to 1.
      volume 5

      # The minimum amount of time to perform the
      # job.  Defaults to 1.
      runtime_min 5

      # The maximum amount of time to perform the
      # job.  Defaults to 2.  The runtime is a
      # random between runtime_min..runtime_max
      runtime_max 10

      # The approximate percentage of a job's
      # runtime where the CPU is pegged.  Defaults
      # to 0.3.
      activity 0.5

      # The error_rate to maintain within the job.
      # Approximately this percentage of enqueues
      # will result in a failure of the job.  The
      # default is 0
      error_rate 0.1
    end

    # another job within the same queue
    job :slow_email do
      volume 1
      runtime_min 5
      runtime_max 10
      activity 0.5
      error_rate 0.2
    end
  end

  # another queue
  queue :reports do
    # another job within the queue.
    job :eeo do
      volume 1
      error_rate 0.05
    end
  end
end
```

Make the jump to hyperspace
---------------------------
stressque is distributable in the same machine or on different machines
to up the load.  They simply have to share the same redis db.  You can test
this as follows:

Open 3 terminals, in the first, run top...

```top -o cpu```

In the second terminal run the examples/as_fast_as_you_can.dsl file...

```bundle exec bin/stressque -c examples/as_fast_as_you_can```

View the CPU use and injection rate with 1 injector...

![One Process Output](http://i.imgur.com/edtlAK8.png)

Kill the first injector, then immediately restart it.  In the third terminal
run the examples/as_fast_as_you_can.dsl file as above.  Now you can view the
CPU use and injection rate with 2 injectors.

![Two Process Output](http://i.imgur.com/dO9bwtz.png)

Resque Clues
------------
You can specify a [resque clues](https://github.com/PeopleAdmin/resque-clues)
event publisher to broadcast the enqueue events for any jobs enqueued by a test
harness.  Do this with the event_publisher DSL element.

```ruby
harness :foo do
  event_publisher do
    Resque::Plugins::Clues::StandardOutPublisher.new
  end
  # rest of your def...
end
```

From Here
---------
Here are a few things we would like to do.

1. Per-job rate tracking
2. Rate equalization profile (throttle up, parabollas, etc..)

Contributing
------------
1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request
