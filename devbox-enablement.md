# Microsoft Dev Box Enablement Guide

Use this guide before the main GitHub Copilot Enterprise setup if you want a cloud-hosted workstation for the enablement work.

Microsoft Dev Box gives you a ready-to-use Windows development environment that runs in the cloud. Instead of installing and running every tool on your personal machine, you can connect to a dev box from the Windows App or a browser, set up GitHub Copilot there, and keep your local hardware available for everyday work.

## Why Start With Dev Box?

Choose Dev Box first if any of these sound familiar:

1. Your local machine is older, storage-constrained, or already running hot during build, indexing, or GenAI-assisted workflows.
2. You want an "always on" workspace that can keep your tools, repo, terminal history, and VS Code setup in one place.
3. You move between devices and want your AI-enabled workspace to meet you anywhere you have an Internet connection.
4. You want to keep heavy installs, experiments, automation, and repo setup away from your personal hardware.

For GitHub Copilot enablement, this is especially useful because VS Code, extensions, Node.js, Git, MCP servers, browser automation, and CLI tools can all live inside the dev box. Your laptop becomes the window into the environment instead of the machine doing all the work.

## What You Need

Before you can create or use a dev box, your organization must already have a Dev Box project and pool available to you. You also need permission to create or access a dev box in that project.

For Microsoft Federal users, follow this guidance, start with this access path:

[Dev Box access via CSS-SSD MyAccess](https://aka.ms/CSS-SSD/MyAccess)

If you do not see an available project, pool, or dev box option after access is granted, contact your local admin or project owner and ask whether you have Dev Box User access.

## Friendly Setup Flow

### 1. Request Access

1. Open [Dev Box access via CSS-SSD MyAccess](https://aka.ms/CSS-SSD/MyAccess).
2. Follow the access request flow for the secure group or site path provided by your organization.
3. Wait for approval before trying to create or connect to a dev box.

### 2. Open the Developer Portal

After access is approved, open the Microsoft Dev Box developer portal:

[Microsoft Dev Box developer portal](https://aka.ms/devbox-portal)

From the portal, you should be able to see the dev box projects and pools available to your account.

### 3. Create a Dev Box

1. In the developer portal, select **New dev box**.
2. Choose the project and pool that matches your team or workload.
3. Give the dev box a simple name, such as `ghcp-workstation`.
4. Create the dev box and wait for provisioning to complete.

If your organization already created a dev box for you, skip this step and connect to the existing dev box tile.

### 4. Connect From Wherever You Work

You can connect in two common ways:

1. **Windows App** - Best for a full desktop experience, multi-monitor use, and regular daily work.
2. **Browser** - Useful for quick access from a device where you do not want to install anything.

In the developer portal, select **Connect via app** on the dev box tile to use the Windows App, or open the connection menu and choose the browser option if your environment allows it.

### 5. Install Your GitHub Copilot Enablement Tools Inside Dev Box

Once connected, treat the dev box like your setup machine for the rest of the enablement process.

Recommended order:

1. Install PowerShell 7.
2. Install Visual Studio Code.
3. Install Git for Windows.
4. Install Node.js LTS.
5. Sign in to VS Code with the personal GitHub account linked to your Microsoft corporate account.
6. Continue with the main GitHub Copilot Enterprise setup guide.

Main guide: [README.md](README.md)

## Daily Use Tips

1. Keep the dev box focused on work setup, repos, automation, and AI tooling.
2. Use Windows App when you expect to work for a while, especially with VS Code and terminal sessions.
3. Use browser access for quick checks, pull request reviews, or small edits.
4. Shut down, hibernate, or restart the dev box from the developer portal when your organization expects cost-conscious usage.
5. If your dev box supports snapshots or restore points, use them before major experiments.

## Quick Troubleshooting

| Symptom | What To Check |
| --- | --- |
| You cannot see any projects or pools | Confirm the access request was approved and that you have Dev Box User permissions. |
| The dev box tile exists but will not connect | Try the browser option, then use the portal's troubleshoot or repair action if available. |
| Windows App does not show the dev box | Sign in with the same Microsoft account used in the developer portal. |
| Tool installs feel blocked | Check whether your dev box image or organization policy restricts admin rights or software installation. |
| Performance feels slow | Verify network quality, close unused apps in the dev box, and ask whether a larger pool/SKU is available for your workload. |

## Helpful Links

1. [Dev Box access via CSS-SSD MyAccess](https://aka.ms/CSS-SSD/MyAccess)
2. [Microsoft Dev Box developer portal](https://aka.ms/devbox-portal)
3. [Microsoft Dev Box overview](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box)
4. [Use the Microsoft Dev Box developer portal](https://learn.microsoft.com/en-us/azure/dev-box/how-to-create-dev-boxes-developer-portal)
5. [Windows App](https://apps.microsoft.com/detail/9n1f85v9t8bn)

## Next Step

After your dev box is ready, continue with the main enablement process:

[GitHub Copilot Enterprise setup guide](README.md)