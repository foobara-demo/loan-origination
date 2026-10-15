require_relative "errors/cannot_transition_state_error"

module FoobaraDemo
  module LoanOrigination
    class StartUnderwriterReview < Foobara::Command
      possible_input_error :loan_file, CannotTransitionStateError

      inputs do
        loan_file LoanFile, :required
      end

      def execute
        transition_loan_file

        nil
      end

      def validate
        unless loan_file.state_machine.can?(transition)
          add_input_error CannotTransitionStateError.new(loan_file, attempted_transition: transition, path: :loan_file)
        end
      end

      def transition
        :start_review
      end

      def transition_loan_file
        loan_file.state_machine.perform_transition!(transition)
      end
    end
  end
end
