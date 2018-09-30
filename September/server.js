const express = require('express');
const app = express();
const PORT = 4500;

app.use(express.static('public'));

console.log(`listening on port: ${PORT}`);
app.listen(PORT, '0.0.0.0')
