require_relative "errors/cannot_transition_state_error"

module FoobaraDemo
  module LoanOrigination
    class ApproveLoanFile < Foobara::Command
      depends_on CreateUnderwriterDecision

      possible_input_error :loan_file, CannotTransitionStateError

      inputs do
        credit_score_used :integer, :required
        loan_file LoanFile, :required
      end

      def execute
        create_underwriting_decision
        transition_loan_file

        nil
      end

      def validate
        unless loan_file.state_machine.can?(:approve)
          add_input_error CannotTransitionStateError.new(loan_file, attempted_transition: transition, path: :loan_file)
        end
      end

      def transition
        :approve
      end

      def create_underwriting_decision
        run_subcommand!(
          CreateUnderwriterDecision,
          loan_file:,
          decision: :approved,
          credit_score_used:
        )
      end

      def transition_loan_file
        loan_file.state_machine.perform_transition!(transition)
      end
    end
  end
end
