module FoobaraDemo
  module LoanOrigination
    class LoanFile < Foobara::Entity
      State = Foobara::Enumerated.make_module(LoanFile::StateMachine.states)
    end

    foobara_register_type(:token_state, :symbol, one_of: Types::Token::State)
  end
end
