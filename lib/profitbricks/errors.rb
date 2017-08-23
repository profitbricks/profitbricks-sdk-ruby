module ProfitBricks
  class Errors
    class Error < StandardError; end
    class OperationFailure < StandardError; end
    class Unauthorized < StandardError; end
  end
end
