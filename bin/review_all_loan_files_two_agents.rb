#!/usr/bin/env ruby

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("./Gemfile", __dir__)
require "bundler/setup"

# add your keys/urls to .env or set them some other way and delete these two lines
require "foobara/load_dotenv"
Foobara::LoadDotenv.run!(dir: __dir__)

require "foobara/anthropic_api" if ENV.key?("ANTHROPIC_API_KEY")
require "foobara/open_ai_api" if ENV.key?("OPENAI_API_KEY")
# require "foobara/ollama_api" if ENV.key?("OLLAMA_API_URL")

require "foobara/sh_cli_connector"
require "foobara/agent_backed_command"

require_relative "../boot"

module FoobaraDemo
  module LoanOrigination
    class UnderwriterSummary < Foobara::Model
      attributes do
        loan_file_id :integer, :required
        pay_stub_count :integer, :required
        fico_scores [:integer, :integer, :integer], :required
        credit_policy CreditPolicy, :required
      end
    end

    class ReviewLoanFile < Foobara::AgentBackedCommand
      description "Starts the LoanFile's review, then checks all requirements of its " \
                  "CreditPolicy and approves it if and only if all requirements are met. Otherwise denies it."

      inputs UnderwriterSummary
      # result LoanFile::UnderwriterDecision

      depends_on StartUnderwriterReview,
                 FindCreditPolicy,
                 DenyLoanFile,
                 ApproveLoanFile

      verbose
      agent_name "Inner"
      # pass_aggregates_to_llm
    end

    class ReviewAllLoanFiles < Foobara::AgentBackedCommand
      description "Reviews all LoanFiles that need review."

      result do
        approved [LoanFile], :required
        denied [LoanFile], :required
      end

      depends_on FindALoanFileThatNeedsReview,
                 ReviewLoanFile,
                 FindLoanFile
      verbose
      agent_name "Outer"
      llm_model "gpt-4"
    end
  end
end

outcome = FoobaraDemo::LoanOrigination::ReviewAllLoanFiles.run

if outcome.success?
  result = outcome.result

  puts
  puts "Great success!!"
  puts

  approved = result[:approved]
  denied = result[:denied]

  approved.each do |loan_file|
    puts "Approved: #{loan_file.loan_application.applicant.name}"
  end

  denied.each do |loan_file|
    puts "Denied: #{loan_file.loan_application.applicant.name} " \
         "(#{loan_file.underwriter_decision.denied_reasons.join(", ")})"
  end
else
  warn "Error: #{outcome.errors_hash}"
end
