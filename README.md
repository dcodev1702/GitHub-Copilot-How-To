# GitHub Copilot and GitHub Copilot CLI for Microsoft FTEs

This beginner-friendly guide walks you through getting GitHub Copilot working in **VS Code** and installing **GitHub Copilot CLI**, plus how to configure **MCP servers** (Model Context Protocol) for richer, tool-backed prompts.

> Tip: Keep your personal GitHub account secure (strong password + 2FA) since it becomes your primary identity for Copilot access.

---

## 0. Set up a GitHub account

1. Create a GitHub account: https://github.com/
2. Install the GitHub Mobile app.
3. Enable 2FA (two-factor authentication) on your GitHub account.
   - Recommended: configure 2FA so you can approve sign-ins from the mobile app.

Helpful link:
- GitHub 2FA docs: https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa

---

## 1. Set up GitHub Copilot (Microsoft FTE flow)

### Link your Microsoft corporate identity to your personal GitHub account

1. Link accounts here: https://repos.opensource.microsoft.com/link
2. Follow this walkthrough (VS Code + Copilot setup):
   - https://github.com/mcaps-microsoft/Getting-Started-with-GitHub-Copilot-and-VSCode/blob/main/Getting_Started_with_GitHub_Copilot_and_VSCode.md

Notes:
- If access doesn’t appear immediately, wait a bit and try signing out/in again.

---

## 2. VS Code integration with GitHub Copilot

### Install the right extensions

1. Open **VS Code** → **Extensions**.
2. Install:
   - **GitHub Copilot**
   - **GitHub Copilot Chat**

### Sign in (VS Code Accounts)

1. In VS Code, open **Accounts** (person icon) → sign in.
2. Sign in using the **personal GitHub account** that you linked to your Microsoft corporate account.

### Verify Copilot Chat + model picker

1. Open the **GitHub Copilot Chat** panel (chat icon near the top right, next to the search bar area).
2. You should see multiple frontier models available (for example: **GPT-5.2**, **GPT-5.2 Codex**, **Claude Sonnet 4.5**, **Claude Opus 4.5**, **Gemini**, etc.).
3. If you do — congratulations. You’re ready to use Copilot Chat with multiple model options.

---

## 2.5 Add MCP Servers to GitHub Copilot in VS Code

MCP servers let Copilot Chat call trusted tools and retrieve grounded information (docs, browser automation, etc.).

### File path

Create or edit this file:

- `C:\Users\%USERNAME%\AppData\Roaming\Code\User\mcp.json`

### Copy/paste this JSON into `mcp.json`

> Security note: If you use Context7, do **not** paste your real key into shared docs. Keep it local.

```json
{
  "mcpServers": {
    "WorkIQ": {
      "command": "npx",
      "args": [
        "-y",
        "@microsoft/workiq",
        "mcp"
      ],
      "tools": ["*"]
    },
    "MicrosoftLearn": {
      "type": "http",
      "url": "https://learn.microsoft.com/api/mcp",
      "tools": ["*"]
    },
    "Playwright": {
      "type": "stdio",
      "command": "npx",
      "args": ["@playwright/mcp@latest"],
      "tools": ["*"]
    },
    "Context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp",
      "headers": {
        "CONTEXT7_API_KEY": "ADD_YOUR_API_KEY_HERE"
      },
      "tools": ["*"]
    }
  }
}
```

Optional next steps (common troubleshooting):
- Restart VS Code after editing `mcp.json`.
- If a server requires Node, install a recent Node.js LTS.
- If a tool requires corporate access (tenant / permissions), it may not work outside your environment.

### Add Aspire (SQL MCP Server) as an MCP server

If you’re using **.NET Aspire** to run a local **SQL MCP Server** (powered by Data API builder), the MCP endpoint is an **HTTP URL that ends in `/mcp`**.

Important notes:
- If you’re running via Aspire, the **host port can be dynamic**. The easiest way to get the exact URL is:
  1. Run `aspire run`
  2. Open the Aspire dashboard
  3. Find the `sql-mcp-server` resource
  4. Click the **MCP** link and copy the full URL (it should end with `/mcp`)

Official quickstarts:
- .NET Aspire: https://learn.microsoft.com/en-us/azure/data-api-builder/mcp/quickstart-dotnet-aspire
- VS Code (local): https://learn.microsoft.com/en-us/azure/data-api-builder/mcp/quickstart-visual-studio-code

#### MCP config snippet (add to your existing `mcpServers`)

