# Mission Command
### Close, minimize and do other actions within Mission Control!
Similar features to [Mission Control Plus](https://www.fadel.io/missioncontrolplus), and Mission Control Actions in [Supercharge](https://sindresorhus.com/supercharge), with more coming soon!
- Supports customizable Keyboard shortcuts
- Close windows with middle click like in KDE
- Visual buttons coming soon™

## Installation
1. Download from releases
2. Bypass gatekeeper in system settings or using `xattr -c <path>`
3. Allow accessibility in system settings
4. Disable the previous projects if you had them installed (and stop them from running on startup if prefered)
5. Relaunch app (Might be hard so just do `killall Mission\ Command` from terminal)

## Planned Features / Bugfixes
- Close other windows
- Minimize other windows
- Update positions when spaces bar expands
- Remove old windows' space from mission control (unlikely)
- Visual X window (multiple styles)
- Stop certain apps from reopening if they get focused (Apps that don't release their windows)

## Building For Yourself
- Wait for SPM to download stuff
- Set your developer id in project settings
- Build

## License
Licensed under the BSD Zero-clause license because I took some code from one of my unreleased projects.
