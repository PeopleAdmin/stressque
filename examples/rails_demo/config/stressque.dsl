harness :rails_demo do
  target_rate 10

  queue :reports do
    job :sales_report_job do
      volume 41
      runtime_min 1
      runtime_max 2
      error_rate 0.1
    end

    job :inventory_report_job do
      volume 39
      runtime_min 0.5
      runtime_max 1.0
      error_rate 0.2
    end
  end

  queue :import_export do
    job :import_job do
      volume 9
      runtime_min 3
      runtime_max 4
      error_rate 0.3
    end
    job :export_job do
      volume 11
      runtime_min 3
      runtime_max 4
      error_rate 0.3
    end
  end
end