The docs’ default local endpoint is typically `http://localhost:5000/mcp` (replace the port if Aspire shows a different one):

```json
"AspireSqlMcpServer": {
  "type": "http",
  "url": "http://localhost:5000/mcp",
  "tools": ["*"]
}
```

---

## 3. Join the GitHub Copilot CLI Teams channel

Join here:
- https://teams.microsoft.com/l/channel/19%3A3a10724f969043c3aab0d68a939500d1%40thread.tacv2/Copilot%20CLI?groupId=5f134ecd-5789-499a-b782-1f6f2dec34de&tenantId=72f988bf-86f1-41af-91ab-2d7cd011db47

---

## 4. Install PowerShell 7 (recommended)

1. Install **PowerShell 7** from the Microsoft Store.
2. Set it as the default profile:
   - Open **Windows Terminal** → **Settings** → **Default profile** → select **PowerShell 7** → **Save**

---

## 5. Install GitHub Copilot CLI

### Confirm Copilot access

1. Go to: https://copilot.github.microsoft.com/
2. Confirm it recognizes you as connected/eligible for Copilot.

### Install via winget

Open **PowerShell 7** and run:

```powershell
winget install github.copilot
```

### Sign in and select a model

1. Open the Copilot CLI experience and sign in when prompted.
2. Select your preferred model. Example (as used in many demos):

```text
/model claude-opus-4.5
```

> Tip: If you’re not sure which command starts the CLI on your machine, run `copilot --help` after installation and follow the sign-in prompts it provides.

### Configure MCP for Copilot CLI

Create or edit this file:

- `C:\Users\%USERNAME%\.copilot\mcp-config.json`

Copy/paste this JSON into `mcp-config.json` (Context7 key omitted):

```json
{
  "mcpServers": {
    "WorkIQ": {
      "command": "npx",
      "args": [
        "-y",
        "@microsoft/workiq",
        "mcp"
      ],
      "tools": ["*"]
    },
    "MicrosoftLearn": {
      "type": "http",
      "url": "https://learn.microsoft.com/api/mcp",
      "tools": ["*"]
    },
    "Playwright": {
      "type": "stdio",
      "command": "npx",
      "args": ["@playwright/mcp@latest"],
      "tools": ["*"]
    },
    "Context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp",
      "headers": {
        "CONTEXT7_API_KEY": "ADD_YOUR_API_KEY_HERE"
      },
      "tools": ["*"]
    }
  }
}
```

### Optional: Add Aspire (SQL MCP Server) to Copilot CLI

If you’re running the SQL MCP Server locally (whether via **Aspire** or `dab start`), you can add it to Copilot CLI by inserting this entry into the same `mcpServers` object:

```json
"AspireSqlMcpServer": {
  "type": "http",
  "url": "http://localhost:5000/mcp",
  "tools": ["*"]
}
```

If you launched it via Aspire and the port is not 5000, copy the MCP URL from the Aspire dashboard and update the `url` value (it must end with `/mcp`).

---

## 6. Join the Microsoft AI Community of Interest

- https://aka.ms/garage/skillupai

---

## 7. Watch Scott Hanselman harness GitHub Copilot CLI

- https://microsoft.sharepoint.com/teams/GarageCentral/_layouts/15/stream.aspx?id=%2Fteams%2FGarageCentral%2FVideos%2FThe+Garage+Recordings%2FTwitch+But+Internal-20260123_234519UTC-Meeting+Recording.mp4&nav=eyJyZWZlcnJhbEluZm8iOnsicmVmZXJyYWxBcHAiOiJTdHJlYW1XZWJBcHAiLCJyZWZlcnJhbFZpZXciOiJTaGFyZURpYWxvZy1MaW5rIiwicmVmZXJyYWxBcHBQbGF0Zm9ybSI6IldlYiIsInJlZmVycmFsTW9kZSI6InZpZXcifX0%3D&referrer=StreamWebApp.Web&referrerScenario=AddressBarCopied.view.823ace8b-bd9c-4db2-a854-89e53c730d89&ga=1&startedResponseCatch=true&isDarkMode=true

---

## Additional resources

- Microsoft Graph MCP Server overview:
  - https://learn.microsoft.com/en-us/graph/mcp-server/overview
- Microsoft Sentinel (data lake) MCP overview:
  - https://learn.microsoft.com/en-us/azure/sentinel/datalake/sentinel-mcp-overview
- GitHub Copilot documentation:
  - https://docs.github.com/en/copilot
