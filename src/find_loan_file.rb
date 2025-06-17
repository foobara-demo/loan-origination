module FoobaraDemo
  module LoanOrigination
    class FindLoanFile < Foobara::Command
      inputs do
        loan_file LoanFile, :required
      end
      result LoanFile

      def execute
        loan_file
      end
    end
  end
end
