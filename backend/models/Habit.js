const mongoose = require('mongoose');

const HabitSchema = new mongoose.Schema({
    userId: {
        type: String,
        required: true,
    },
    title: {
        type: String,
        required: true,
    },
    completedDates: [{
        type: Date
    }],
}, { timestamps: true });

module.exports = mongoose.model('Habit', HabitSchema);
