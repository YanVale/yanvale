const express = require('express')

// Constants
const PORT = 8080;
const HOST = '0.0.0.0';

const app = express()

app.get('/', (req, res) => {
  return res.json({
    hello: 'world'
  })
})

app.listen(PORT, HOST);

console.log(`Running on http://${HOST}:${PORT}`);
