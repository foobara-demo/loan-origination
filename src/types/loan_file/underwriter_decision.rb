module FoobaraDemo
  module LoanOrigination
    class LoanFile < Foobara::Entity
      class UnderwriterDecision < Foobara::Model
        attributes do
          decision :decision, :required
          integer :credit_score_used, :required
          denied_reasons [:denied_reason], :allow_nil
        end
      end

      foobara_register_type(:decision, :string, one_of: [:approved, :denied])
      foobara_register_type(:denied_reason, :string, one_of: [:insufficient_pay_stubs_provided, :low_credit_score])
    end
  end
end
