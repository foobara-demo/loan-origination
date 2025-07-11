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

raise "this doesn't work at all! Maybe debug this when there's time?"
# :nocov:
module FoobaraDemo
  module LoanOrigination
    class ReviewLoanFile < Foobara::AgentBackedCommand
      description "Denies the LoanFile if its CreditPolicy has any unmet requirements. Otherwise approves it."

      add_inputs do
        loan_file LoanFile, :required
      end

      # result LoanFile::UnderwriterDecision

      depends_on StartUnderwriterReview,
                 # FindCreditPolicy,
                 DenyLoanFile,
                 ApproveLoanFile

      verbose
      pass_aggregates_to_llm
      # works:
      llm_model "claude-opus-4-20250514"
      # llm_model "o1"

      # Does not seem to work... doesn't return proper json for denying a loan.
      # llm_model "deepseek-r1:70b"
      # Does not work: incorrectly denies Fumiko's loan file.
      # llm_model "claude-sonnet-4-20250514"
      # Incorrectly denies Fumiko
      # llm_model "claude-3-7-sonnet-20250219"
      # Incorrectly denies Fumiko, incorrectly approves Basil
      # llm_model "gpt-4o"

      # llm_model "qwen3:8b"
      # llm_model "gpt-4o-mini"
    end

    class ReviewAllLoanFilesNeedingReview < Foobara::Command
      description "Reviews all LoanFiles that need review."

      depends_on FindALoanFileThatNeedsReview,
                 ReviewLoanFile

      def execute
        each_loan_file_that_needs_review do
          review_loan_file_async
        end

        wait_for_all_reviews
        raise_if_any_failed

        nil
      end

      attr_accessor :loan_file

      def each_loan_file_that_needs_review
        loop do
          self.loan_file = run_subcommand!(FindALoanFileThatNeedsReview)
          break unless loan_file

          yield
        end
      end

      def threads
        @threads ||= []
      end

      def review_loan_file_async
        threads << Thread.new do
          LoanFile.transaction(mode: :open_new) do
            ReviewLoanFile.run(loan_file: loan_file.id)
          end
        end
      end

      def wait_for_all_reviews
        threads.join
      end

      def raise_if_any_failed
        threads.each do |thread|
          outcome = thread.value
          outcome.raise!
        end
      end
      # works:
      # llm_model "claude-sonnet-4-20250514"
      # llm_model "claude-opus-4-20250514"

      # Does not work: can't construct the proper inputs to ReviewLoanFile for some reason
      # llm_model "deepseek-r1:70b"

      # llm_model "claude-3-7-sonnet-20250219"
      # llm_model "gpt-4o"
      # llm_model "qwen3:8b"
      # llm_model "gpt-4o-mini"

      # llm_model "o1"
    end
  end
end

outcome = FoobaraDemo::LoanOrigination::ReviewAllLoanFilesNeedingReview.run

if outcome.success?
  puts
  puts "Great success!!"
  puts
else
  warn "Error: #{outcome.errors_hash}"
end
# :nocov:
