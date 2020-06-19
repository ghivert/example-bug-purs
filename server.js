const { createProxyMiddleware } = require('http-proxy-middleware')
const Bundler = require('parcel-bundler')
const express = require('express')

const bundler = new Bundler('public/index.html', {
  // Don't cache anything in development
  cache: false,
})

const app = express()
const PORT = process.env.PORT || 7000

app.use(
  '/__',
  createProxyMiddleware({
    target: 'http://localhost:5000',
  })
)

// Pass the Parcel bundler into Express as middleware
app.use(bundler.middleware())

// Run your Express server
app.listen(PORT)
