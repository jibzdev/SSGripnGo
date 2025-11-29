#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /myapp/tmp/pids/server.pid

# Fix line endings for Windows compatibility
echo "Fixing line endings..."
find /myapp -name "*.rb" -o -name "*.sh" | xargs dos2unix 2>/dev/null || true

# Check SSL setup
echo "Checking SSL setup..."
# Add SSL setup commands here if necessary

# Execute the container's main process (rails server)
exec "$@"
