module FoobaraDemo
  module LoanOrigination
    foobara_register_type(:decision, :string, one_of: [:approved, :denied])
    foobara_register_type(:denied_reason, :string, one_of: [:insufficient_pay_stubs_provided, :low_credit_score])

    class LoanFile < Foobara::Entity
      class UnderwriterDecision < Foobara::Model
        attributes do
          decision :decision, :required
          credit_score_used :integer, :required
          denied_reasons [:denied_reason], default: []
        end
      end
    end
  end
end
