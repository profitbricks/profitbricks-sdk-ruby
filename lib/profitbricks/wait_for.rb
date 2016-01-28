module ProfitBricks
  # Resource wait_for check
  def self.wait_for(timeout = ProfitBricks::Config.timeout,
                    interval = ProfitBricks::Config.interval,
                    &_block)
    duration = 0
    start = Time.now
    retries = 0
    until yield || duration > timeout
      sleep(interval.respond_to?(:call) ? interval.call(retries += 1).to_f : interval.to_f)
      duration = Time.now - start
    end
    if duration > timeout
      fail StandardError,
           "The specified wait_for timeout (#{timeout} seconds) was exceeded."
    else
      { duration: duration }
    end
  end
end
