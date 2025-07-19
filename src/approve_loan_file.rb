module FoobaraDemo
  module LoanOrigination
    class ApproveLoanFile < Foobara::Command
      depends_on CreateUnderwriterDecision, TransitionLoanFileState

      inputs do
        credit_score_used :integer, :required
        loan_file LoanFile, :required
      end

      def execute
        create_underwriting_decision
        transition_loan_file

        nil
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
        run_subcommand!(TransitionLoanFileState, loan_file:, transition:)
      end
    end
  end
end
