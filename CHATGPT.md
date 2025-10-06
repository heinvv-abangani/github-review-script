Skip to content
Chat history

You said:
i would like to automate my review process in github.

I am thinking of using the Github MCP incombination with Cursor AI.

Analyse, evaluate and elaborate.
ChatGPT said:

Thought for 1m 17s
Nice—great idea. Automating PR reviews with GitHub’s MCP (Model Context Protocol) + Cursor AI is both practical and powerful. Below I’ll:

give a short verdict,

outline two realistic architectures (quick vs. production),

show an actionable implementation (including a GitHub Action + Cursor API example),

give a ready-to-copy prompt/checklist for the agent, and

list security, cost and governance guardrails you should apply.

Short verdict
Yes — this is a good approach. MCP gives AI tools safe, structured access to repo context and GitHub artifacts; Cursor provides “background agents” (and an API) that can clone a repo, run checks, create PRs and post review comments. That combo lets you automate the first-pass review, run programmatic checks, and even propose fixes — while keeping humans in the loop for final approval. 
GitHub Docs
+1

Two architecture options
Option A — Fast path (recommended to prototype)
Use Cursor’s built-in GitHub integration + Background Agents.

Configure Cursor to access the repo, then spawn agents (manually or via Cursor’s Background Agent API) to review PRs and open suggestion PRs. This is fastest to get value (no self-hosting). Cursor agents can clone the repo, run checks, and open PRs for you. 
Cursor
+1

Pros: fast to set up; Cursor handles runtime; quick to iterate.
Cons: relies on a third-party SaaS provider and paid features (background agents often have usage billing). 
Reddit

Option B — Production / security-focused (self-hosted MCP + Cursor)
Run (or use) GitHub’s official GitHub MCP Server (or a curated GitHub-MCP server) in your infra, exposing only the exact GitHub capabilities you want (read PRs/diffs, create PR comments, create branches). Connect Cursor to that MCP server (Cursor supports adding MCP servers). Use GitHub Actions to trigger Cursor via the Background Agents API (or call the MCP server hooks) when PRs update. 
GitHub
+1

Pros: more control over access, auditing and network boundaries; better for private/internal code.
Cons: more engineering and CI/CD upkeep; you must harden and maintain the MCP server.

Either way: prefer agents to open suggestion PRs rather than granting them direct commit/merge rights to protected branches.

How it can work (end-to-end, practical flow)
PR created / updated → GitHub pull_request event fires.

A GitHub Action (or webhook) calls Cursor’s Background Agents API to spawn a new agent, passing PR context (repo URL, head sha/ref, PR number) + an explicit prompt describing the checks to run. 
Cursor Documentation

Cursor Agent clones the PR branch, runs configured tools (lint, tests, typecheck, static analysis, SCA, unit tests, performance-lite checks), summarizes findings as a structured report and posts inline review comments. If allowed, it opens a suggestion branch / PR with fixes. 
Cursor

GitHub Actions CI still runs; require all status checks and human review before merging (branch protection).

Team reviews the agent’s PR/comments, merges when satisfied.

Concrete: GitHub Action that asks Cursor to review a PR
Store a Cursor API key in Secrets -> CURSOR_API_KEY. This example fires on pull_request events and calls Cursor’s Background Agent API to request a review:

name: Request Cursor PR Review
on:
  pull_request:
    types: [opened, reopened, synchronize]

jobs:
  cursor-review:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger Cursor Background Agent
        env:
          CURSOR_API_KEY: ${{ secrets.CURSOR_API_KEY }}
          REPO_URL: https://github.com/${{ github.repository }}
          PR_NUMBER: ${{ github.event.pull_request.number }}
          PR_HEAD_SHA: ${{ github.event.pull_request.head.sha }}
          PR_HEAD_REF: ${{ github.event.pull_request.head.ref }}
        run: |
          curl --request POST \
            --url https://api.cursor.com/v0/agents \
            --header "Authorization: Bearer $CURSOR_API_KEY" \
            --header 'Content-Type: application/json' \
            --data '{
              "prompt": {
                "text": "Review PR #'$PR_NUMBER' on '"$REPO_URL"'. Check code correctness, run lint/tests/typecheck where applicable, run static security scan, list any risky changes, and propose fixes as commits in a new branch. Produce inline comments and an executive summary at the top of the PR."
              },
              "source": {
                "repository": "'"$REPO_URL"'",
                "ref": "'"$PR_HEAD_SHA"'"
              },
              "target": {
                "autoCreatePr": false
              }
            }'
