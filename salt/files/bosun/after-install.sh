if ! getent passwd bosun > /dev/null; then
  useradd --system --group --no-create-home --home /internal/bosun bosun
fi

# Restart service if running
if service bosun status | grep -q 'start/running'; then
  service bosun restart
fi
