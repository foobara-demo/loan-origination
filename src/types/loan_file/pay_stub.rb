module Foobara
  module LoanOrigination
    class LoanFile < Foobara::Entity
      class PayStub < Foobara::Model
        attributes do
          amount :integer
          date :date
          employer :string
        end
      end
    end
  end
end
