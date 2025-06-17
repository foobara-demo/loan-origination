module FoobaraDemo
  module LoanOrigination
    class AddPayStub < Foobara::Command
      inputs do
        loan_file LoanFile, :required
        pay_stub PayStub, :required
      end
      result LoanFile

      def execute
        add_pay_stub_to_loan_file
        loan_file
      end

      def add_pay_stub_to_loan_file
        loan_file.pay_stubs.append(pay_stub)
      end
    end
  end
end
