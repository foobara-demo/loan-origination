module FoobaraDemo
  module LoanOrigination
    class StartUnderwriterReview < Foobara::Command
      inputs do
        loan_file LoanFile, :required
      end
      result LoanFile

      def execute
        transition_loan_file

        loan_file
      end

      def transition_loan_file
        loan_file.state_machine.perform_transition!(:start_review)
      end
    end
  end
end
