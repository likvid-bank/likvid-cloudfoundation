const express = require('express');
const cors = require('cors');
const app = express();

const PORT = process.env.PORT || 3000;

const compliments = [
    "You're doing a great job!",
    "Keep up the awesome work!",
    "You have a fantastic smile!",
    "Your code is super clean!",
    "You're a Kubernetes superstar!",
];

let visitorCount = 0;

// Allow requests from localhost:4200 (your Angular dev server)
app.use(cors({
    origin: 'http://localhost:4200',
}));

app.get('/', (req, res) => {
    visitorCount++;
    res.json({ greeting: 'Greetings from NodeJS K8S Starter App!', visitorCount });
});

app.get('/compliment', (req, res) => {
    const compliment = compliments[Math.floor(Math.random() * compliments.length)];
    res.json({ compliment });
});

app.get('/healthz', (req, res) => {
    res.json({ status: 'OK' });
});

app.use((req, res) => {
    res.status(404).json({ error: 'Not Found' });
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
