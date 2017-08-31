module RSpec
  module Matchers
    def fail_with(message)
      raise_error(RSpec::Expectations::ExpectationNotMetError, message)
    end

    def fail_including(*snippets)
      raise_error(
        RSpec::Expectations::ExpectationNotMetError,
        a_string_including(*snippets)
      )
    end
  end
end
