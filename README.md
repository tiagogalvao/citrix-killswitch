# Citrix Workspace - KillSwitch

Turn **Citrix App Protection** off when you're done working and back on when you need it, with just a double-click. Usually requires reboot to disable, but enabling it back usually requires no reboot.

Citrix Workspace's App Protection feature installs two drivers (`ctxapinject` and `ctxapdriver`). They hook into **every process** on the machine to block screen capture and keylogging. That's what your employer wants during a work session. Outside of work, the same hooks can get in the way of games, anti-cheat, screen recorders, overlays and screenshot tools. This repo has three small batch scripts that switch between the two states cleanly.

| Script | What it does |
| --- | --- |
| `Game-Mode (Citrix App Protection OFF).cmd` | Disables both drivers, closes Citrix Workspace, and stops the drivers live |
| `Work-Mode (Citrix App Protection ON).cmd` | Restores the original driver start types and starts the drivers live |
| `Check-Mode.cmd` | Shows which mode you're in and warns if a restart is still pending |

## Requirements

- Windows with Citrix Workspace app and App Protection installed
- Administrator rights (the scripts ask for elevation themselves)

## Usage

1. Download or clone the repo.
2. Double-click the script you need. Approve the UAC prompt.
3. Run `Check-Mode.cmd` any time you're unsure of the current state.

### Game Mode (App Protection OFF)

- Asks you to confirm first, since it **force-closes Citrix Workspace**. Save your work and end your session before running it.
- Sets both drivers to `disabled`, so they stay off across restarts.
- Kills the Citrix Workspace processes and tries to stop the drivers immediately.
- If Windows won't stop them live, it offers to restart. The drivers will be off after the reboot.

> Programs that were already running before you switched still have the Citrix DLL loaded. Restart them, or reboot, for a fully clean state.

### Work Mode (App Protection ON)

- Restores the default start types: `ctxapinject` → `system`, `ctxapdriver` → `auto`.
- Closes Citrix Workspace if it's open, then starts both drivers live.
- If Windows won't start them live, it offers to restart.
- Afterwards, start Citrix Workspace again. Programs launched from that point on are protected. **A restart is still the safest way** to make sure everything already open is covered too.

### Check Mode

Reads the start type and current state of `ctxapinject` and reports:

- **ON - Work mode**: the driver is running.
- **OFF - Game mode**: the driver is stopped.
- A warning if the configured mode and the running state disagree, which means a restart (or a re-run) is needed to finish switching.

## Under the hood

The scripts only use built-in Windows tools (`sc`, `taskkill`, `net session`, `choice`, `shutdown`). Nothing is installed, downloaded or deleted. The only thing they change is the `Start` value of two services:

| Service | Work mode (default) | Game mode |
| --- | --- | --- |
| `ctxapinject` | `1` (system) | `4` (disabled) |
| `ctxapdriver` | `2` (auto) | `4` (disabled) |

### If a script says "Access is denied"

Some Citrix versions protect their own service entries. In that case set the values by hand in `regedit`:

```
HKLM\SYSTEM\CurrentControlSet\Services\ctxapinject   Start
HKLM\SYSTEM\CurrentControlSet\Services\ctxapdriver   Start
```

Use `4` for Game mode, or `1` / `2` (respectively) for Work mode, then restart.

## ⚠️ Be responsible

App Protection is a security control your organization chose to enable. These scripts are meant for **your own machine, outside working hours**:

- Always switch back to **Work Mode** before you connect to a work session.
- Your Citrix environment may refuse to launch protected apps, or may report that protection is missing, while it's off.
- Check your employer's IT and acceptable-use policies before using this. You're responsible for how you use it.

## License

[MIT](LICENSE)
