# PalladiumXP (PXP) remote access through jump server

Current network path:

```text
Current Windows PC --VNC--> <jump-host> --SSH--> <pxp-host> PXP
```

Important constraint:

```text
Current Windows PC cannot SSH to <jump-host>.
<jump-host> is reachable only through VNC.
```

Because of this, `<jump-host>` cannot be used as a normal inbound SSH jump host from the current Windows PC. The safe baseline workflow is to operate inside the VNC desktop on `<jump-host>`, then SSH from there to PXP.

The `setup-pxp-jump.ps1` script below is only useful if SSH from the current Windows PC to `<jump-host>:22` is later allowed.

## 1. Recommended VNC-only workflow

Through VNC, open a terminal on `<jump-host>`, then connect to PXP:

```bash
ssh <pxp-user>@<pxp-host>
```

After logging in to PXP, go to the floating-point test case directory:

```bash
cd /path/to/float_case
```

Search common error keywords:

```bash
grep -RniE "error|fatal|fail|mismatch|nan|inf" .
```

Follow a running log:

```bash
tail -f /path/to/log/file.log
```

Find recent logs:

```bash
find . -type f \( -name "*.log" -o -name "*.out" -o -name "*.err" \) -mtime -7 -print
```

If the floating-point case is stored on `<jump-host>` instead of PXP, use the VNC desktop editor or terminal directly on `<jump-host>`.

## 2. Convenience option without changing <jump-host> firewall

If security policy allows `<jump-host>` to initiate outbound SSH connections to the current Windows PC, you can use a reverse SSH tunnel:

```text
<jump-host> -> current Windows PC
```

This does not require opening inbound SSH on `<jump-host>`.

High-level flow:

1. Enable or install OpenSSH Server on the current Windows PC.
2. Allow the Windows PC firewall to accept SSH from `<jump-host>`.
3. In the VNC terminal on `<jump-host>`, run:

```bash
ssh -N -R 2222:<pxp-host>:22 <windows-user>@<current-windows-pc-host>
```

4. On the current Windows PC, connect to PXP through the reverse tunnel:

```powershell
ssh -p 2222 <pxp-user>@localhost
```

Only use this option if it is approved by your network/security policy.

## 3. SSH jump workflow if policy changes later

Use `<jump-host>` as the SSH jump server only if SSH from the current Windows PC to `<jump-host>:22` is allowed.

### Install SSH aliases

Run this in PowerShell from this project directory:

```powershell
.\setup-pxp-jump.ps1
```

The script asks for:

- Username for jump server `<jump-host>`
- Username for PXP `<pxp-host>`

It writes this managed block to `%USERPROFILE%\.ssh\config`:

```sshconfig
Host pxp-gateway
    HostName <jump-host>
    User <jump-server-user>

Host pxp
    HostName <pxp-host>
    User <pxp-user>
    ProxyJump pxp-gateway
```

If an SSH config already exists, the script creates a timestamped backup before updating it.

### Test connections

First test the jump server:

```powershell
ssh pxp-gateway
```

Then test PXP through the jump server:

```powershell
ssh pxp
```

Equivalent one-shot command without config:

```powershell
ssh -J <jump-server-user>@<jump-host> <pxp-user>@<pxp-host>
```

### View code and logs

After `ssh pxp`, go to the floating-point test case directory:

```bash
cd /path/to/float_case
```

Search common error keywords:

```bash
grep -RniE "error|fatal|fail|mismatch|nan|inf" .
```

Follow a running log:

```bash
tail -f /path/to/log/file.log
```

Copy logs back to Windows:

```powershell
scp pxp:/path/to/case/logs/run.log .
```

Copy a whole result directory:

```powershell
scp -r pxp:/path/to/case/results .
```

### VS Code Remote SSH

After the SSH aliases work:

1. Install the VS Code extension "Remote - SSH".
2. Run "Remote-SSH: Connect to Host...".
3. Choose `pxp`.
4. Open the floating-point test case directory on PXP.

If the test case is actually stored on `<jump-host>`, connect VS Code to `pxp-gateway` instead.

### If `ssh pxp-gateway` fails

If the current PC only has VNC access to `<jump-host>`, this is expected:

```text
ssh: connect to host <jump-host> port 22: Connection timed out
```

In that case, use the VNC-only workflow above.
