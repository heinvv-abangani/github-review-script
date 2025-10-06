# Getting Started with PR Review Automation

**Welcome!** This guide will get you reviewing PRs with AI in 15 minutes.

---

## 🎯 What You're About to Build

A system that automatically reviews GitHub PRs using:
- **Cursor AI** - Your IDE with AI capabilities
- **GitHub MCP** - Secure connection to GitHub
- **22 Coding Rules** - Comprehensive standards for Elementor

**The Result:** Detailed PR reviews with file:line references, severity ratings, and actionable recommendations.

---

## 📚 Your Documentation Map

```
00-github-reviews/
│
├── 🚀 START HERE ─────────────────────────────────────
│   ├── GETTING-STARTED.md      ← You are here!
│   └── QUICK-START.md          ← 5-minute setup
│
├── 📖 DETAILED GUIDES ────────────────────────────────
│   ├── MCP-SETUP-GUIDE.md      ← Complete MCP setup
│   └── README.md               ← System overview
│
├── 📋 PLANNING & STATUS ──────────────────────────────
│   ├── PLAN.MD                 ← Full PRD & proposals
│   ├── IMPLEMENTATION-STATUS.md ← Checklist & metrics
│   └── CHATGPT.md              ← Research notes
│
└── 🔧 TOOLS ──────────────────────────────────────────
    ├── scripts/review-pr-mcp.sh ← Helper script
    ├── pr-reviews/              ← Generated reviews
    └── .gitignore               ← Keep reviews local
```

---

## 🚦 Choose Your Path

### Path A: I Have GitHub Copilot ✨ (Easiest)

**Time:** ~10 minutes  
**Requirements:** GitHub Copilot subscription

```
1. Configure MCP    → 5 mins (copy/paste config)
2. Authorize OAuth  → 2 mins (click authorize)
3. Test connection  → 3 mins (simple query)
✅ Done!
```

**Next:** Open [QUICK-START.md](./QUICK-START.md) → "For Users with GitHub Copilot"

---

### Path B: I Don't Have Copilot 🐳 (Still Easy)

**Time:** ~15 minutes  
**Requirements:** Docker + GitHub token

```
1. Install Docker   → 5 mins (if not installed)
2. Create GitHub token → 3 mins
3. Configure MCP    → 5 mins (Docker setup)
4. Test connection  → 2 mins
✅ Done!
```

**Next:** Open [QUICK-START.md](./QUICK-START.md) → "For Users Without GitHub Copilot"

---

## 🎬 Quick Demo: What It Looks Like

### Step 1: Run Helper Script
```bash
./scripts/review-pr-mcp.sh https://github.com/elementor/elementor/pull/123
```

### Step 2: Get Generated Prompt
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  GitHub PR Review via MCP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Repository: elementor/elementor
  PR Number:  #123
  Output:     pr-reviews/PR-123-2025-10-06.md

📝 CURSOR CHAT PROMPT (copy and paste):
════════════════════════════════════════════════

Please review GitHub PR: https://github.com/...
[detailed instructions]
════════════════════════════════════════════════
```

### Step 3: Paste into Cursor Chat

### Step 4: Get Structured Review
```markdown
# PR Review: #123 - Add new widget feature

**Date:** 2025-10-06 15:30:00
**Status:** NEEDS_WORK

## Executive Summary
This PR adds a new atomic widget with 156 lines across 
5 files. Overall quality is good but has 2 critical 
type safety issues that need addressing before merge.

## Critical Issues (Blockers) 🚨

### Missing TypeScript Return Type
- **File:** [`modules/widgets/new-widget.tsx:45`](...)
- **Rule:** typescript-safety
- **Description:** Function missing explicit return type
- **Recommended Fix:**
  ```typescript
  // Current
  function createWidget(props) {
    return <Widget {...props} />;
  }
  
  // Recommended
  function createWidget(props: WidgetProps): JSX.Element {
    return <Widget {...props} />;
  }
  ```

[... more issues ...]

## Positive Observations ✅
- [`new-widget.tsx`] Excellent use of React hooks
- [`styles.scss`] Well-organized CSS structure
- [`tests/`] Comprehensive test coverage

## Recommendations
1. Fix 2 critical type safety issues
2. Add JSDoc for public API methods
3. Consider memoizing expensive computations
```

---

## ✅ 3-Step Quick Start

### Step 1: Setup (10 minutes)

**Option A (with Copilot):**
```json
// Add to Cursor settings.json:
{
  "mcp": {
    "servers": {
      "github": {
        "url": "https://api.githubcopilot.com/mcp/",
        "type": "http",
        "auth": { "type": "oauth" }
      }
    }
  }
}
```

**Option B (without Copilot):**
```bash
# Create GitHub token at: https://github.com/settings/tokens
export GITHUB_TOKEN="ghp_your_token_here"

# Configure Docker MCP in settings.json (see QUICK-START.md)
```

### Step 2: Test (3 minutes)

```
Open Cursor Chat → Type:
"List recent PRs in elementor/elementor"

