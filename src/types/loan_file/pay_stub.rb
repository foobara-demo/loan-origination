module FoobaraDemo
  module LoanOrigination
    class LoanFile < Foobara::Entity
      class PayStub < Foobara::Model
        attributes do
          amount :integer, :required
          date :date, :required
          employer :string, :required
        end
      end
    end
  end
end
