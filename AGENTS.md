# Mikhmon V3 — MikroTik Hotspot Manager

PHP web app for managing MikroTik hotspot users, vouchers, and reports. Talks to RouterOS over its API.

## Architecture

- **Entry points**: `admin.php` (admin panel — login, router config), root `index.php` (dashboard after connecting to a router).
- **No database**. All router config stored as PHP arrays in `include/config.php`. Editing this file directly is possible but error-prone.
- **RouterOS API**: `lib/routeros_api.class.php` connects to MikroTik on port 8728 (default). Every feature page calls `$API->comm(...)` directly.
- **Auth**: session-based (`$_SESSION["mikhmon"]`). Admin creds stored in `include/config.php` (base64-encoded password).
- **Config parsing**: `include/readcfg.php` uses delimiter-based string splitting (`!`, `@|@`, `#|#`, `%`, `^`, `&`, `*`, `(`, `)`, `=`, `+`, `@!@`).
- **Error reporting**: `error_reporting(0)` everywhere — all PHP errors hidden.

## Directory layout

| Directory | Purpose |
|-----------|---------|
| `hotspot/` | User CRUD, profile management, generate users, active sessions, hosts, IP bindings, cookies, logs |
| `voucher/` | Voucher print templates (default, small, thermal) |
| `settings/` | Router settings, admin settings, logo upload, template editor |
| `process/` | Backend actions: remove/disable/enable/reset users, reboot/shutdown router |
| `dashboard/` | Home dashboard with system info, resource usage, traffic charts |
| `report/` | Sales reports, user logs, live reports, resume reports |
| `traffic/` | Traffic monitoring (Highcharts) |
| `system/` | System scheduler |
| `include/` | Config, login, menu, theme, lang loader, head HTML |
| `lib/` | RouterOS API client, byte formatting utilities |
| `lang/` | i18n: en, id (Indonesian), es, tl (Tagalog), tr (Turkish) |
| `css/` | Theme CSS: blue, dark, green, light, pink |
| `js/` | jQuery, Highcharts, QRious (QR code), pace (loader), per-theme UI JS |

## Quick start (Docker test lab)

```bash
docker-compose up -d
# Mikhmon:   http://localhost:8080   (user: mikhmon, pass: 1234)
# RouterOS:  http://localhost:8081   (IP: 192.168.88.1, pass: 12345)
# RouterOS API at 172.27.0.7:8728 (add in Mikhmon: IP 172.27.0.7, user admin, pass 12345)
docker-compose down
```

Standalone: PHP 7.4+ with any web server (nginx config in `nginx.conf`). Just serve the directory.

## Render deployment

Free-tier deploy via Docker. Uses `Dockerfile`, `entrypoint.sh`, `supervisord.conf`.

Set `GENERATE_CONFIG=true` and supply `ROUTER_IP`, `ROUTER_PASS` as env vars — entrypoint generates `include/config.php` at boot. Settings changed in the UI survive until the next deploy (config regenerates from env vars). Logo uploads are ephemeral; use `LOGO_URL` env var to pull from an external URL.

Env vars are the source of truth. To change config, update Render env vars and redeploy.

## Key quirks

- `include/config.php` is both config file and writable target — saving settings in the UI rewrites this PHP file via `str_replace` on delimiter patterns. **Do not manually reformat this file.**
- Password is encrypted via `encrypt()`/`decrypt()` functions (base64-based, not cryptographically secure).
- Session name (router config key) cannot contain spaces or special chars: `_!@#$%^&*()+=;|?,~` are rejected client-side.
- Generate users uses `ini_set('max_execution_time', 300)` — bulk generation can be slow on large routers.
- Voucher templates use `<?= $qrcode ?>`, `<?= $username ?>`, `<?= $password ?>`, `<?= $price ?>` PHP variables.
- Idle timeout: can be set in seconds per-session; when enabled, shows a countdown timer in the navbar.
- Live report: per-session enable/disable toggle.
- No Composer, npm, or build step. No tests. No CI/CD.
