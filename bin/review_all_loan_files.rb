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
    class ReviewAllLoanFilesNeedingReview < Foobara::AgentBackedCommand
      description "Checks each LoanFile against all requirements in its CreditPolicy. " \
                  "Denies each LoanFile that has any unsatisfied requirements."

      result do
        approved [LoanFile], :required
        denied [LoanFile], :required
      end

      depends_on FindALoanFileThatNeedsReview,
                 StartUnderwriterReview,
                 FindCreditPolicy,
                 ApproveLoanFile,
                 DenyLoanFile

      verbose
      # works:
      llm_model "claude-3-7-sonnet-20250219"
      # llm_model "chatgpt-4o-latest"
      # llm_model "claude-opus-4-20250514"
      # llm_model "claude-sonnet-4-20250514"
      # llm_model "gpt-4o"
      # llm_model "o1"
      # llm_model "claude-3-5-sonnet-20241022"
      # llm_model "claude-3-opus-20240229"
      # llm_model "gpt-4"
      # llm_model "gpt-4.1"

      # Does not work: Only processes the first loan file.
      # Rerunning it to hit all loan files, it incorrectly approves Basil
      # llm_model "gpt-4-turbo"
      # Does not work: incorrectly denies Fumiko, gives wrong reasons for Basil
      # llm_model "claude-3-5-haiku-20241022"
      # Does not work: gave up couldn't give proper command and inputs
      # llm_model "gpt-3.5-turbo"
      # Does not work: only processes the first loan file
      # Rerunning it to hit all loans, it gives wrong reasons for Basil but gets Fumiko right
      # llm_model "claude-3-sonnet-20240229"
      # Does not work: only processes the first loan file and incorrectly approves it
      # llm_model "claude-3-haiku-20240307"

      # Does not work: does not fetch the credit policy, incorrectly approves it, and only processes the first loan
      # llm_model "deepseek-r1:70b"
      # llm_model "deepseek-r1:32b"

      # TODO: fix this! gives a 400 likely due to temperature?
      # llm_model "o1-mini"
      # llm_model "o3-mini"
      # llm_model "o3-mini-2025-01-31"
      # llm_model "o4-mini"
    end
  end
end

outcome = FoobaraDemo::LoanOrigination::ReviewAllLoanFilesNeedingReview.run

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
