module FoobaraDemo
  module LoanOrigination
    class CreditPolicy < Foobara::Entity
      attributes do
        id :integer
        institutional_investor_name :string, :required
        minimum_credit_score :integer, :required
        credit_score_to_use :symbol,
                            :required,
                            one_of: [:median, :maximum],
                            description: "If the scores are 500, 650, and 700, then " \
                                         ":maximum will use 700 and :median will use 650"
        required_pay_stub_quantity :integer, :required
      end

      primary_key :id
    end
  end
end
