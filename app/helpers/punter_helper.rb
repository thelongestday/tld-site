module PunterHelper

  # AS helper
  def has_paid_ticket_column(record)
    record.has_paid_ticket? ? 'Yes' : 'No'
  end
end
