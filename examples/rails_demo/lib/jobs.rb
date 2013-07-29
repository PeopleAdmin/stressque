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
