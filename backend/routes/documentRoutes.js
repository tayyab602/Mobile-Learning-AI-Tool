const express = require('express');
const { body, validationResult, param } = require('express-validator');
const documentController = require('../controllers/documentController');

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

// GET all resources
router.get('/resources', documentController.getAllResources);

// GET single resource by ID
router.get(
  '/resources/:id',
  param('id').isInt().withMessage('Resource ID must be an integer'),
  handleValidationErrors,
  documentController.getResourceById
);

// CREATE new resource
router.post(
  '/resources',
  [
    body('title').trim().notEmpty().withMessage('Title is required'),
    body('category')
      .isIn(['software_development', 'web_development', 'mobile_app_development'])
      .withMessage('Invalid category'),
    body('short_description')
      .trim()
      .notEmpty()
      .withMessage('Short description is required'),
    body('detailed_content')
      .trim()
      .notEmpty()
      .withMessage('Detailed content is required'),
    body('worth').optional().trim(),
    body('popularity_level')
      .optional()
      .isIn(['low', 'medium', 'high', 'very_high'])
      .withMessage('Invalid popularity level'),
    body('popularity_score')
      .optional()
      .isInt({ min: 0, max: 100 })
      .withMessage('Popularity score must be between 0-100'),
    body('difficulty')
      .optional()
      .isIn(['beginner', 'intermediate', 'advanced'])
      .withMessage('Invalid difficulty level'),
  ],
  handleValidationErrors,
  documentController.createResource
);

// UPDATE resource
router.put(
  '/resources/:id',
  [
    param('id').isInt().withMessage('Resource ID must be an integer'),
    body('title').optional().trim().notEmpty().withMessage('Title cannot be empty'),
    body('category')
      .optional()
      .isIn(['software_development', 'web_development', 'mobile_app_development'])
      .withMessage('Invalid category'),
  ],
  handleValidationErrors,
  documentController.updateResource
);

// DELETE resource
router.delete(
  '/resources/:id',
  param('id').isInt().withMessage('Resource ID must be an integer'),
  handleValidationErrors,
  documentController.deleteResource
);

module.exports = router;
