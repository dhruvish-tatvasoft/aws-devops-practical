const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

app.get('/', (req, res) => {
    res.send('Node.js App Version 1.0 🚀');
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
