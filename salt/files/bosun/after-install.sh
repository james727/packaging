if ! getent passwd bosun > /dev/null; then
  useradd --system --user-group --no-create-home --home /internal/bosun bosun
fi

chmod +x /usr/local/bin/bosun

# Restart service if running
if service bosun status | grep -q 'start/running'; then
  service bosun restart
fi
