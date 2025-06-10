# Kodelet Action - Context File

## Project Overview
GitHub Action that automates software engineering tasks using Kodelet AI. Enables background execution for issue resolution, PR reviews, and code improvements triggered by GitHub events.

## Tech Stack
- **Type**: GitHub Composite Action (Shell + YAML)
- **Runtime**: Ubuntu Linux (GitHub Actions runner)
- **Dependencies**: Kodelet CLI, GitHub CLI (gh), Git

## Project Structure
```
.
├── action.yml                    # Main action definition
├── README.md                     # Documentation
├── LICENSE                       # MIT License
├── Makefile                      # Common development tasks
├── examples/basic-workflow.yml   # Example usage
└── .github/workflows/
    ├── test.yml                  # CI testing
    └── release.yml               # Release automation
```

## Key Components

### action.yml
Main action with inputs: `anthropic-api-key`, `github-token`, `auth-gateway-endpoint`, `commenter`, `event-name`, `issue-number`, `comment-id`, `review-id`, `is-pr`
Steps: Auth resolution → Status comment → Install Kodelet → Configure Git → Run Kodelet → Error handling

### Authentication
Uses Auth Gateway by default for enhanced GitHub token with better trigger capabilities and `kodelet` user context. Falls back to provided `github-token` if specified. Requires `id-token: write` permission for OIDC authentication.

### Event Handling
- `issue_comment`: Comments on issues → `kodelet issue-resolve --issue-url`
- `issue_comment` (on PR): Comments on PRs → `kodelet pr-respond --pr-url --issue-comment-id`
- `pull_request_review_comment`: Inline PR comments → `kodelet pr-respond --pr-url --review-id`
- `pull_request_review`: PR review submissions → `kodelet pr-respond --pr-url --review-id`

## Security & Permissions
```yaml
permissions:
  id-token: write        # Auth gateway OIDC authentication
  issues: write          # Comment on issues
  pull-requests: write   # Comment on PRs
  contents: write        # Push commits and create branches
```

### Environment Variables
- `ANTHROPIC_API_KEY`: Required for Kodelet AI
- `GITHUB_TOKEN`: GitHub API access (via auth gateway or provided token)
- `KODELET_LOG_LEVEL`: Optional (debug, info, warn, error)
- `RESOLVED_GITHUB_TOKEN`: Internal environment variable for resolved token

## Configuration
- **Timeout**: Default 15min, max 360min
- **Versioning**: `latest`, `v0.1.7-alpha`

## Coding Conventions
- **YAML**: Single quotes, 2-space indent, descriptive step names
- **Shell**: Bash explicitly, error handling, input validation
- **Git**: Auto-config from GitHub user, noreply email, full clone (fetch-depth: 0)

## Deployment
- Semantic versioning (v1.2.3)
- Major version tags (v1) → latest patch
- Matrix testing for event scenarios

## Common Issues
- **Timeout**: Increase `timeout-minutes`, check API limits
- **Permissions**: Verify repo permissions, token scope, commenter access
- **Git Config**: Check user email, git config logs, full clone

## Development Notes
- Kodelet CLI installed fresh each run (no caching)
- Action runs in isolated Ubuntu environment
- Error handling posts informative comments to issues/PRs
- Git configuration is ephemeral (per-run)
