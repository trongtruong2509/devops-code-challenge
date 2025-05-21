// Proxy server for forwarding requests to backend
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');

// Polyfill for Object.hasOwn for Node.js 14
if (!Object.hasOwn) {
    Object.hasOwn = function (obj, prop) {
        return Object.prototype.hasOwnProperty.call(obj, prop);
    };
}

const app = express();

// Get backend URL from environment variable
const backendUrl = process.env.BACKEND_URL || 'http://localhost:8080';
console.log(`Backend URL: ${backendUrl}`);

// Serve static frontend assets
app.use(express.static(path.join(__dirname, 'build')));

// Proxy API requests to the backend service
app.use('/api', createProxyMiddleware({
    target: backendUrl,
    changeOrigin: true,
    pathRewrite: {
        '^/api': '/' // Remove /api prefix when forwarding to backend
    },
    onProxyReq: (proxyReq, req, res) => {
        console.log(`Proxying request to: ${backendUrl}${req.url.replace(/^\/api/, '')}`);
    }
}));

// Handle all other routes by serving the main index.html file
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'build', 'index.html'));
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Frontend server with API proxy running on port ${PORT}`);
});