Notes:

Use the commit SHA for ref to be precise. Cursor’s API accepts repository + ref. (Docs / cURL examples in Cursor docs.) 
Cursor Documentation

Example agent prompt / checklist (copy–paste into prompt.text)
Act as a senior code reviewer. You have the full repository at commit <SHA> and PR #<PR_NUMBER>.

Run formatting/linting, type-checks (TS/Py), and unit tests (only where runnable in CI-like environment). List failures.

Run static analysis / SAST (quick scan) and flag high/critical findings.

Check for: public API changes, missing docs, missing migrations, dependency updates, and added secrets/credentials.

Provide inline comments for every non-trivial diff with clear remediation steps and code snippets where possible.

If fixes are straightforward and low-risk (formatting, small bug fixes, missing tests), create a new branch cursor/pr-<PR_NUMBER>/fixes with commits and open a draft PR; otherwise only leave comments.

Summarize: risk level, required human reviewers (areas), and a 1–3 step recommended action plan.

This checklist can be tuned to your team (strictness, allowed auto-fixes, etc.). Many teams keep style/lint auto-fixes automatic and restrict agent-created PRs to suggestion-only for security-sensitive modules.

Security & governance — MUST HAVES
Least privilege: give the Cursor/GitHub MCP identity only the permissions it needs. Prefer read for review actions and write only for creating suggestion PR branches (not direct merges). Use a scoped GitHub App or fine-grained token. 
GitHub Docs

Human-in-the-loop: require that agents create PRs, not merge them. Protect main/release branches with required reviews / status checks. (This is an organizational policy — enforce via branch protection.)

Audit & logging: ensure every agent action is recorded in PR comments and team audit logs; store agent run metadata (agent id, timestamp, prompt, inputs). Cursor’s API returns agent IDs and URLs you can store. 
Cursor Documentation

Pin & vet MCP servers: if you self-host an MCP server or use third-party MCPs, strictly vet the code and pin versions. There have been real supply-chain incidents where malicious MCP servers exfiltrated data — treat MCP servers like any infra you’d run with secrets. Rotate keys after updates and scan dependencies. 
IT Pro
+1

Sensitive-data checks: add a pre-step (or include in agent checklist) to refuse making changes that touch credentials, private keys, config files with secrets, or deploy scripts without explicit human approval.

Network controls: if running MCP/self-hosted Cursor connectors, restrict egress and use VPCs/allow-lists where possible.

Costs, limits & practical caveats
Cursor background agents and their API usage are often behind a paid tier / usage-based billing. Expect per-run charges for large repos or heavy CI-like execution. Validate pricing before rolling out widely. 
Reddit

Agents are not perfect — they will make mistakes. Keep human reviewers for critical subsystems.

For large monorepos, define which folders the agent is allowed to change (scoped reviews) to reduce CI time and surface area.

Observability / metrics to track
Time-to-first-PR-comment (before vs after automation).

Number of agent-created PRs merged vs abandoned.

Reviewer load (comments per reviewer / PR).

False-positive rate (agent suggestions you reverted).

Security findings reduced / increased after agent adoption.

Quick roadmap to experiment (week-by-week)
Week 0 — prototype: pick a non-critical repo, enable Cursor GitHub integration, write a short checklist prompt, run agents manually against a few PRs.

Week 1 — automate trigger: add the GitHub Action above to spawn an agent on PR open/update. Limit agent scope to a single folder.

