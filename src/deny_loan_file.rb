module FoobaraDemo
  module LoanOrigination
    class DenyLoanFile < Foobara::Command
      possible_input_error :denied_reasons, :cannot_be_empty
      possible_input_error :loan_file, CannotTransitionStateError

      inputs do
        credit_score_used :integer, :required
        denied_reasons [:denied_reason], :required
        loan_file LoanFile, :required
      end
      result LoanFile

      def execute
        create_underwriting_decision
        transition_loan_file

        loan_file
      end

      def validate
        if denied_reasons.empty?
          add_input_error(:denied_reasons, :cannot_be_empty)
        end

        unless loan_file.state_machine.can?(:approve)
          add_input_error CannotTransitionStateError.new(loan_file, attempted_transition: transition, path: :loan_file)
        end
      end

      def create_underwriting_decision
        loan_file.underwriter_decision = LoanFile::UnderwriterDecision.new(
          decision: :denied,
          credit_score_used:,
          denied_reasons:
        )
      end

      def transition
        :deny
      end

      def transition_loan_file
        loan_file.state_machine.perform_transition!(transition)
      end
    end
  end
end
