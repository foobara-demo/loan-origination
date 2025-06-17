module FoobaraDemo
  module LoanOrigination
    class DenyLoanFile < Foobara::Command
      possible_input_error :denied_reasons, :cannot_be_empty

      inputs do
        credit_score_used :integer, :required
        denied_reasons [:denial_reason], :required
        loan_file LoanFile, :required
      end
      result LoanFile

      def execute
        validate_denied_reasons
        create_underwriting_decision
        transition_loan_file

        loan_file
      end

      def validate
        if denied_reasons.empty?
          add_input_error(:denied_reasons, :cannot_be_empty)
        end
      end

      def create_underwriting_decision
        loan_file.underwriter_decision = UnderwriterDecision.create(
          decision: :denied,
          credit_score_used:,
          denied_reasons:
        )
      end

      def transition_loan_file
        loan_file.state_machine.transition!(:approve)
      end
    end
  end
end
