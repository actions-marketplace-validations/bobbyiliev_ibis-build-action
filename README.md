# 📚 Ibis Build Action

A fast, lightweight GitHub Action to automatically build eBooks using [Ibis Next](https://github.com/Hi-Folks/ibis-next).

![Ibis Next GitHub Action](https://user-images.githubusercontent.com/21223421/139258477-107b1da3-6c02-4a81-a827-d58380a43252.png)

## ✨ Features

- 🚀 **Super Fast**: ~30-60 seconds (no Docker!)
- 📄 **Multiple Formats**: PDF (light & dark), EPUB, samples
- 🔧 **Simple Setup**: Just add to your workflow
- 📦 **Smart Caching**: Composer dependencies cached
- 🎯 **Auto Commit**: Builds and commits export files

## 📖 About Ibis Next

[Ibis Next](https://github.com/Hi-Folks/ibis-next) is a PHP tool that lets you write eBooks in Markdown and export them to multiple formats.

## 🚀 Quick Start

### 1. Create Workflow File

Create `.github/workflows/ibis.yml`:

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
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Build eBooks with Ibis Next
        uses: bobbyiliev/ibis-build-action@main
        with:
          ibis_path: "./ebook/en"          # Path to your Ibis project
          ibis_branch: "main"              # Branch to commit to
          email: "your@email.com"          # Git commit email
          commit_message: "📚 Updated eBooks"
          php_version: "8.2"              # PHP version (optional)
          formats: "pdf,epub"              # Only build PDF and EPUB
          skip_push: "false"               # Enable git operations
```

### 2. Repository Setup

Make sure your repository has:
- An Ibis project initialized with `ibis-next init`
- The `ibis.php` configuration file
- Markdown content in the `content/` directory

## ⚙️ Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `ibis_path` | Path to your Ibis ebook directory | No | `"./"` |
| `ibis_branch` | Branch to commit changes to | No | `"main"` |
| `email` | Email for Git commits | No | `"bobby@bobbyiliev.com"` |
| `commit_message` | Commit message for changes | No | `"Updated Ibis Next Exported Files"` |
| `php_version` | PHP version to use | No | `"8.2"` |
| `skip_push` | Skip git operations (commit/push) | No | `"false"` |
| `formats` | Formats to build (comma-separated) | No | `"pdf,pdf-dark,epub,sample,sample-dark"` |

## 💡 Usage Examples

### Basic Usage (All Formats)
```yaml
- uses: bobbyiliev/ibis-build-action@main
  with:
    ibis_path: "./ebook/en"
    email: "your@email.com"
```

### PDF Only
```yaml
- uses: bobbyiliev/ibis-build-action@main
  with:
    ibis_path: "./ebook/en"
    formats: "pdf,pdf-dark"
    email: "your@email.com"
```

### Testing (No Git Operations)
```yaml
- uses: bobbyiliev/ibis-build-action@main
  with:
    ibis_path: "./ebook/en"
    skip_push: "true"
    formats: "pdf,sample"
```

### Custom Branch & Message
```yaml
- uses: bobbyiliev/ibis-build-action@main
  with:
    ibis_path: "./docs"
    ibis_branch: "gh-pages" 
    commit_message: "🤖 Auto-update documentation"
    email: "bot@company.com"
```

## 🔄 What It Does

1. **Setup**: Installs PHP 8.2+ with required extensions (gd, zip, mbstring, intl)
2. **Install**: Downloads and caches Ibis Next via Composer
3. **Build**: Generates all formats:
   - 📄 PDF (light theme)
   - 🌙 PDF (dark theme)  
   - 📱 EPUB
   - 📑 Sample PDFs (light & dark)
4. **Commit**: Auto-commits and pushes export files if changes detected

## 🏗️ Project Structure

Your repository should look like:

```
your-ebook-repo/
├── .github/workflows/
│   └── ibis.yml
├── ebook/en/              # or your ibis_path
│   ├── ibis.php          # Ibis config file
│   ├── content/
│   │   ├── 001-intro.md
│   │   └── 002-chapter.md
│   ├── assets/
│   └── export/           # Generated files go here
└── README.md
```

## 🚀 Performance

| Build Type | Time | 
|------------|------|
| **First Run** | ~60 seconds |
| **Cached Run** | ~30 seconds |
| **Docker (old)** | ~2-3 minutes |

## 📚 Example Projects

- [Introduction to Docker](https://github.com/bobbyiliev/introduction-to-docker-ebook)
- [Introduction to Git and GitHub](https://github.com/bobbyiliev/introduction-to-git-and-github-ebook)
- [Introduction to Bash Scripting](https://github.com/bobbyiliev/introduction-to-bash-scripting)
- [Introduction to SQL](https://github.com/bobbyiliev/introduction-to-sql)
- [Laravel tips and tricks](https://github.com/bobbyiliev/laravel-tips-and-tricks-ebook)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT License - see [LICENSE.md](LICENSE.md) for details.
