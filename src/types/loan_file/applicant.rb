module Foobara
  module LoanOrigination
    class LoanFile < Foobara::Entity
      class Applicant < Foobara::Model
        attributes do
          first_name :string, :required
          last_name :string, :required
        end
      end
    end
  end
end
