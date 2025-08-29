# DeltaSync PowerShell Module

## Overview

DeltaSync is a PowerShell module designed to automate the initiation of a delta synchronization cycle on the active Azure AD Connect server. It identifies the active server in a multi-server setup, waits for any ongoing synchronization to complete, and then triggers a delta sync.

## Features

- Automatically detects the active Azure AD Connect server
- Waits for any ongoing sync cycles to finish before initiating a new one
- Provides verbose logging for monitoring and troubleshooting
- Configurable sleep interval between sync status checks

## Requirements

- PowerShell 5.1 or later
- Remote access to Azure AD Connect servers via PowerShell remoting
- `Get-ADSyncScheduler` and `Start-ADSyncSyncCycle` cmdlets available on target servers

## Installation

### Manual Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/acelaya77/Start-AdConDeltaSync.git
   ```
2. Run the installer script:
   ```PowerShell
   .\Install-DeltaSyncModule.ps1 -ImportAfterInstall
   ```

### PowerShell Gallery (Coming Soon)

Once published, you can install via:

```PowerShell
Install-Module AdConDeltaSync -Scope CurrentUser
```

### Usage

```PowerShell
Start-AdConDeltaSync -SleepTimeSeconds 10 -Verbose
```

### Parameters

- Servers: Servers to operate with. Example: `-Servers @('adcon1.domain.net','adcon2.domain.net')`
- SleepTimeSeconds: Number of seconds to wait between sync status checks. Default is 8.

### Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your improvements.

### License

This project is licensed under the MIT License. See the LICENSE file for details.

### Author

Anthony J. Celaya
