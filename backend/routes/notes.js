const router = require('express').Router();
const Note = require('../models/Note');

// Get all notes for a user
router.get('/:userId', async (req, res) => {
    try {
        const notes = await Note.find({ userId: req.params.userId });
        res.status(200).json(notes);
    } catch (err) {
        res.status(500).json(err);
    }
});

// Create a note
router.post('/', async (req, res) => {
    const newNote = new Note(req.body);
    try {
        const savedNote = await newNote.save();
        res.status(200).json(savedNote);
    } catch (err) {
        res.status(500).json(err);
    }
});

// Update a note
router.put('/:id', async (req, res) => {
    try {
        const updatedNote = await Note.findByIdAndUpdate(
            req.params.id,
            { $set: req.body },
            { new: true }
        );
        res.status(200).json(updatedNote);
    } catch (err) {
        res.status(500).json(err);
    }
});

// Delete a note
router.delete('/:id', async (req, res) => {
    try {
        await Note.findByIdAndDelete(req.params.id);
        res.status(200).json("Note has been deleted");
    } catch (err) {
        res.status(500).json(err);
    }
});

module.exports = router;
