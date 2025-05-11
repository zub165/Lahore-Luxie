const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0'; // Allows connections from any IP

// Serve static files
app.use(express.static(__dirname));

// Serve backend files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Send all requests to index.html
app.get('*', (req, res) => {
  res.sendFile(path.resolve(__dirname, 'index.html'));
});

app.listen(PORT, HOST, () => {
  console.log(`Server running on http://${HOST}:${PORT}`);
}); 