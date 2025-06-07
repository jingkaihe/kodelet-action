# Kodelet Action

[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/jingkaihe/kodelet-action)](https://github.com/jingkaihe/kodelet-action/releases)
[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-Kodelet%20Action-blue.svg?colorA=24292e&colorB=0366d6&style=flat&longCache=true&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAM6wAADOsB5dZE0gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAERSURBVCiRhZG/SsMxFEZPfsVJ61jbxaF0cRQRcRJ9hlYn30IHN/+9iquDCOIsblIrOjqKgy5aKoJQj4n3EllCLx9AuAkfOScdtNwJZdH+fKGiMEhiFCeAJ+JPWBa8AADBSOA8gNFSKYR8H6AAD5KM8HFw/YJJpJaUKJhANSRBQ1EY0rQr4dMZPKwZLLqA2k8y5nHEPW2hL9P4pYgHuNzQASi7/OcJwrHQlJ3I1hQh0Y6J2V0K04UHMcOKoIJSojM/JUKKyBwb8kRcnGPKJOSfDGpL1XYAAAAASUVORK5CYII=)](https://github.com/marketplace/actions/kodelet-action)

A GitHub Action that automates software engineering tasks using Kodelet AI. This action enables background execution of Kodelet for issue resolution, pull request reviews, and code improvements triggered by GitHub events.

## Features

* 🤖 **AI-Powered Engineering**: Automates software engineering tasks using advanced AI models
* 📝 **Issue Resolution**: Automatically resolves GitHub issues with code changes and explanations
* 🔍 **PR Reviews**: Provides intelligent code review comments and suggestions
* ⚡ **Background Processing**: Runs asynchronously without blocking your development workflow
* 🔄 **Multi-Event Support**: Works with issue comments, PR comments, and review comments
* 🛡️ **Secure**: Uses GitHub tokens and API keys securely through GitHub Secrets

## Quick Start

### 1. Setup API Key

Add your Anthropic API key to your repository secrets:

1. Go to your repository → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `ANTHROPIC_API_KEY`
4. Value: Your Anthropic API key (starts with `sk-ant-`)

### 2. Create Workflow File

Create `.github/workflows/kodelet.yml` in your repository:

```yaml
name: Background Kodelet
on:
  issue_comment:
    types: [created]
  issues:
    types: [opened, assigned]
  pull_request_review_comment:
    types: [created]
  pull_request_review:
    types: [submitted]

permissions:
  issues: write
  pull-requests: write
  contents: write

jobs:
  background-agent:
    runs-on: ubuntu-latest
    timeout-minutes: 15  # 15 minutes
    if: |
      (
        (github.event_name == 'issues' && contains(github.event.issue.body, '@kodelet')) ||
        (github.event_name == 'issue_comment' && contains(github.event.comment.body, '@kodelet')) ||
        (github.event_name == 'pull_request_review_comment' && contains(github.event.comment.body, '@kodelet')) ||
        (github.event_name == 'pull_request_review' && contains(github.event.review.body, '@kodelet'))
      ) &&
      (
        (github.event.issue.author_association == 'OWNER' || github.event.issue.author_association == 'MEMBER' || github.event.issue.author_association == 'COLLABORATOR') ||
        (github.event.comment.author_association == 'OWNER' || github.event.comment.author_association == 'MEMBER' || github.event.comment.author_association == 'COLLABORATOR') ||
        (github.event.review.author_association == 'OWNER' || github.event.review.author_association == 'MEMBER' || github.event.review.author_association == 'COLLABORATOR')
      )

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
      - name: Setup your dev environment
        run: |
          echo "YMMV"
      - name: Run Kodelet
        uses: jingkaihe/kodelet-action@v0.1.4-alpha
        with:
          anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
          # All other inputs are automatically populated from GitHub context
```

### 3. Trigger Kodelet

Comment `@kodelet` on any issue or pull request to trigger automated assistance:

- **Issues**: `@kodelet please fix this bug`
- **PRs**: `@kodelet review this code`
- **PR Reviews**: Include `@kodelet` in review comments

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `anthropic-api-key` | Anthropic API key for Kodelet | ✅ | |
| `github-token` | GitHub token for repository operations | ❌ | `${{ github.token }}` |
| `commenter` | Username who triggered the action | ❌ | Auto-detected from event |
| `event-name` | GitHub event name | ❌ | `${{ github.event_name }}` |
| `issue-number` | Issue or PR number | ❌ | Auto-detected from event |
| `comment-id` | Comment ID (for issue comments on PRs) | ❌ | Auto-detected from event |
| `review-id` | Review ID (for PR review comments) | ❌ | Auto-detected from event |
| `repository` | Repository in format owner/repo | ❌ | `${{ github.repository }}` |
| `is-pr` | Whether this is a pull request | ❌ | Auto-detected from event |
| `pr-number` | Pull request number | ❌ | Auto-detected from event |
| `timeout-minutes` | Timeout for execution in minutes | ❌ | `15` |
| `log-level` | Log level (debug, info, warn, error) | ❌ | `info` |
| `kodelet-version` | Kodelet version to install (e.g., v0.0.35.alpha, latest) | ❌ | `latest` |
| `env` | Additional environment variables as JSON object | ❌ | `{}` |

## Usage Examples

### Basic Usage (Minimal Configuration)

```yaml
- uses: jingkaihe/kodelet-action@v0.1.4-alpha
  with:
    anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
    # All other inputs are automatically populated from GitHub context
```

### Custom Configuration

```yaml
- uses: jingkaihe/kodelet-action@v0.1.4-alpha
  with:
    anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
    timeout-minutes: 180  # 3 hours
    log-level: debug
    kodelet-version: v0.0.35.alpha  # Pin to specific version
```

### Manual Override (if needed)

```yaml
- uses: jingkaihe/kodelet-action@v0.1.4-alpha
  with:
    anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
    # Override any auto-detected values if needed:
    commenter: custom-user
    event-name: issue_comment
    issue-number: 123
    repository: owner/repo
    is-pr: false
```

### Environment Variables

You can pass additional environment variables to Kodelet:

```yaml
- uses: jingkaihe/kodelet-action@v0.1.4-alpha
  with:
    anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
    env: |
      {
        "DATABASE_URL": "${{ secrets.DATABASE_URL }}",
        "API_BASE_URL": "https://api.example.com",
        "DEBUG_MODE": "true"
      }
```

The `env` input accepts a JSON object as a string where each key-value pair becomes an environment variable available to Kodelet during execution.

### Version Pinning

You can control which version of Kodelet is installed:

```yaml
# Use latest release (default)
- uses: jingkaihe/kodelet-action@v0.1.4-alpha
  with:
    kodelet-version: latest

# Pin to specific version
- uses: jingkaihe/kodelet-action@v0.1.4-alpha
  with:
    kodelet-version: 0.0.35.alpha
```

**Recommended approaches:**
- **Production**: Pin to a specific stable version for consistency
- **Development**: Use `latest` to get the newest features
- **Testing**: Pin to specific versions to ensure reproducible results

## Permissions

The action requires the following GitHub permissions:

```yaml
permissions:
  issues: write          # Comment on issues
  pull-requests: write   # Comment on PRs
  contents: write        # Push commits and create branches
```

## Security

- **API Keys**: Store your Anthropic API key in GitHub Secrets
- **GitHub Token**: Uses the automatically provided `GITHUB_TOKEN`
- **Repository Access**: Only maintainers/collaborators can trigger the action
- **Timeout Protection**: Execution is limited by configurable timeout

## Supported Events

| Event | Description | Kodelet Command |
|-------|-------------|-----------------|
| `issue_comment` | Comments on issues | `kodelet resolve --issue-url` |
| `issue_comment` (on PR) | Comments on pull requests | `kodelet pr-respond --pr-url --issue-comment-id` |
| `pull_request_review_comment` | Inline PR review comments | `kodelet pr-respond --pr-url --review-id` |
| `pull_request_review` | PR review submissions | `kodelet pr-respond --pr-url --review-id` |

## Error Handling

The action automatically handles errors and posts informative comments when execution fails:

- API rate limits or service unavailability
- Complex requirements needing human intervention
- Environmental or dependency issues
- Timeout exceeded

Failed runs include links to workflow logs for debugging.

## Versioning

This action follows semantic versioning:

- **Latest stable**: `@v0`
- **Specific version**: `@v0.1.4-alpha`
- **Development**: `@main` (not recommended for production)

## Development

### Testing Locally

```bash
# Clone the repository
git clone https://github.com/jingkaihe/kodelet-action.git
cd kodelet-action

# Test the action (requires actual GitHub repository context)
act pull_request_review_comment --secret ANTHROPIC_API_KEY=your-key
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## Support

- 📖 [Kodelet Documentation](https://github.com/jingkaihe/kodelet)
- 🐛 [Report Issues](https://github.com/jingkaihe/kodelet-action/issues)
- 💬 [Discussions](https://github.com/jingkaihe/kodelet-action/discussions)

## License

This action is licensed under the MIT License. See [LICENSE](LICENSE) for details.
