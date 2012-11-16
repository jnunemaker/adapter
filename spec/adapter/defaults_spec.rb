require 'helper'

describe Adapter::Defaults do
  subject {
    Module.new.tap do |m|
      m.extend(Adapter::Defaults)
    end.methods
  }

  # these are all spec'd in shared adapter examples explicitly
  it { should include(:fetch) }
  it { should include(:key?) }
  it { should include(:read_multiple) }
end