Week 2 — audit: review agent results, measure noise, tighten the checklist. Require agent PRs to be draft and human-reviewed.

Week 3 — extend: allow auto-fixes (formatting, lint) to be merged automatically if CI green and tests pass; keep other areas manual.

Ongoing: add SCA, CodeQL, and other scanners into the agent checklist; lock down MCP and rotate secrets periodically.

Useful links (for your next clicks)
GitHub docs: About Model Context Protocol (MCP) and GitHub MCP Server. 
GitHub Docs
+1

Cursor docs: GitHub integration, Background Agents, and Background Agent API (launch examples). 
Cursor
+1

Security / MCP guidance: risk analysis and best practices (Red Hat / MCP security community resources). 
Red Hat
+1

News: active supply-chain incident with malicious MCP servers — DO NOT skip vetting/pinning. 
IT Pro

If you want, I can do one of the following right now (pick one; I’ll produce it in this reply):

generate a ready-to-use GitHub Action tailored to your repo (I’ll include exact github.* variables you should use), plus the exact JSON payload for the Cursor API; or

produce a complete agent prompt + an adjustable 14-point checklist you can drop into Cursor; or

outline a self-hosted MCP hardening checklist (docker config, secrets rotation, code pinning, CI tests for MCP server code).

Which one should I generate now?

You said:
I don't have access to Cursor Background Agents.

I would like to manually intialise a review by providing a Github PR url inside the chat.

Then I would like Cursor to access the diff of the PR.

I would like to provide a set of Cursor rules as a guideline.

Optional: push comments to Github > directly in the PR as PR comments. Not as a general textual review in one place.
ChatGPT said:
Got it 👍 That changes the setup quite a bit — since you don’t have Cursor Background Agents, the workflow will be manual, chat-driven instead of fully automated. Let me break it down into a practical design:

1. What you want
Trigger: You paste a GitHub PR URL into Cursor’s chat.

Cursor action:

Fetch the PR diff (the “files changed” tab).

Apply a set of review rules you define (style, security, testing, docs, etc.).

Produce a review.

Optional: Post the findings inline as PR comments (not one big block).

2. Feasibility with Cursor today
Accessing the diff:

Cursor (Pro) can fetch files over the web if the repo is public.

For private repos, you need to connect Cursor to your GitHub account (via its built-in GitHub integration) so it can pull the diff. Cursor already has a “review PR” command if connected.

If Cursor can’t fetch diffs automatically, you can paste the raw diff (from https://github.com/<org>/<repo>/pull/<num>.diff) into the chat.

Applying rules:

Cursor lets you provide a review checklist or ruleset in your system prompt / pinned instruction. For example:

“When I provide a PR diff, check for: 1) security issues, 2) test coverage, 3) adherence to style guide, 4) missing docs, 5) API stability. Use concise, actionable comments.”

Posting inline comments:

Cursor itself won’t push inline comments unless it’s connected to GitHub with the right permissions.

Two options:

Semi-manual: Cursor generates a list of comments with file + line numbers → you paste them into GitHub.

Automated: Run a small GitHub Action or local script that takes Cursor’s JSON output (file/line/comment) and uses the GitHub PR Review Comments API to push them inline.

3. Suggested workflow (minimal setup)
Define rules (once, in a pinned message in Cursor):

Security (no secrets, unsafe eval, SQL injection)

Performance (no O(n²) in hot paths)

Style (follows team linter, naming, spacing)

Tests (new/changed functions have coverage)

Docs (public methods updated in docs/changelog)

Manual review session:

Paste PR URL or diff into Cursor.

Cursor applies rules, outputs structured JSON like:

[
  {
    "file": "src/utils/helpers.js",
    "line": 42,
    "comment": "Consider renaming this function to camelCase for consistency."
  },
  {
    "file": "src/auth/login.js",
    "line": 88,
    "comment": "Potential SQL injection risk: avoid string concatenation in queries."
  }
]
Push to GitHub (optional automation):

