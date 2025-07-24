#!/usr/bin/env ruby

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("./Gemfile", __dir__)
require "bundler/setup"

# add your keys/urls to .env or set them some other way and delete these two lines
require "foobara/load_dotenv"
Foobara::LoadDotenv.run!(dir: __dir__)

require "foobara/anthropic_api" if ENV.key?("ANTHROPIC_API_KEY")
require "foobara/open_ai_api" if ENV.key?("OPENAI_API_KEY")
require "foobara/ollama_api" if ENV.key?("OLLAMA_API_URL")

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
      # inputs do
      #   loan_file LoanFile, :required
      # end
      result LoanFile::UnderwriterDecision

      depends_on StartUnderwriterReview,
                 FindCreditPolicy,
                 DenyLoanFile,
                 ApproveLoanFile

      verbose
      agent_name "Inner"
      # pass_aggregates_to_llm

      # llm_model  "qwen3:32b" # works!
      # llm_model "qwen3:14b" # wooooooooow this works!
      llm_model "qwen3:8b" # woooooooooooooooooooooow this works!! how??
      # llm_model "qwen3:4b"

      # llm_model "gpt-4"

      # llm_model  "claude-3-7-sonnet-20250219"
      # llm_model  "claude-sonnet-4-20250514"
      # llm_model  "claude-opus-4-20250514"
      # llm_model  "o1"
      # llm_model  "o3-mini"

      # llm_model  "gpt-4o"
    end

    class ReviewAllLoanFiles < Foobara::AgentBackedCommand
      description "Reviews all LoanFiles that need review."

      result do
        approved [LoanFile], :required
        denied [LoanFile], :required
      end

      depends_on FindALoanFileThatNeedsReview,
                 ReviewLoanFile # ,
      # FindLoanFile
      verbose
      agent_name "Outer"
      # llm_model "gpt-4"
      llm_model "qwen3:14b" # this works!
      # llm_model "qwen3:32b" # almost works... if running twice then it works,
      # but if running only once stops processing records after the first two

      # llm_model  "claude-3-7-sonnet-20250219"
      # llm_model  "claude-sonnet-4-20250514"
      # llm_model  "claude-opus-4-20250514"
      # llm_model  "o1"
      # llm_model  "o3-mini"

      # llm_model  "gpt-4o"
      # llm_model  "qwen3:14b"
      # llm_model  "qwen3:8b"
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
