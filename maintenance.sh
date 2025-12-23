#!/bin/bash
# Maintenance Script for SUCHT Server

# Log start
echo "Starting maintenance at $(date)" >> /var/www/sucht/maintenance.log

# 1. PM2 Logs Flush (Clear current logs to save space, assuming logrotate handles archives)
# pm2 flush # Optional: logrotate handles rotation, flush might clear too much. We can skip flush if rotation is active.
# But clearing PM2 in-memory logs is good.
pm2 flush

# 2. Clean Package Manager Caches
npm cache clean --force
apt-get clean

# 3. PostgreSQL Maintenance (VACUUM ANALYZE to reclaim storage and update stats)
export PGPASSWORD=Arrecifes893
psql -h localhost -U sucht_user -d sucht_db -c "VACUUM ANALYZE;"

# 4. Clean Frontend Cache (Next.js cache can grow large)
# Be careful not to delete build cache if needed for faster builds, but .next/cache/images is good to clean periodically if serving many images.
# For now, safe cleanup:
# rm -rf /var/www/sucht/frontend/.next/cache/images

echo "Maintenance completed at $(date)" >> /var/www/sucht/maintenance.log
