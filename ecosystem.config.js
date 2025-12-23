
module.exports = {
    apps: [{
        name: "sucht-backend",
        cwd: "/var/www/sucht/backend",
        script: "dist/main.js",
        env: {
            NODE_ENV: "production",
            TZ: "UTC"
        }
    }, {
        name: "sucht-frontend",
        cwd: "/var/www/sucht/frontend",
        script: "npm",
        args: "start",
        env: {
            NODE_ENV: "production"
        }
    }]
}
