require "test_helper"

describe Run do
  let(:run) { Run.new }

  it "must be valid" do
    value(run).must_be :valid?
  end
end
