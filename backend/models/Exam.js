const mongoose = require('mongoose');

const ExamSchema = new mongoose.Schema({
    userId: {
        type: String,
        required: true,
    },
    subject: {
        type: String,
        required: true,
    },
    date: {
        type: Date,
        required: true,
    },
    syllabus: [{
        topic: String,
        isCompleted: {
            type: Boolean,
            default: false
        }
    }],
}, { timestamps: true });

module.exports = mongoose.model('Exam', ExamSchema);
