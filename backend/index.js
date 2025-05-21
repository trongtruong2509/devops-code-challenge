const express = require('express')
const { v4: uuidv4 } = require('uuid');
const { CORS_ORIGIN } = require('./config')
console.log(require('./config'))
console.log(CORS_ORIGIN)

const ID = uuidv4()
const PORT = 8080

const app = express()
app.use(express.json())

app.use((req, res, next) => {
    res.setHeader('Access-Control-Allow-Origin', CORS_ORIGIN)
    res.setHeader('Access-Control-Allow-Methods', 'GET')
    res.setHeader('Access-Control-Allow-Headers', '*')
    next();
})

// Add health endpoint for Docker healthcheck
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'healthy' });
});

app.get(/.*/, (req, res) => {
    const timestamp = new Date().toISOString();
    console.log(`${timestamp} GET`)
    res.json({
        id: ID,
        message: "Backend connection successful!",
        timestamp: timestamp,
        serverInfo: {
            port: PORT,
            environment: process.env.NODE_ENV || 'development'
        }
    })
})

app.listen(PORT, () => {
    console.log(`Backend started on ${PORT}. ctrl+c to exit`)
})