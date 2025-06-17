module FoobaraDemo
  module LoanOrigination
    class StartLoanApplication < Foobara::Command
      inputs LoanApplication.attributes_for_create
      result LoanFile

      def execute
        create_application
        create_loan_file

        loan_file
      end

      attr_accessor :loan_file, :loan_application

      def create_application
        self.loan_application = LoanApplication.create(inputs)
      end

      def create_loan_file
        self.loan_file = LoanFile.create(loan_application:)
      end
    end
  end
end
