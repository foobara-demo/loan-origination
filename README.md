# A demo LoanOrigination domain

This is just a random LoanOrigination domain I made for demos/experiments, in particular to experiment
with Foobara::Agent and Foobara::AgentBackedCommand.

## Installation

Typical stuff: add `gem "foobara-demo-loan-origination"` to your Gemfile or .gemspec file. Or even just
`gem install foobara-demo-loan-origination` if just playing with it directly in scripts.

## Playing with the demo scripts

The demo scripts are currently in bin/ but should be moved to something like example_scripts/
or experiments/.

You can `cd bin` and `bundle install`. Then, you can set up the services you wish to use
(either foobara-ollama-api, foobara-open-ai-api, or anthropic-api)
by setting the relevant environment variable values in .env.development.test (or copy it to
.env.development.test.local first.)

Some example commands for running some of these files from `bin/`...

To set up demo data:

```
./prepare-loan-records
```

To see a slice of demo data:

```
$ ./loan-origination GenerateLoanFilesReport
```

To review all loans with one line of added Ruby code:

```
$ ./loan-origination-add-abc-one-liner ReviewAllLoanFilesThatNeedReview --agent-options-verbose --llm-model gpt-4o
```

You can pass `--help` to the above to see available options.

To run a script that runs 1 AgentBackedCommand and uses its outcome programmatically:

```
$ ./review_all_loan_files.rb
```

To run a script that uses two AgentBackedCommands and uses the outcome programmatically:

```
$ ./review_all_loan_files_two_agents.rb
```

The above two scripts can have their behavior changed by editing the files. See the comments in those files.

## Contributing

Bug reports and pull requests are welcome on GitHub
at https://github.com/foobara-demo/loan-origination

## License

This project is licensed under the MPL-2.0 license. Please see LICENSE.txt for more info.
