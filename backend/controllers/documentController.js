const pool = require('../db');

// GET all resources with optional filtering
exports.getAllResources = async (req, res) => {
  try {
    const { category, difficulty, sort } = req.query;
    let query = 'SELECT * FROM learning_resources WHERE 1=1';
    const params = [];

    if (category) {
      query += ' AND category = ?';
      params.push(category);
    }

    if (difficulty) {
      query += ' AND difficulty = ?';
      params.push(difficulty);
    }

    // Sort by popularity score by default
    query += ' ORDER BY ';
    if (sort === 'recent') {
      query += 'created_at DESC';
    } else if (sort === 'title') {
      query += 'title ASC';
    } else {
      query += 'popularity_score DESC';
    }

    const connection = await pool.getConnection();
    const [rows] = await connection.execute(query, params);
    connection.release();

    res.status(200).json({
      success: true,
      message: 'Resources fetched successfully',
      count: rows.length,
      data: rows,
    });
  } catch (error) {
    console.error('Error fetching resources:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching resources',
      error: error.message,
    });
  }
};

// GET single resource by ID
exports.getResourceById = async (req, res) => {
  try {
    const { id } = req.params;
    const connection = await pool.getConnection();
    const [rows] = await connection.execute(
      'SELECT * FROM learning_resources WHERE id = ?',
      [id]
    );
    connection.release();

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Resource not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Resource fetched successfully',
      data: rows[0],
    });
  } catch (error) {
    console.error('Error fetching resource:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching resource',
      error: error.message,
    });
  }
};

// CREATE new resource
exports.createResource = async (req, res) => {
  try {
    const {
      title,
      category,
      short_description,
      detailed_content,
      worth,
      popularity_level,
      popularity_score,
      difficulty,
      image_url,
      pdf_url,
      word_url,
      documentation_url,
    } = req.body;

    const connection = await pool.getConnection();
    const [result] = await connection.execute(
      `INSERT INTO learning_resources 
       (title, category, short_description, detailed_content, worth, popularity_level, 
        popularity_score, difficulty, image_url, pdf_url, word_url, documentation_url)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        title,
        category,
        short_description,
        detailed_content,
        worth || null,
        popularity_level || 'high',
        popularity_score || 80,
        difficulty || 'intermediate',
        image_url || null,
        pdf_url || null,
        word_url || null,
        documentation_url || null,
      ]
    );
    connection.release();

    res.status(201).json({
      success: true,
      message: 'Resource created successfully',
      resourceId: result.insertId,
    });
  } catch (error) {
    console.error('Error creating resource:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating resource',
      error: error.message,
    });
  }
};

// UPDATE resource
exports.updateResource = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    // Build dynamic update query
    const allowedFields = [
      'title',
      'category',
      'short_description',
      'detailed_content',
      'worth',
      'popularity_level',
      'popularity_score',
      'difficulty',
      'image_url',
      'pdf_url',
      'word_url',
      'documentation_url',
    ];
    const fields = Object.keys(updates).filter((key) => allowedFields.includes(key));
    const values = fields.map((field) => updates[field]);
    values.push(id);

    if (fields.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No valid fields to update',
      });
    }

    const query = `UPDATE learning_resources SET ${fields.map((f) => `${f} = ?`).join(', ')}, updated_at = CURRENT_TIMESTAMP WHERE id = ?`;

    const connection = await pool.getConnection();
    const [result] = await connection.execute(query, values);
    connection.release();

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Resource not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Resource updated successfully',
    });
  } catch (error) {
    console.error('Error updating resource:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating resource',
      error: error.message,
    });
  }
};

// DELETE resource
exports.deleteResource = async (req, res) => {
  try {
    const { id } = req.params;
    const connection = await pool.getConnection();
    const [result] = await connection.execute(
      'DELETE FROM learning_resources WHERE id = ?',
      [id]
    );
    connection.release();

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Resource not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Resource deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting resource:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting resource',
      error: error.message,
    });
  }
};
