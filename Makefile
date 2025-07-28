# Variables
SAMPLE_DATA ?= 100
RAILS_ENV ?= development
PORT ?= 3000

# Default target
.PHONY: all
all: install db-setup run

# Install dependencies
.PHONY: install
install:
	brew install postgresql@16
	brew services start postgresql@16
	brew install redis
	brew services start redis
	brew install k6
	bundle install

# Run database migrations
.PHONY: db-migrate
db-migrate:
	RAILS_ENV=$(RAILS_ENV) bundle exec rails db:migrate

# Set up database (create and migrate)
.PHONY: db-setup
db-setup:
	RAILS_ENV=$(RAILS_ENV) SAMPLE_DATA=$(SAMPLE_DATA) bundle exec rails db:setup

# Run the Rails server
.PHONY: run
run:
	bin/dev

# Run load test
.PHONY: test-load
test-load:
	RAILS_ENV=test bundle install
	RAILS_ENV=test bundle exec rails db:create
	RAILS_ENV=test bundle exec rails db:migrate
	RAILS_ENV=test SAMPLE_DATA=$(SAMPLE_DATA)  bundle exec rails db:seed
	RAILS_ENV=test bundle exec rake db:mongoid:create_indexes
	RAILS_ENV=test bundle exec rails server &
	sleep 3
	clear
	k6 run spec/load/requests_test.js
	sleep 3
	pkill -f 'puma'
	sleep 3
	RAILS_ENV=test bundle exec rails db:drop

# Run load test with warm cache
.PHONY: warm-test-load
warm-test-load:
	RAILS_ENV=test bundle install
	RAILS_ENV=test bundle exec rails db:create
	RAILS_ENV=test bundle exec rails db:migrate
	RAILS_ENV=test SAMPLE_DATA=$(SAMPLE_DATA)  bundle exec rails db:seed
	RAILS_ENV=test bundle exec rails runner bin/warm_cache.rb
	RAILS_ENV=test bundle exec rails server &
	sleep 3
	clear
	k6 run spec/load/requests_test.js
	sleep 3
	pkill -f 'puma'
	sleep 3
	RAILS_ENV=test bundle exec rails db:drop

# Run RSpec tests
.PHONY: seed
seed:
	RAILS_ENV=$(RAILS_ENV) SAMPLE_DATA=$(SAMPLE_DATA) bundle exec rails db:seed

# Run RSpec tests
.PHONY: test
test:
	bundle exec rspec

# Clean up generated files
.PHONY: clean
clean:
	rm -rf tmp/*
	rm -rf log/*.log

# Run console
.PHONY: console
console:
	RAILS_ENV=$(RAILS_ENV) bundle exec rails console

# Run linter
.PHONY: lint
lint:
	bundle exec rubocop

# Run linter with auto-correction
.PHONY: lint-fix
lint-fix:
	bundle exec rubocop -A

# Run all checks (tests and lint)
.PHONY: check
check: test lint

# Stop the server
.PHONY: stop
stop:
	pkill -f 'puma'

# Restart the server
.PHONY: restart
restart: stop run

# View logs
.PHONY: logs
logs:
	tail -f log/$(RAILS_ENV).log

# Help command to display available targets
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all         	- Install dependencies and run the server"
	@echo "  install     	- Install dependencies (requires Homebrew and Ruby already present)"
	@echo "  db-migrate  	- Run database migrations"
	@echo "  db-setup    	- Create and migrate database"
	@echo "  run         	- Start Rails server"
	@echo "  test        	- Run tests"
	@echo "  test-load   	- Runs load test (SAMPLE_DATA number of events)"
	@echo "  warm-test-load - Warms cache then runs load test (SAMPLE_DATA number of events)"
	@echo "  seed   	 	- Generate seed data (SAMPLE_DATA number of events)"
	@echo "  clean       	- Remove temporary files and logs"
	@echo "  console     	- Start Rails console"
	@echo "  lint        	- Run RuboCop linter"
	@echo "  lint-fix    	- Run RuboCop with auto-correction"
	@echo "  check       	- Run tests and linter"
	@echo "  stop        	- Stop Rails server"
	@echo "  restart     	- Restart Rails server"
	@echo "  logs        	- Tail the application logs"
	@echo "  help        	- Display this help message"
	@echo ""
	@echo "Variables:"
	@echo "  SAMPLE_DATA - Set the number of seed events to create (default: 30)"
	@echo "  RAILS_ENV   - Set the Rails environment (default: development)"
	@echo "  PORT        - Set the server port (default: 3000)"