module FoobaraDemo
  module LoanOrigination
    class LoanFile < Foobara::Entity
      attributes do
        id :integer
        loan_application LoanApplication, :required
        state :state, :required
        pay_stubs [PayStub], :required, default: []
        credit_scores [CreditScore], :required, default: []
        underwriter_decision UnderwriterDecision, :allow_nil
      end

      primary_key :id
    end

    def state_machine
      @state_machine ||= StateMachine.new(owner: self, target_attribute: :state)
    end
  end
end
