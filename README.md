# 🏆 GitHub Copilot | GitHub Copilot CLI for Microsoft FTEs

This beginner-friendly guide walks you through setting up GitHub Copilot in **VS Code** and installing **GitHub Copilot CLI**, to include, how to configure **MCP servers** (Model Context Protocol) for richer, tool-backed prompts.

> Tip: Keep your personal GitHub account secure (strong password + 2FA) since it becomes your primary identity for Copilot access.

---
## What can GitHub Copilot CLI do??

[GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli)

## 0. Set up NodeJS and a GitHub account (if needed)

1. Install NodeJS here: https://nodejs.org/en
   
   🏁 Run the installer

		During setup:
		✅ Leave npm package manager checked
		✅ Leave Add to PATH checked
		✅ Accept defaults (don’t overthink it)
		
		Finish the install.
3. Create a GitHub account: https://github.com/
4. Install the GitHub Mobile app on your mobile device.
5. Enable 2FA (two-factor authentication) on your GitHub account.
   - Recommended: configure 2FA so you can approve sign-ins from the mobile app.

Helpful link:
- GitHub 2FA docs: https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa

---

## 1. Set up GitHub Copilot (Microsoft FTE flow)

### Link your Microsoft corporate identity with your personal GitHub account

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
   
   ✅ **GitHub Copilot** <br/>
   ✅ **GitHub Copilot Chat** <br/>
   ✅ **GitHub Copilot for Azure** <br/>

### Sign in (VS Code Accounts)

1. In VS Code, open **Accounts** (person icon) → sign in.
2. Sign in using the **personal GitHub account** that you linked to your Microsoft corporate account.

### Verify Copilot Chat + model selector

1. Open the **GitHub Copilot Chat** panel (chat icon near the top right, next to the search bar area).
2. You should see multiple frontier models available (for example: **GPT-5.2**, **GPT-5.2 Codex**, **Claude Sonnet 4.5**, **Claude Opus 4.5**, **Gemini**, etc.).
3. If you do — congratulations. You’re ready to use Copilot Chat with multiple model options.

**🟢 GITHUB -> SETTINGS -> BILLING/LICENSING -> LICENSING: YOU SHOULD SEE THIS 🟢**
<img width="1053" height="800" alt="image" src="https://github.com/user-attachments/assets/37606a6a-64c7-4452-89ac-25a37be8fa23" />

**🟢 VSCODE: YOU SHOULD SEE THIS 🟢**
<img width="1150" height="1119" alt="image" src="https://github.com/user-attachments/assets/5499c6da-ab6e-46cf-b64b-565cf518dbd9" />

---

## 2.5 Add MCP Servers to GitHub Copilot in VS Code

MCP servers allows GitHub Copilot Chat call trusted tools and retrieve grounded information (docs, browser automation, etc).

<img width="1377" height="1200" alt="image" src="https://github.com/user-attachments/assets/efe890e8-b2f0-45f8-9043-9d27c25f6ad8" />


### File path

Create or edit this file:

- `C:\Users\%USERNAME%\AppData\Roaming\Code\User\mcp.json`

### Copy/paste this JSON into `mcp.json`

> Security note: If you use Context7, do **not** paste your real key into shared docs. Keep it local.
> Configuration note: The format / structure for mcp.json is **different** than mcp-config.json (GitHub Copilot CLI)
```json
{
	"servers": {
		"playwright": {
			"command": "npx",
			"args": [
				"@playwright/mcp@latest"
			],
			"type": "stdio"
		},
		"context7": {
			"type": "http",
			"url": "https://mcp.context7.com/mcp",
			"headers": {
				"CONTEXT7_API_KEY": "ADD_YOUR_API_KEY_HERE"
			}
		},
		"Microsoft Learn - MCP": {
			"type": "http",
			"url": "https://learn.microsoft.com/api/mcp",
			"gallery": "https://api.mcp.github.com",
			"version": "1.0.0"
		}
	},
	"inputs": []
}
```

Obtain context7 API KEY
- Go to context7 and create an account to obtain an API KEY and insert that key into your mcp.json and mcp-config.json files
- Context7: https://context7.com/

Optional next steps (common troubleshooting):
- Restart VS Code after editing `mcp.json`.
- If a server requires Node, install a recent Node.js LTS.
- If a tool requires corporate access (tenant / permissions), it may not work outside your environment.

---

## 3. Install PowerShell 7 (recommended)

1. Install **PowerShell 7** from the Microsoft Store.
2. Set **PowerShell 7** as the default profile:
   - Open **Windows Terminal** → **Settings** → **Default profile** → select **PowerShell 7** → **Save**

<img width="1300" height="516" alt="image" src="https://github.com/user-attachments/assets/017bdc73-e022-42aa-8852-5399ef15ad78" />


---

## 4. Install GitHub Copilot CLI

<img width="1602" height="753" alt="image" src="https://github.com/user-attachments/assets/b546b6bd-1e9c-4717-9ee6-86807145abcf" />


### Confirm Copilot access

1. Go to: https://copilot.github.microsoft.com/
2. Confirm it recognizes you as connected/eligible for GitHub Copilot.

### Install GitHub Copilot CLI via winget

Open **PowerShell 7** and run:

```powershell
winget install github.copilot
```

Run **GitHub Copilot CLI** 

```powershell
copilot
```

Run **GitHub Copilot CLI w/ the fancy banner 😎**
```powershell
copilot --banner
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

---

## 5. GitHub Copilot CLI How-To's

- https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli

## 6. Join the Microsoft AI Community of Interest

- https://aka.ms/garage/skillupai
- Watch Scott Hanselman harness the power of GitHub Copilot CLI w/ MCP and Copilot Skills & [Handy](https://handy.computer/)

---

## Additional resources

- Microsoft GitHub Copilot SDK
  - https://github.blog/news-insights/company-news/build-an-agent-into-any-app-with-the-github-copilot-sdk/
- Microsoft PowerShell Azure Module (Az)
  - https://learn.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-15.2.0
- Microsoft Graph MCP Server overview:
  - https://learn.microsoft.com/en-us/graph/mcp-server/overview
- Microsoft Sentinel (data lake) MCP overview:
  - https://learn.microsoft.com/en-us/azure/sentinel/datalake/sentinel-mcp-overview
- GitHub Copilot documentation:
  - https://docs.github.com/en/copilot
- John Saville YouTube Channel
  - https://www.youtube.com/@NTFAQGuy
- Azure Friday's
  - https://azurefriday.com/
