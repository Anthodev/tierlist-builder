set dotenv-load

alias bd := build
alias u := up
alias s := stop
alias rp := reset-permissions

alias start := setup-project

# Development aliases
alias d := dev
alias t := test
alias tw := test-watch
alias tc := test-coverage
alias l := lint
alias lf := lint-fix
alias f := format
alias fc := format-check
alias tsc := type-check
alias q := quality
alias ud := up-dev

container-name := "tierlist-builder-app-1"
docker-running := `docker ps -q --filter name=tierlist-builder-app-1 | grep -q . && echo true || echo false`

d := if docker-running == "true" { "docker exec -t " + container-name } else { "" }
shell := if docker-running == "true" { "docker exec -t " + container-name } else { "" }

default:
  just --list

#---------- Docker management ----------
setup-project:
  @echo "Building and starting the project..."
  just bd
  just u
  just rp
  @echo "Project is ready!"
  @echo "You can now access the project at https://localhost"

build:
  docker compose build --no-cache

up:
  docker compose up -d

up-dev:
  APP_PORT=3000 docker compose --profile local-storage --profile cache up -d

down:
  docker compose down --remove-orphans

stop:
  docker compose stop

prune:
  docker compose down --remove-orphans
  docker compose down --volumes
  docker compose rm -f

reset-permissions:
  sudo chown -Rf $(id -u):$(id -g) ./

#---------- Container commands ----------
sh:
  @docker exec -it tierlist-builder-app-1 sh

#---------- Development commands ----------
# Start development server
dev:
  {{ d }} bun --hot index.html

# Build the project for production
build-app:
  {{ d }} bun build src/index.tsx --outdir=dist --target=browser --minify

# Run tests
test:
  {{ d }} bun test

# Run tests in watch mode
test-watch:
  {{ d }} bun run test:watch

# Run tests with coverage
test-coverage:
  {{ d }} bun run test:coverage

# Lint the codebase
lint:
  {{ d }} bun run lint

# Lint and fix issues
lint-fix:
  {{ d }} bun run lint:fix

# Format code
format:
  {{ d }} bun run format

# Check code formatting
format-check:
  {{ d }} bun run format:check

# Type check
type-check:
  {{ d }} bun run type-check

# Run all quality checks (lint, format check, type check)
quality:
  {{ d }} bun run quality

# Install dependencies
install:
  {{ d }} bun install

# Update dependencies
update:
  {{ d }} bun update

# Clean node_modules and reinstall
clean-install:
  {{ d }} rm -rf node_modules
  {{ d }} bun install
