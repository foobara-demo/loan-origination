module FoobaraDemo
  module LoanOrigination
    class FindALoanFileThatNeedsReview < Foobara::Command
      result LoanFile, :allow_nil

      def execute
        find_loan_file_that_needs_review

        loan_files
      end

      attr_accessor :loan_files

      def load_all_loan_files
        self.loan_file = LoanFile.find_by(state: "needs_review").first
      end
    end
  end
end