Local script using gh api or Python/Node hitting GitHub REST API:

gh api repos/:owner/:repo/pulls/:pr_number/comments \
  -f body="Potential SQL injection risk..." \
  -f path="src/auth/login.js" \
  -f line=88 \
  -f side=RIGHT
This turns Cursor’s output into inline PR comments.

4. Evaluation
Pros:

You stay in control (you paste PRs manually).

Cursor enforces your rules consistently.

You can decide whether to push comments automatically or manually.

Cons:

Not “hands-free” — you need to paste diffs and run a script if you want inline comments.

For private repos, Cursor needs GitHub integration to fetch PR diffs.

✅ This is actually a solid MVP before jumping into Background Agents. You get rule-driven reviews with Cursor’s LLM power, and if you later want full automation you can wrap it in MCP/agents.

Would you like me to draft the review ruleset (like a ready-to-copy “Cursor guideline prompt”), or would you prefer I show you the GitHub API script to take Cursor’s structured output and post inline comments automatically?

You said:
For some reason Cursor can't access my Github repo through the default settings, but I can access the PR with the GITHUB_TOKEN.

About pushing comments to Github: can that be done through the GITHUB MCP
ChatGPT said:
Ah — perfect, this clarifies a lot. Let’s unpack this carefully.

1. Accessing GitHub via Cursor without Background Agents
Since Cursor can’t access your repo directly, you can still feed it the PR diff manually:

GitHub exposes a raw diff URL for every PR:

https://github.com/<owner>/<repo>/pull/<PR_NUMBER>.diff
With the GITHUB_TOKEN, you can download this diff programmatically:

curl -H "Authorization: token $GITHUB_TOKEN" \
     -H "Accept: application/vnd.github.v3.diff" \
     https://github.com/<owner>/<repo>/pull/<PR_NUMBER>.diff \
     -o pr.diff
Then you can paste the diff into Cursor, or load it into Cursor’s chat if it accepts files.

This keeps the process manual but works reliably with private repos.

2. Pushing comments to GitHub
Here’s the key question: can this be done through the GitHub MCP?

GitHub MCP Capabilities
MCP (Model Context Protocol) is essentially a secure API layer that exposes GitHub data to AI agents.

If you have a GitHub MCP server configured with the right scopes, an AI agent (like Cursor) can:

read PRs and diffs

post PR comments directly (inline or general)

create suggestion branches/commits

The MCP server enforces access rules; the AI never gets your personal token directly.

So yes — if Cursor can talk to an MCP server that wraps your GitHub access, it can post inline PR comments programmatically using MCP APIs.

Limitations / considerations
Default MCP: GitHub’s public MCP (currently) may not be connected to your private repos, which explains why Cursor can’t access your repo.

Self-hosted MCP:

You can run your own MCP server in your environment.

MCP server can use the GITHUB_TOKEN for authentication and expose only the PRs you want to Cursor.

Cursor then communicates with the MCP server instead of GitHub directly.

Inline comments: MCP supports posting review comments at file + line level, just like the GitHub REST API.

3. Minimal architecture for your case
Cursor chat session → you provide:

PR URL or downloaded .diff

Set of rules / guidelines for review

Cursor agent → analyzes diff according to rules → produces structured output:

[
  { "file": "src/app.js", "line": 25, "comment": "Rename variable to camelCase" },
  { "file": "src/utils.js", "line": 87, "comment": "Missing unit test for this function" }
]
MCP server (self-hosted or GitHub MCP connected to your repo) → receives structured output → pushes comments inline to PR using repos/:owner/:repo/pulls/:pr_number/comments endpoint.

Optional: Automate step 2 → 3 with a local script or GitHub Action, so you just paste the PR URL once, Cursor returns structured review, and the MCP server posts the comments.

✅ Bottom line:

Cursor can’t natively push comments without either Background Agents or MCP access.

Using MCP + your GITHUB_TOKEN, you can safely let Cursor produce inline PR comments without giving it full repo access.

