const router = require('express').Router();
const Goal = require('../models/Goal');

// Get all goals for a user
router.get('/:userId', async (req, res) => {
    try {
        const goals = await Goal.find({ userId: req.params.userId });
        res.status(200).json(goals);
    } catch (err) {
        res.status(500).json(err);
    }
});

// Create a goal
router.post('/', async (req, res) => {
    const newGoal = new Goal(req.body);
    try {
        const savedGoal = await newGoal.save();
        res.status(200).json(savedGoal);
    } catch (err) {
        res.status(500).json(err);
    }
});

// Update a goal
router.put('/:id', async (req, res) => {
    try {
        const updatedGoal = await Goal.findByIdAndUpdate(
            req.params.id,
            { $set: req.body },
            { new: true }
        );
        res.status(200).json(updatedGoal);
    } catch (err) {
        res.status(500).json(err);
    }
});

// Delete a goal
router.delete('/:id', async (req, res) => {
    try {
        await Goal.findByIdAndDelete(req.params.id);
        res.status(200).json("Goal has been deleted");
    } catch (err) {
        res.status(500).json(err);
    }
});

module.exports = router;
