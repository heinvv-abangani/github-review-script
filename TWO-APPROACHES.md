# Two Approaches: MCP vs Direct API

**Your Problem:** GitHub MCP loads 101 tools, exceeding Cursor's limit.

**Your Solution:** Choose one of these approaches.

---

## ⚡ Approach 1: Filtered GitHub MCP (Try This First)

**What:** Use GitHub MCP but only load 10 essential tools instead of 101.

**Status:** ✅ Already configured in your `~/.cursor/mcp.json`

**Tools Loaded:** Only 10 tools:
- `get_pull_request`
- `list_pull_requests`
- `get_pull_request_diff`
- `get_pull_request_files`
- `get_file_contents`
- `search_code`
- `create_review_comment`
- `list_review_comments`
- `create_review`
- `get_repository`

**How to Use:**

1. **Restart Cursor completely** (Cmd+Q, then reopen)

2. **Verify tool count:**
   - Check status bar: "MCP: X connected"
   - Should show ~10 GitHub tools instead of 101

3. **Test it:**
   ```
   Open Cursor Chat → Type:
   "List recent PRs in elementor/elementor"
   ```

4. **If it works, use normal workflow:**
   ```bash
   ./scripts/review-pr-mcp.sh https://github.com/elementor/elementor/pull/123
   # Copy prompt → Paste in Cursor
   ```

**Pros:**
- ✅ Integrated MCP experience
- ✅ Can post comments directly to GitHub
- ✅ Stays under tool limit

**Cons:**
- ⚠️ Depends on MCP tool filtering working
- ⚠️ Still requires Docker running

---

## 🔄 Approach 2: Direct GitHub API (Fallback)

**What:** Bypass MCP entirely. Fetch PR data with simple curl commands, then give to Cursor.

**Status:** ✅ Script created at `scripts/fetch-pr-data.sh`

**Tools Loaded:** 0 (doesn't use MCP at all)

**How to Use:**

1. **Fetch PR data:**
   ```bash
   ./scripts/fetch-pr-data.sh https://github.com/elementor/elementor/pull/123
   ```
   This downloads:
   - PR details (JSON)
   - PR diff (text)
   - Changed files (JSON)

2. **Copy the generated prompt** (script shows it)

3. **Paste into Cursor chat**

4. **Cursor reviews the files** (reads local files, no MCP needed)

5. **Review is generated** at `pr-reviews/PR-123-2025-10-06.md`

**Pros:**
- ✅ Zero tool limit issues
- ✅ No MCP needed
- ✅ No Docker needed
- ✅ 100% reliable
- ✅ Faster (no MCP overhead)

**Cons:**
- ⚠️ Extra step (fetch data first)
- ⚠️ Can't post comments directly (need separate script)
- ⚠️ Slightly more manual

---

## 🎯 Which Should You Use?

### Use Approach 1 (Filtered MCP) If:
- ✅ You want seamless integration
- ✅ You want to post comments directly to GitHub
- ✅ You don't mind keeping Docker running
- ✅ The tool filtering works (test it!)

### Use Approach 2 (Direct API) If:
- ✅ Tool filtering doesn't work
- ✅ You want guaranteed reliability
- ✅ You don't need to post comments often
- ✅ You prefer simpler, more transparent workflow

---

## 📊 Side-by-Side Comparison

| Feature | Approach 1: Filtered MCP | Approach 2: Direct API |
|---------|-------------------------|----------------------|
| **Tool Count** | 10 tools | 0 tools (no MCP) |
| **Setup Complexity** | Medium | Low |
| **Reliability** | Good (if filtering works) | Excellent |
| **Docker Required** | Yes | No |
| **Post Comments** | Yes (direct) | Yes (separate script) |
| **Speed** | Fast | Very fast |
| **Maintenance** | Low | Very low |

---

## 🧪 Testing Both Approaches

### Test Approach 1:
```bash
# After restarting Cursor
# Open Cursor chat and try:
"List the 5 most recent PRs in elementor/elementor"

# If this works without tool limit errors, you're good!
```

### Test Approach 2:
```bash
# Fetch some PR data
./scripts/fetch-pr-data.sh https://github.com/elementor/elementor/pull/27890

# Copy the generated prompt
# Paste in Cursor chat
# Should generate review successfully
```

---

## 💡 Recommendation

**Start with Approach 1** (it's already configured):

1. Restart Cursor
2. Test if tool count is reduced
3. Try a PR review

**If it doesn't work or still hits limit:**

Switch to Approach 2 - it's bulletproof and actually simpler.

---

## 🔧 Quick Switch Guide

### Currently Using MCP (Approach 1)
You're using this right now.

### Switch to Direct API (Approach 2)

**Option A: Disable GitHub MCP entirely**
```json
// In ~/.cursor/mcp.json, comment out or remove the "github" section
{
  "mcpServers": {
    // "github": { ... },  // Commented out
    "wordpress-mcp1": { ... },
    // ... other MCPs
  }
}
```

**Option B: Just use the direct API script**
Even with MCP enabled, you can use `fetch-pr-data.sh` anytime:
```bash
./scripts/fetch-pr-data.sh <PR_URL>
# Then paste prompt in Cursor
```

---

## 📝 Both Scripts Available

You now have both options ready:

1. **`./scripts/review-pr-mcp.sh`** - Uses MCP (Approach 1)
2. **`./scripts/fetch-pr-data.sh`** - Direct API (Approach 2)

Try both and use whichever works best for you!

---

## ✅ Next Steps

1. **Restart Cursor** (to apply filtered MCP config)
2. **Test Approach 1** (see if tool count is reduced)
3. **If issues persist**, use **Approach 2** (direct API)
4. **Pick your favorite** and stick with it

---

**Last Updated:** October 6, 2025  
**Status:** Both approaches ready to use