This also allows you to enforce rules, audit every action, and stay secure.

If you want, I can draw a concrete workflow diagram + script example that shows:

You paste PR URL → Cursor produces structured comments → MCP server posts inline comments.

This would be a fully functioning MVP for your use case without requiring Background Agents.

Do you want me to do that?

You said:
How can I use the Github MCP
ChatGPT said:
Perfect — let’s go step by step. I’ll explain how to use GitHub MCP in your context: to let an AI (like Cursor) access PRs and optionally post inline comments, safely.

1. What GitHub MCP is
MCP = Model Context Protocol.

It’s a secure API layer between your AI agent and GitHub.

Provides controlled access: AI can read PRs, diffs, files, and optionally post comments without direct GitHub credentials.

You can run it self-hosted or use GitHub’s experimental MCP server (if available).

2. Key components
MCP Server

The “gateway” to your GitHub repo.

Handles authentication (GITHUB_TOKEN) and enforces permissions.

Exposes only the resources you want to AI agents.

AI Agent / LLM (Cursor)

Sends structured requests to MCP.

Can request: PR diff, file contents, or create inline comments.

MCP ensures the AI can only do what you allow.

GitHub repo

MCP connects to your repo using a token with minimal scopes:

pull_request read/write (for posting comments)

contents: read (for diffs or file access)

Optional: repo or workflow depending on your needs.

3. Step-by-step setup
Step 1: Create a GitHub token
Go to Settings → Developer settings → Personal access tokens → Tokens (classic)

Minimum scopes:

repo: read/write
repo: pull_request
Copy the token.

Step 2: Deploy / connect to MCP server
Option A: Use GitHub’s MCP (if available for your account)

Some accounts / enterprise orgs can enable GitHub MCP.

Check GitHub MCP docs.

Option B: Self-host MCP server (recommended for private repos)

Clone GitHub’s MCP server repository:

git clone https://github.com/github/mcp-server.git
Configure .env or config file with:

GITHUB_TOKEN=your_personal_token
PORT=3000
Run MCP server (docker or node):

npm install
npm run start
MCP server now exposes endpoints like:

GET /repos/:owner/:repo/pulls/:pr_number/diff

POST /repos/:owner/:repo/pulls/:pr_number/comments

The MCP server is now your secure gateway for AI agents.

Step 3: Connect Cursor to MCP
In Cursor, go to Settings → Integrations → MCP server

Enter the MCP server URL and any auth credentials (if configured)

Cursor can now request:

PR diff: GET /diff

File contents: GET /file?path=<path>

Create comments: POST /comments

Step 4: Using MCP to post inline comments
Cursor can now send structured JSON like:

[
  {
    "file": "src/app.js",
    "line": 42,
    "side": "RIGHT",
    "comment": "Consider renaming this function to camelCase for consistency"
  }
]
MCP converts it to GitHub API calls:

POST /repos/:owner/:repo/pulls/:pr_number/comments
path: file path

line: line number

side: LEFT/RIGHT (diff side)

body: comment text

This creates inline comments directly in the PR.

Step 5: Workflow
You paste PR URL into Cursor.

Cursor fetches diff via MCP (GET /diff).

Cursor analyzes diff based on your rules.

Cursor outputs structured comments → MCP posts them inline in GitHub.

✅ This is fully manual-trigger but secure and audit-able.

Notes / best practices
Least privilege: token should only allow what’s necessary.

Audit: MCP logs all requests.

Private repos: MCP server handles authentication safely.

Optional automation: You can wrap Cursor → MCP → GitHub in a script or GitHub Action to reduce manual steps.

I can also draw a diagram + example request flow showing:

[You] → [Cursor Chat] → [MCP server] → [GitHub PR comments]
This usually helps visualize how to paste the PR and push comments.

Do you want me to create that diagram and an example JSON payload for posting inline comments?




No file chosenNo file chosen
ChatGPT can make mistakes. Check important info. See Cookie Preferences.
