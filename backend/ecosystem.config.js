// PM2 process manager config for production (AWS EC2)
//
// Usage:
//   pm2 start ecosystem.config.js --env production
//   pm2 save
//   pm2 startup   ← run the printed command to auto-start on reboot

module.exports = {
  apps: [
    {
      name: 'makhzani-api',
      script: 'server.js',
      instances: 1,           // single t2.micro — no clustering needed yet
      autorestart: true,
      watch: false,
      max_memory_restart: '400M',
      env_production: {
        NODE_ENV: 'production',
        PORT: 3000,
      },
      error_file: 'logs/err.log',
      out_file: 'logs/out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
      merge_logs: true,
    },
  ],
};
