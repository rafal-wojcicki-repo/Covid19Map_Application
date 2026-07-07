# AGENT.md

## Purpose

This file defines how AI agents and developers should work in this repository.  
Follow these instructions before making code changes, running commands, or opening pull requests.

## Project Context

This project is a production-oriented software system. Prioritize correctness, maintainability, security, and clear communication over quick fixes.

When working in this repository:

- Understand the existing architecture before changing behavior.
- Prefer small, focused changes over broad rewrites.
- Preserve existing public APIs unless explicitly asked to change them.
- Avoid introducing unnecessary dependencies.
- Keep security, observability, and testability in mind.

## Working Principles

### Make minimal, safe changes

- Change only what is necessary to solve the task.
- Do not refactor unrelated code.
- Do not rename files, classes, functions, or APIs unless required.
- Do not change formatting across large files unless formatting is the explicit task.

### Respect existing conventions

Before writing new code, inspect nearby files and follow:

- Naming conventions
- Folder structure
- Error handling style
- Logging style
- Testing patterns
- Dependency injection patterns
- Configuration patterns

Consistency with the current codebase is more important than personal preference.

### Ask when requirements are unclear

If the task is ambiguous, ask for clarification before implementing.  
Do not guess business rules, security requirements, or API contracts.

Examples of unclear requirements:

- Missing expected behavior
- Undefined edge cases
- Conflicting existing behavior
- Unclear ownership of a module
- Potential breaking API changes

## Development Workflow

### Before making changes

1. Read the relevant files.
2. Identify the smallest safe implementation path.
3. Check existing tests for related behavior.
4. Confirm whether similar patterns already exist in the codebase.

### During implementation

- Keep changes focused on the requested task.
- Prefer readable code over clever code.
- Add comments only when they explain non-obvious reasoning.
- Avoid dead code, unused imports, and temporary debug output.
- Do not commit secrets, credentials, tokens, private keys, or personal data.

### After implementation

Run the most relevant checks available in the project.

Suggested order:

1. Unit tests for changed code
2. Integration tests if behavior crosses module boundaries
3. Linting or formatting checks
4. Type checks or build verification
5. Manual verification if automated coverage is missing

If some checks cannot be run, explain why.

## Testing Guidelines

Every behavior change should include or update tests unless there is a clear reason not to.

Tests should cover:

- Normal expected behavior
- Edge cases
- Failure paths
- Security-sensitive behavior
- Regression scenarios for bug fixes

Prefer tests that validate behavior rather than implementation details.

Do not remove or weaken tests unless the requirement changed and the reason is documented.

## Security Guidelines

Security must be considered for every change.

Never:

- Log secrets, passwords, tokens, session IDs, or personal data
- Hardcode credentials
- Disable authentication or authorization checks
- Bypass validation without a documented reason
- Introduce unsafe deserialization
- Ignore user input sanitization
- Weaken TLS, encryption, or permission checks

When handling user input:

- Validate input at boundaries
- Fail safely
- Return safe error messages
- Avoid exposing internal implementation details

## Error Handling

Use the project’s existing error handling style.

Good error handling should:

- Provide enough context for debugging
- Avoid leaking sensitive information
- Preserve original causes where useful
- Use appropriate error types or status codes
- Be testable

Do not silently swallow exceptions unless the behavior is intentional and documented.

## Logging and Observability

Follow existing logging conventions.

Logs should be useful for operations and debugging, but must not expose sensitive data.

Prefer structured logs where the project already uses them.

For important workflows, consider whether metrics, traces, or audit logs are needed.

## Dependencies

Before adding a dependency, check whether the project already has a suitable tool or library.

Only add dependencies when they are justified by:

- Clear functionality need
- Active maintenance
- Reasonable license
- Security posture
- Low complexity cost

Avoid large dependencies for small utilities.

## API and Contract Changes

Be careful with changes to:

- Public APIs
- Database schemas
- Event formats
- Configuration keys
- CLI arguments
- External integrations
- Authentication or authorization behavior

If a change is breaking, document it clearly and include migration notes if needed.

## Database and Migration Rules

For database changes:

- Prefer backward-compatible migrations.
- Avoid destructive changes unless explicitly approved.
- Include rollback considerations where possible.
- Keep schema changes separate from unrelated logic changes.
- Consider production data volume and migration runtime.

## Configuration Rules

Do not hardcode environment-specific values.

Use the existing configuration mechanism for:

- URLs
- Credentials
- Feature flags
- Timeouts
- Limits
- Environment-specific behavior

Document any new required configuration.

## Pull Request Expectations

A good pull request should include:

- Clear summary of what changed
- Reason for the change
- Tests added or updated
- Checks run locally
- Known limitations or follow-ups
- Screenshots or examples if UI/API behavior changed

Use this structure:

```md
## Summary

- ...

## Why

- ...

## Changes

- ...

## Testing

- ...

## Notes

- ...
```

## Commit Guidelines

Use clear, meaningful commit messages.

Preferred format:

```text
type(scope): short description
```

Examples:

```text
fix(auth): handle expired refresh tokens
feat(api): add pagination to user endpoint
test(payments): cover failed authorization flow
refactor(config): simplify environment loading
```

## Code Style

Follow the formatter, linter, and style rules already configured in the repository.

Do not introduce a new style system unless explicitly requested.

If no formatter exists, match the surrounding code style.

## Documentation

Update documentation when changing:

- Setup steps
- Configuration
- Public APIs
- Operational behavior
- Security assumptions
- Developer workflows

Documentation should be accurate, concise, and close to the code it describes.

## AI Agent Specific Instructions

When acting as an AI coding agent:

1. Do not make assumptions about business logic.
2. Do not perform broad rewrites unless explicitly requested.
3. Do not modify unrelated files.
4. Do not remove tests to make the build pass.
5. Do not invent APIs, services, or configuration that do not exist.
6. Do not claim tests passed unless they were actually run.
7. If blocked, explain the blocker and suggest the next best step.
8. Prefer a working, simple solution over an over-engineered one.
9. Keep the final response concise and include changed files, tests run, and remaining risks.

## Final Response Format for AI Agents

After completing a task, respond with:

```md
## What changed

- ...

## Tests run

- ...

## Notes

- ...
```

If no tests were run, say so explicitly and explain why.

## Non-Goals

Do not do the following unless explicitly requested:

- Large-scale refactoring
- Dependency upgrades
- Framework migrations
- Formatting-only changes across the repository
- Performance rewrites without benchmarks
- Security model changes
- Public API changes
- Database destructive migrations

## Priority Order

When instructions conflict, follow this priority:

1. Explicit user request
2. Security and data safety
3. Existing repository conventions
4. This AGENT.md file
5. General best practices