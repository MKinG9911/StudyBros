const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Database Connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/studybros', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
    .then(() => console.log('MongoDB Connected'))
    .catch(err => console.log(err));

const taskRoute = require('./routes/tasks');
const noteRoute = require('./routes/notes');
const goalRoute = require('./routes/goals');

// Routes
app.use('/api/tasks', taskRoute);
app.use('/api/notes', noteRoute);
app.use('/api/goals', goalRoute);

app.get('/', (req, res) => {
    res.send('StudyBros API is running');
});

// Start Server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
