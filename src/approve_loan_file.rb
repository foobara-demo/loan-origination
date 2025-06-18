module FoobaraDemo
  module LoanOrigination
    class ApproveLoanFile < Foobara::Command
      inputs do
        credit_score_used :integer, :required
        loan_file LoanFile, :required
      end
      result LoanFile

      def execute
        create_underwriting_decision
        transition_loan_file

        loan_file
      end

      def create_underwriting_decision
        loan_file.underwriter_decision = LoanFile::UnderwriterDecision.new(decision: :approved, credit_score_used:)
      end

      def transition_loan_file
        loan_file.state_machine.perform_transition!(:approve)
      end
    end
  end
end