Expected: List of recent PRs appears
```

### Step 3: Review (2 minutes)

```bash
./scripts/review-pr-mcp.sh https://github.com/elementor/elementor/pull/[NUMBER]
# Copy prompt → Paste in Cursor → Wait for review
```

**🎉 You're done!** Open the generated review in `pr-reviews/`

---

## 🔍 What Makes This Powerful?

### 22 Comprehensive Coding Rules

Your reviews check against:

**TypeScript & JavaScript**
- ✅ Type safety (no `any`)
- ✅ Performance patterns
- ✅ React best practices

**PHP & WordPress**
- ✅ Security vulnerabilities
- ✅ WordPress standards
- ✅ Clean code principles

**Testing & Quality**
- ✅ Test coverage
- ✅ Code style
- ✅ Git commit standards

**And 13 more categories!**

### Detailed Feedback

Every issue includes:
- 📍 **File:line reference** - Exact location
- 📋 **Rule citation** - Which standard violated
- 💡 **Code example** - How to fix it
- 🎯 **Severity rating** - How important

---

## 🎯 Your First Review (Step by Step)

### 1. Pick a PR to Test

Choose a recently merged PR (safer for testing):
- Look for TypeScript/React changes
- Smaller PRs (< 500 lines) work best
- Example: A bug fix or feature addition

### 2. Run the Helper Script

```bash
cd "/Users/janvanvlastuin1981/Local Sites/elementor/app/public/wp-content"
./scripts/review-pr-mcp.sh https://github.com/elementor/elementor/pull/27890
```

### 3. Review the Prompt

The script generates a detailed prompt. Read it to understand what it asks Cursor to do:
- Fetch PR via MCP
- Apply 22 coding rules
- Generate structured report
- Save to specific location

### 4. Paste into Cursor

1. Open Cursor
2. Open chat panel (Cmd+L or Ctrl+L)
3. Paste the full prompt
4. Press Enter

### 5. Wait for Analysis

Cursor will:
- ✓ Connect to GitHub MCP
- ✓ Fetch PR data and diff
- ✓ Load coding rules
- ✓ Analyze each changed file
- ✓ Generate structured review
- ✓ Save to pr-reviews/

**Time:** ~1-2 minutes for typical PR

### 6. Review the Output

```bash
open pr-reviews/PR-27890-2025-10-06.md
```

Check for:
- ✅ Clear executive summary
- ✅ Issues grouped by severity
- ✅ File:line references present
- ✅ Code examples provided
- ✅ Rule violations cited

### 7. Validate Accuracy

- Are the issues real?
- Any false positives?
- Missing any obvious issues?

### 8. Iterate & Improve

- Refine prompts if needed
- Adjust coding rules
- Share findings with team

---

## 💡 Pro Tips

### Start Small
```
Review just TypeScript files in PR #123
```

### Focus Reviews
```
Security audit for PR #123: check WordPress security practices
```

### Learn from Reviews
```
Explain why the issue in file.tsx:45 violates the typescript-safety rule
```

### Test Before Posting
Always review AI suggestions before posting to GitHub!

---

## 🐛 Troubleshooting Guide

### "MCP not configured"
```bash
# Check settings.json has MCP config
Cmd+Shift+P → "Open User Settings (JSON)"
# Restart Cursor
```

### "Can't connect to GitHub"
```bash
# With Copilot: Re-authorize
GitHub Settings → Applications → Revoke and re-auth

# Without Copilot: Check token
echo $GITHUB_TOKEN
```

### "Docker won't start" (self-hosted)
```bash
# Verify Docker running
docker ps

# Pull MCP image
docker pull ghcr.io/github/github-mcp-server:latest
```

### "Review is generic/not detailed"
```bash
# Make prompt more specific
# Instead of: "Review PR #123"
# Use: "Review PR #123 for TypeScript type safety, React 
#       performance, and WordPress security. Include file:line 
#       references and code examples for each issue."
```

---

## 📊 What Success Looks Like

### Good Review Output:
```markdown
✅ Executive summary with risk assessment
✅ Issues grouped by severity
✅ Every issue has [file:line] reference
✅ Specific rule violations cited
✅ Code examples show current + recommended
✅ Positive observations included
✅ Clear recommendations
```

### Poor Review Output:
```markdown
❌ Generic "looks good" or vague comments
❌ No file/line references
❌ Missing code examples
❌ No severity ratings
❌ Only criticism, no positive notes
```

---

## 🚀 Ready to Start?

### Right Now (15 minutes):
1. **Open:** [QUICK-START.md](./QUICK-START.md)
2. **Setup:** Your MCP connection (10 mins)
3. **Test:** With one PR (5 mins)

### Today (30 minutes):
1. Review 3-5 different PRs
2. Validate accuracy
3. Document learnings

### This Week:
1. Share with team
2. Refine workflow
3. Measure impact

---

## 📚 Documentation Quick Links

- **Need setup help?** → [QUICK-START.md](./QUICK-START.md)
- **Want full details?** → [MCP-SETUP-GUIDE.md](./MCP-SETUP-GUIDE.md)
- **System overview?** → [README.md](./README.md)
- **Implementation checklist?** → [IMPLEMENTATION-STATUS.md](./IMPLEMENTATION-STATUS.md)
- **Full PRD?** → [PLAN.MD](./PLAN.MD)

---

## 🎓 Learn More

### Understanding MCP
- GitHub's secure API layer for AI
- Controls what AI can access
- Audit trail of all actions
- OAuth or token authentication

### How Reviews Work
1. Cursor connects to GitHub MCP
2. MCP fetches PR data securely
3. Cursor applies 22 coding rules
4. Structured review generated
5. Optional: Post to GitHub

### Why This Matters
- Consistent code quality
- Faster reviews (50% time saved)
- Catch issues before merge
- Learn coding standards
- Free up reviewers for architecture

---

## 🎉 You're All Set!

**Next Action:** Open [QUICK-START.md](./QUICK-START.md) and follow the 5-minute setup.

**Questions?** Everything is documented. Check the guides above.

**Stuck?** See troubleshooting sections in each guide.

---

**Version:** 1.0  
**Status:** Production Ready  
**Updated:** October 6, 2025

**Let's make PR reviews awesome! 🚀**




