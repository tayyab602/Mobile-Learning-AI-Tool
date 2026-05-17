const express = require('express');
const { body, validationResult } = require('express-validator');
const chatController = require('../controllers/chatController');

const router = express.Router();

// Validation middleware
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array(),
    });
  }
  next();
};

// POST chat message (ask chatbot a question)
router.post(
  '/chat',
  [
    body('question')
      .trim()
      .notEmpty()
      .withMessage('Question is required')
      .isLength({ min: 5 })
      .withMessage('Question must be at least 5 characters'),
  ],
  handleValidationErrors,
  chatController.chat
);

// GET chat history
router.get('/chat/history', chatController.getChatHistory);

// GET specific chat by ID
router.get('/chat/:id', chatController.getChatById);

module.exports = router;
