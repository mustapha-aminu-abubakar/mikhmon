#!/bin/sh
set -e

if [ "$GENERATE_CONFIG" = "true" ]; then
  ADMIN_USER="${ADMIN_USER:-mikhmon}"
  ADMIN_PASS="${ADMIN_PASS:-1234}"
  SESSION_NAME="${SESSION_NAME:-mikrotik}"
  ROUTER_IP="${ROUTER_IP:-}"
  ROUTER_USER="${ROUTER_USER:-admin}"
  ROUTER_PASS="${ROUTER_PASS:-}"
  HOTSPOT_NAME="${HOTSPOT_NAME:-MikroTik}"
  DNS_NAME="${DNS_NAME:-}"
  CURRENCY="${CURRENCY:-Rp}"
  AUTO_RELOAD="${AUTO_RELOAD:-10}"
  INTERFACE="${INTERFACE:-1}"
  INFO_LINE="${INFO_LINE:-}"
  IDLE_TIMEOUT="${IDLE_TIMEOUT:-10}"
  LIVE_REPORT="${LIVE_REPORT:-disable}"
  QR_BT="${QR_BT:-disable}"
  LOGO_URL="${LOGO_URL:-}"

  if [ -z "$ROUTER_IP" ] || [ -z "$ROUTER_PASS" ]; then
    echo "ERROR: ROUTER_IP and ROUTER_PASS env vars are required when GENERATE_CONFIG=true"
    exit 1
  fi

  INFO_HEX=$(printf '%s' "$INFO_LINE" | php -r 'echo bin2hex(stream_get_contents(STDIN));')
  ADMIN_ENC=$(printf '%s' "$ADMIN_PASS" | php -r '
    require "/var/www/lib/routeros_api.class.php";
    echo encrypt(stream_get_contents(STDIN));
  ')
  ROUTER_ENC=$(printf '%s' "$ROUTER_PASS" | php -r '
    require "/var/www/lib/routeros_api.class.php";
    echo encrypt(stream_get_contents(STDIN));
  ')

  cat > /var/www/include/config.php <<EOF
<?php
if(substr(\$_SERVER["REQUEST_URI"], -10) == "config.php"){header("Location:./");};
\$data['mikhmon'] = array ('1'=>'mikhmon<|<$ADMIN_USER','mikhmon>|>$ADMIN_ENC');
\$data['$SESSION_NAME'] = array (
  '1'=>'$SESSION_NAME!$ROUTER_IP',
  '2'=>'$SESSION_NAME@|@$ROUTER_USER',
  '3'=>'$SESSION_NAME#|#$ROUTER_ENC',
  '4'=>'$SESSION_NAME%$HOTSPOT_NAME',
  '5'=>'$SESSION_NAME^$DNS_NAME',
  '6'=>'$SESSION_NAME&$CURRENCY',
  '7'=>'$SESSION_NAME*$AUTO_RELOAD',
  '8'=>'$SESSION_NAME($INTERFACE',
  '9'=>'$SESSION_NAME)$INFO_HEX',
  '10'=>'$SESSION_NAME=$IDLE_TIMEOUT',
  '11'=>'$SESSION_NAME@!@$LIVE_REPORT'
);
EOF

  cat > /var/www/include/quickbt.php <<EOF
<?php \$qrbt="$QR_BT";?>
EOF

  mkdir -p /var/www/img
  if [ -n "$LOGO_URL" ]; then
    wget -q -O /var/www/img/logo.png "$LOGO_URL" || true
  fi
fi

exec /usr/bin/supervisord -c /etc/supervisor.conf
