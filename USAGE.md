# 🚀 Ibis Build Action Usage Guide

## Quick Setup

### 1. Prerequisites
- Repository with Ibis Next project initialized
- `ibis.php` configuration file
- Markdown content in `content/` directory

### 2. Add Workflow

Create `.github/workflows/build-ebooks.yml`:

```yaml
name: Build eBooks
on:
  push:
    branches: [main]
permissions:
  contents: write
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GITHUB_TOKEN }}
      - uses: bobbyiliev/ibis-build-action@main
        with:
          ibis_path: "./ebook/en"
          email: "your@email.com"
```

## Configuration Options

| Input | Description | Default | Example |
|-------|-------------|---------|---------|
| `ibis_path` | Path to Ibis project | `"./"` | `"./ebook/en"` |
| `ibis_branch` | Branch for commits | `"main"` | `"main"` |
| `email` | Git commit email | `"bobby@bobbyiliev.com"` | `"user@example.com"` |
| `commit_message` | Commit message | `"Updated Ibis Next Exported Files"` | `"📚 Updated eBooks"` |
| `php_version` | PHP version | `"8.2"` | `"8.3"` |

## Generated Files

The action creates these files in your `export/` directory:
- `{title}-light.pdf` - Light theme PDF
- `{title}-dark.pdf` - Dark theme PDF  
- `{title}.epub` - EPUB format
- `{title}-sample-light.pdf` - Sample light PDF
- `{title}-sample-dark.pdf` - Sample dark PDF

## Troubleshooting

### "ibis.php not found"
- Ensure you've run `ibis-next init` in your project
- Check the `ibis_path` points to correct directory
- Verify `ibis.php` exists in the specified path

### "No changes detected"
- This means export files are up to date
- Action skips commit when no changes exist
- This is normal behavior, not an error

### Permission errors
- Ensure `GITHUB_TOKEN` has write permissions
- Add `permissions: contents: write` to workflow

## Performance Tips

- First run: ~60 seconds
- Cached runs: ~30 seconds  
- Composer dependencies are cached automatically
- PHP extensions are pre-installed on runners

## Example Projects

See these repositories for real-world examples:
- [Introduction to Docker](https://github.com/bobbyiliev/introduction-to-docker-ebook)
- [Introduction to Bash Scripting](https://github.com/bobbyiliev/introduction-to-bash-scripting)
