module SqlTools
  module Selection
    Column = Data.define(:name, :column)
    Invocation = Data.define(:name, :invocation)
    AllFields = Data.define(:table)
  end
end
