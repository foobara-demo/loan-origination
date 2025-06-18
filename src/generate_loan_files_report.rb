require_relative "find_all_loan_files"

module FoobaraDemo
  module LoanOrigination
    class GenerateLoanFilesReport < Foobara::Command
      result [
        {
          id: :integer,
          applicant: :string,
          state: :string,
          underwriter_decision: LoanFile::UnderwriterDecision
        }
      ]

      depends_on FindAllLoanFiles

      def execute
        load_all_loan_files
        generate_report

        report
      end

      attr_accessor :loan_files, :report

      def load_all_loan_files
        self.loan_files = run_subcommand!(FindAllLoanFiles)
      end

      def generate_report
        self.report = loan_files.map do |loan_file|
          underwriter_decision = loan_file.underwriter_decision

          report = {
            id: loan_file.id,
            applicant: loan_file.loan_application.applicant.name,
            state: loan_file.state
          }

          if underwriter_decision
            report[:underwriter_decision] = underwriter_decision.attributes
          end

          report
        end
      end
    end
  end
end
