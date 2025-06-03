# Kodelet Action Examples

This directory contains example workflows demonstrating different configurations and use cases for the Kodelet Action.

## Available Examples

### 📄 [basic-workflow.yml](basic-workflow.yml)
**Recommended for most users**

A simple, production-ready configuration that covers the most common use cases:
- Issue resolution via `@kodelet` comments
- PR review responses
- Basic security controls (collaborators only)
- Standard timeout settings

**Setup:**
1. Copy the file to `.github/workflows/kodelet.yml` in your repository
2. Add `ANTHROPIC_API_KEY` to your repository secrets
3. Start using `@kodelet` in issue and PR comments

## Quick Start

1. **Choose your example**: Start with `basic-workflow.yml` unless you need advanced features
2. **Copy to your repository**: Place the file in `.github/workflows/kodelet.yml`
3. **Add secrets**: Go to Repository Settings → Secrets → Actions and add:
   - `ANTHROPIC_API_KEY`: Your Anthropic API key (starts with `sk-ant-`)
4. **Test**: Comment `@kodelet` on any issue or PR

## Configuration Options

### Required Inputs
- `anthropic-api-key`: Your Anthropic API key
- `github-token`: Usually `${{ secrets.GITHUB_TOKEN }}`
- `commenter`: The user who triggered the action
- `event-name`: GitHub event type
- `issue-number`: Issue or PR number
- `repository`: Repository in `owner/repo` format
- `is-pr`: Whether this is a pull request

### Optional Inputs
- `comment-id`: Specific comment ID for PR reviews
- `pr-number`: Pull request number
- `timeout-minutes`: Execution timeout (default: 15)
- `log-level`: Logging level (default: info)
- `kodelet-version`: Kodelet version to install (default: latest)

## Security Considerations

### Access Control
All examples include security checks to ensure only authorized users can trigger Kodelet:
- Repository owners
- Organization members
- Collaborators

### API Keys
- Store your Anthropic API key in GitHub Secrets, never in code
- Use the default `GITHUB_TOKEN` for repository operations
- GitHub automatically provides appropriate permissions

### Timeouts
- Set reasonable timeouts to prevent runaway executions
- Default is 5 hours, adjust based on your project complexity
- Consider shorter timeouts for initial testing

## Common Patterns

### Basic Issue Resolution
```yaml
if: |
  github.event_name == 'issue_comment' &&
  contains(github.event.comment.body, '@kodelet') &&
  github.event.comment.author_association == 'OWNER'
```

### PR Review Response
```yaml
if: |
  github.event_name == 'pull_request_review_comment' &&
  contains(github.event.comment.body, '@kodelet')
```

### Multiple Triggers
```yaml
if: |
  (
    contains(github.event.comment.body, '@kodelet') ||
    contains(github.event.comment.body, '@kodelet-help')
  )
```

## Troubleshooting

### Common Issues

1. **Action not triggering**
   - Check if commenter has required permissions
   - Verify `@kodelet` is in the comment body
   - Ensure workflow file is in `.github/workflows/` directory

2. **Permission errors**
   - Verify repository permissions in workflow file
   - Check if `ANTHROPIC_API_KEY` is set in secrets
   - Ensure `GITHUB_TOKEN` has required permissions

3. **Timeout errors**
   - Increase `timeout-minutes` value
   - Check if repository size/complexity requires longer processing
   - Consider splitting complex tasks

### Debug Steps

1. **Enable debug logging**: Set `log-level: "debug"` in action inputs
2. **Check workflow logs**: Go to Actions tab → Failed workflow → View logs
3. **Verify inputs**: Ensure all required inputs are provided correctly
4. **Test manually**: Try running Kodelet locally with same parameters

### Getting Help

- 📖 [Main Documentation](https://github.com/jingkaihe/kodelet)
- 🐛 [Report Issues](https://github.com/jingkaihe/kodelet-action/issues)
- 💬 [Community Discussions](https://github.com/jingkaihe/kodelet-action/discussions)

## Contributing Examples

Have a useful configuration? We'd love to include it! Please:

1. Create a new example file with descriptive name
2. Add comprehensive comments explaining the use case
3. Include setup instructions
4. Add entry to this README
5. Submit a pull request

Example naming convention:
- `enterprise-workflow.yml` - For enterprise environments
- `monorepo-workflow.yml` - For monorepo setups
- `security-focused-workflow.yml` - For high-security environments
