class PunterException < Exception
  def initialize(params = nil)
    super(params)
    RAILS_DEFAULT_LOGGER.error("PunterException: #{self.to_s}")
  end
end
