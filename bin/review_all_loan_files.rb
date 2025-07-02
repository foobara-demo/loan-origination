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
      description "Checks each LoanFile all requirements in its CreditPolicy. " \
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
