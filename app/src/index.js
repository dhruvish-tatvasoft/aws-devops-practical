const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

app.get('/', (req, res) => {
    res.send('Node.js App Version 2.0 🚀');
});

app.get('/health', (req, res) => {
    res.send('Node.js App is running very well 🚀');
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
