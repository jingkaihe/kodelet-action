# Kodelet Action

[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/jingkaihe/kodelet-action)](https://github.com/jingkaihe/kodelet-action/releases)
[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-Kodelet%20Action-blue.svg?colorA=24292e&colorB=0366d6&style=flat&longCache=true&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAM6wAADOsB5dZE0gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAERSURBVCiRhZG/SsMxFEZPfsVJ61jbxaF0cRQRcRJ9hlYn30IHN/+9iquDCOIsblIrOjqKgy5aKoJQj4n3EllCLx9AuAkfOScdtNwJZdH+fKGiMEhiFCeAJ+JPWBa8AADBSOA8gNFSKYR8H6AAD5KM8HFw/YJJpJaUKJhANSRBQ1EY0rQr4dMZPKwZLLqA2k8y5nHEPW2hL9P4pYgHuNzQASi7/OcJwrHQlJ3I1hQh0Y6J2V0K04UHMcOKoIJSojM/JUKKyBwb8kRcnGPKJOSfDGpL1XYAAAAASUVORK5CYII=)](https://github.com/marketplace/actions/kodelet-action)

Kodelet is an LLM-powered coding agent that integrates seamlessly with your GitHub workflow, transforming how you handle development tasks.



## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
  - [1. Setup API Key](#1-setup-api-key)
  - [2. Create Workflow File](#2-create-workflow-file)
  - [3. Trigger Kodelet](#3-trigger-kodelet)
- [Inputs](#inputs)
- [Usage Examples](#usage-examples)
  - [Basic Usage (Minimal Configuration)](#basic-usage-minimal-configuration)
  - [Auth Gateway Authentication](#auth-gateway-authentication)
  - [Custom Configuration](#custom-configuration)
  - [Manual Override (if needed)](#manual-override-if-needed)
  - [Environment Variables](#environment-variables)
  - [Version Pinning](#version-pinning)
  - [Kodelet Configuration](#kodelet-configuration)
- [Permissions](#permissions)
- [Security](#security)
- [Supported Events](#supported-events)
- [Error Handling](#error-handling)
- [GitHub Authentication Token Considerations](#github-authentication-token-considerations)
  - [1. Auth Gateway (Default & Recommended)](#1-auth-gateway-default--recommended)
  - [2. Standard GitHub Token](#2-standard-github-token)
  - [3. Personal Access Token (PAT)](#3-personal-access-token-pat)
  - [4. Custom Auth Gateway](#custom-auth-gateway)
  - [Recommendation](#recommendation)
- [Versioning](#versioning)
- [Development](#development)
  - [Testing Locally](#testing-locally)
  - [Contributing](#contributing)
- [Support](#support)
- [License](#license)

## Features

* **Automated Issue Resolution** Kodelet analyses your GitHub issues and automatically generates comprehensive solutions, creating pull requests with clean, production-ready code based on your specifications. It handles complex coding tasks without manual intervention, letting you focus on higher-level architectural decisions while it manages the implementation details.
* **Intelligent Continuous Improvement** Kodelet doesn't just write code once and disappear. It iteratively improves pull requests based on your feedback and code review comments, adapting to your coding standards and project requirements.
* **Parallel Task Management** Scale your development capacity by delegating multiple coding tasks simultaneously. You can assign as many issues as needed to Kodelet, and it will work on them in parallel, maximising your development velocity without requiring you to manage the workload distribution.
* **Integrate into your workflow** Simply mention `@kodelet` in any GitHub issue or pull request to engage your AI coding assistant. Kodelet will spring into github action, analysing your requirements and delivering high-quality solutions tailored to your project.

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


jobs:
  background-agent:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      issues: read
      pull-requests: read
      contents: read
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
        uses: jingkaihe/kodelet-action@v0.1.7-alpha
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
| `anthropic-api-key` | Anthropic API key for Kodelet | No | |
| `openai-api-key` | OpenAI API key for Kodelet | No | |
| `github-token` | GitHub token for repository operations | No | Auto-resolved via auth gateway |
| `auth-gateway-endpoint` | Auth gateway endpoint URL to obtain GitHub token | No | `https://gha-auth-gateway.kodelet.com/api/github` |
| `commenter` | Username who triggered the action | No | Auto-detected from event |
| `event-name` | GitHub event name | No | `${{ github.event_name }}` |
| `issue-number` | Issue or PR number | No | Auto-detected from event |
| `comment-id` | Comment ID (for issue comments on PRs) | No | Auto-detected from event |
| `review-id` | Review ID (for PR review comments) | No | Auto-detected from event |
| `repository` | Repository in format owner/repo | No | `${{ github.repository }}` |
| `is-pr` | Whether this is a pull request | No | Auto-detected from event |
| `pr-number` | Pull request number | No | Auto-detected from event |
| `timeout-minutes` | Timeout for execution in minutes | No | `15` |
| `log-level` | Log level (debug, info, warn, error) | No | `info` |
| `kodelet-version` | Kodelet version to install (e.g., v0.0.35.alpha, latest) | No | `latest` |
| `kodelet-config` | Kodelet configuration content in YAML format | No | if empty `./kodelet-config.yaml` will be used |
| `env` | Additional environment variables as JSON object | No | `{}` |
| `max-turns` | Maximum number of turns for Kodelet execution | No | `0` |

## Usage Examples

### Basic Usage (Minimal Configuration)

```yaml
# With Anthropic API
- uses: jingkaihe/kodelet-action@v0.1.7-alpha
  with:
    anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
    # All other inputs are automatically populated from GitHub context

# With OpenAI API
- uses: jingkaihe/kodelet-action@v0.1.7-alpha
  with:
    openai-api-key: ${{ secrets.OPENAI_API_KEY }}
    # All other inputs are automatically populated from GitHub context
```

### Auth Gateway Authentication

By default, the action uses the Auth Gateway to obtain a GitHub token instead of the standard `GITHUB_TOKEN`. This provides several benefits:

- **Enhanced Triggers**: Pull requests and git pushes will trigger follow-up workflow runs (unlike the default GitHub Actions token)
- **Kodelet User Context**: Actions appear as performed by the `kodelet` user

The action automatically handles authentication via the auth gateway. To use a custom GitHub token instead:

```yaml
- uses: jingkaihe/kodelet-action@v0.1.7-alpha
  with:
    anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
    github-token: ${{ secrets.CUSTOM_GITHUB_TOKEN }}  # Override auth gateway
```

Required permissions for auth gateway usage:

```yaml
permissions:
  id-token: write        # Required for auth gateway authentication
  issues: write          # Comment on issues
  pull-requests: write   # Comment on PRs
  contents: write        # Push commits and create branches
```

### Custom Configuration

```yaml
- uses: jingkaihe/kodelet-action@v0.1.7-alpha
  with:
    anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
    timeout-minutes: 180  # 3 hours
    log-level: debug
    kodelet-version: v0.0.35.alpha  # Pin to specific version
    max-turns: 10  # Limit Kodelet to maximum 10 turns
```

### Manual Override (if needed)

```yaml
- uses: jingkaihe/kodelet-action@v0.1.7-alpha
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
- uses: jingkaihe/kodelet-action@v0.1.7-alpha
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
- uses: jingkaihe/kodelet-action@v0.1.7-alpha
  with:
    kodelet-version: latest

# Pin to specific version
- uses: jingkaihe/kodelet-action@v0.1.7-alpha
  with:
    kodelet-version: 0.0.35.alpha
```

**Recommended approaches:**
- **Production**: Pin to a specific stable version for consistency
- **Development**: Use `latest` to get the newest features
- **Testing**: Pin to specific versions to ensure reproducible results

### Kodelet Configuration

The action supports configurable Kodelet settings through YAML configuration content:

```yaml
# Use custom configuration content
- uses: jingkaihe/kodelet-action@v0.1.7-alpha
  with:
    anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
    kodelet-config: |
      # Logging Configuration
      log_level: "info"
      log_format: "json"

      # LLM Configuration
      provider: "anthropic"
      model: "claude-sonnet-4-0"
      max_tokens: 8192
      thinking_budget_tokens: 4048
      weak_model: "claude-3-5-haiku-latest"
      weak_model_max_tokens: 8192
      reasoning_effort: "medium"

      # Tracing Configuration
      tracing:
        enabled: true
        sampler: always
        ratio: 1

# OpenAI Configuration Example
- uses: jingkaihe/kodelet-action@v0.1.7-alpha
  with:
    openai-api-key: ${{ secrets.OPENAI_API_KEY }}
    kodelet-config: |
      # LLM Configuration for OpenAI
      provider: "openai"
      model: "o4-mini"
      max_tokens: 8192
      weak_model: "gpt-4.1-mini"
      weak_model_max_tokens: 4096
      reasoning_effort: "medium"

      # Logging Configuration
      log_level: "info"
      log_format: "json"

# Use default configuration file (./kodelet-config.yaml) if it exists
- uses: jingkaihe/kodelet-action@v0.1.7-alpha
  with:
    anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
    # Will automatically use ./kodelet-config.yaml if present
```

For configuration file format and options, see:
- [Kodelet Configuration Documentation](https://github.com/jingkaihe/kodelet/blob/main/docs/MANUAL.md#configuration-file)
- [Sample Configuration File](https://github.com/jingkaihe/kodelet/blob/main/config.sample.yaml)

## Permissions

The action requires the following GitHub permissions:

```yaml
permissions:
  id-token: write        # Required for auth gateway authentication
  issues: write          # Comment on issues
  pull-requests: write   # Comment on PRs
  contents: write        # Push commits and create branches
```

## Security

- **API Keys**: Store your Anthropic or OpenAI API keys in GitHub Secrets (at least one is required)
- **GitHub Token**: Uses the Auth Gateway with OIDC authentication by default, or custom `GITHUB_TOKEN` if provided
- **Auth Gateway**: Securely authenticates using GitHub's OIDC ID tokens to obtain enhanced GitHub access tokens
- **Repository Access**: Only maintainers/collaborators can trigger the action
- **Timeout Protection**: Execution is limited by configurable timeout

## Supported Events

| Event | Description | Kodelet Command |
|-------|-------------|-----------------|
| `issue_comment` | Comments on issues | `kodelet issue-resolve --issue-url` |
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

## GitHub Authentication Token Considerations

The action supports three different approaches for GitHub authentication, each with distinct advantages and limitations:

### 1. Auth Gateway (Default & Recommended)

**How it works**: Uses GitHub's OIDC ID tokens to authenticate with Kodelet's Auth Gateway, which provides an enhanced GitHub token.

**Advantages**:
- **Enhanced Triggers**: Code pushes and PR creation by Kodelet will trigger follow-up workflow runs
- **Kodelet User Context**: Actions appear as performed by the `kodelet` user instead of `github-actions[bot]`
- **No Token Management**: No need to create or rotate tokens manually
- **Secure**: Uses GitHub's built-in OIDC authentication

**Requirements**:
- `id-token: write` permission in workflow
- Repository must allow the Kodelet app (default: [kodelet app](https://github.com/apps/kodelet))

**Usage**:
```yaml
permissions:
  id-token: write        # Required for auth gateway
  contents: write
  issues: write
  pull-requests: write

steps:
  - uses: jingkaihe/kodelet-action@v0.1.7-alpha
    with:
      anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
      # Auth gateway used automatically
```

### 2. Standard GitHub Token

**How it works**: Uses the default `GITHUB_TOKEN` provided by GitHub Actions.

**Advantages**:
- **No Setup Required**: Available by default in all GitHub Actions
- **No External Dependencies**: Doesn't require external services

**Limitations**:
- **Limited Triggers**: [Code pushes and PR creation won't trigger follow-up workflows](https://github.com/orgs/community/discussions/25702)
- **Bot User Context**: Actions appear as performed by `github-actions[bot]`

**Usage**:
```yaml
steps:
  - uses: jingkaihe/kodelet-action@v0.1.7-alpha
    with:
      anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
      github-token: ${{ secrets.GITHUB_TOKEN }}  # Override auth gateway
```

### 3. Personal Access Token (PAT)

**How it works**: Uses a manually created Personal Access Token with repository permissions.

**Advantages**:
- **Enhanced Triggers**: Code pushes and PR creation will trigger follow-up workflows
- **User Context**: Actions appear as performed by the token owner

**Limitations**:
- **Token Management Overhead**: Requires manual creation, rotation, and renewal
- **Security Risk**: Tokens need to be stored as secrets and managed carefully
- **Doesn't Scale**: Difficult to manage across multiple repositories

**Usage**:
```yaml
steps:
  - uses: jingkaihe/kodelet-action@v0.1.7-alpha
    with:
      anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
      github-token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
```

### 4. Custom Auth Gateway

**How it works**: Uses a custom auth gateway endpoint instead of the default Kodelet service to obtain GitHub tokens.

**When to use**:
- **Enterprise Deployments**: Organizations running their own Kodelet instance with custom authentication requirements
- **Security Compliance**: Companies with strict policies requiring all external services to go through internal gateways
- **Custom GitHub Apps**: Organizations that have created their own GitHub App instead of using the public Kodelet app
- **Air-Gapped Environments**: Deployments in restricted networks that cannot access external Kodelet services
- **Custom Authentication Flows**: Organizations needing specialized token acquisition logic or additional security layers

**Requirements**:
- Custom auth gateway service compatible with Kodelet's authentication protocol
- `id-token: write` permission for OIDC authentication
- Custom GitHub App configured for your organization (if not using the default)

**Usage**:
```yaml
steps:
  - uses: jingkaihe/kodelet-action@v0.1.7-alpha
    with:
      anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
      auth-gateway-endpoint: https://your-custom-gateway.com/api/github
```

**Considerations**:
- Requires maintaining your own auth gateway infrastructure
- Must implement the same authentication protocol as the default gateway
- Need to ensure high availability and security of the custom service
- May require additional setup and configuration compared to the default approach

### Recommendation

**For most users**: Use the default Auth Gateway approach as it provides the best balance of functionality, security, and ease of use.

**For organizations with strict security policies**: Consider using a PAT with appropriate scope limitations, but be prepared for the additional token management overhead.

**For simple, one-off usage**: The standard `GITHUB_TOKEN` may be sufficient if follow-up workflow triggers are not needed.

**For enterprise deployments**: Consider using a custom auth gateway if you have strict security policies or need to integrate with your existing authentication infrastructure.

## Versioning

This action follows semantic versioning:

- **Latest stable**: `@v0`
- **Specific version**: `@v0.1.7-alpha`
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

- [Kodelet Documentation](https://github.com/jingkaihe/kodelet)
- [Report Issues](https://github.com/jingkaihe/kodelet-action/issues)
- [Discussions](https://github.com/jingkaihe/kodelet-action/discussions)

## License

This action is licensed under the MIT License. See [LICENSE](LICENSE) for details.
