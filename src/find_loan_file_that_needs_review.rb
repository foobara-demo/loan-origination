module FoobaraDemo
  module LoanOrigination
    class FindALoanFileThatNeedsReview < Foobara::Command
      description "Will return a loan file that needs review or nil if there are no loan files that need review"

      result LoanFile, :allow_nil

      def execute
        find_loan_file_that_needs_review

        loan_file
      end

      attr_accessor :loan_file

      def find_loan_file_that_needs_review
        self.loan_file = LoanFile.find_by(state: "needs_review")
      end
    end
  end
end
