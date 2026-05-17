const pool = require('../db');
const aiService = require('../services/aiService');

// Keywords to validate if question is development-related
const DEV_KEYWORDS = [
  'flutter', 'nodejs', 'node.js', 'express', 'mysql', 'database', 'api', 'rest',
  'http', 'javascript', 'typescript', 'react', 'angular', 'vue', 'html', 'css',
  'backend', 'frontend', 'full-stack', 'web development', 'mobile development',
  'android', 'ios', 'swift', 'kotlin', 'java', 'python', 'php', 'git', 'github',
  'deployment', 'docker', 'kubernetes', 'aws', 'azure', 'firebase', 'mongodb',
  'postgresql', 'rest api', 'graphql', 'websocket', 'authentication', 'jwt',
  'cors', 'middleware', 'routing', 'controller', 'service', 'repository', 'orm',
  'sql', 'nosql', 'orm', 'sql query', 'index', 'join', 'normalize', 'schema',
  'microservices', 'crud', 'soap', 'xml', 'json', 'yaml', 'npm', 'yarn',
  'webpack', 'babel', 'eslint', 'testing', 'jest', 'mocha', 'unittest',
  'integration test', 'e2e', 'ci/cd', 'jenkins', 'github actions', 'devops'
];

// Check if question is development-related
const isDevelopmentQuestion = (question) => {
  const lowerQuestion = question.toLowerCase();
  return DEV_KEYWORDS.some(keyword => lowerQuestion.includes(keyword));
};

// Search for relevant resources
const searchRelevantResources = async (question) => {
  try {
    const connection = await pool.getConnection();
    
    // Try full-text search first
    let [results] = await connection.execute(
      `SELECT id, title, short_description, image_url, pdf_url, word_url 
       FROM learning_resources 
       WHERE MATCH(title, short_description, detailed_content) AGAINST(? IN BOOLEAN MODE)
       LIMIT 3`,
      [question]
    );

    // If no full-text results, fallback to keyword search
    if (results.length === 0) {
      const keywords = question.split(' ').filter(w => w.length > 3).join('|');
      [results] = await connection.execute(
        `SELECT id, title, short_description, image_url, pdf_url, word_url 
         FROM learning_resources 
         WHERE title LIKE ? OR short_description LIKE ?
         LIMIT 3`,
        [`%${question}%`, `%${question}%`]
      );
    }
    
    connection.release();
    return results;
  } catch (error) {
    console.error('Error searching resources:', error);
    return [];
  }
};

// POST chat message - main chatbot endpoint
exports.chat = async (req, res) => {
  try {
    const { question } = req.body;

    // Validate if question is development-related
    if (!isDevelopmentQuestion(question)) {
      const refusalMessage = `I appreciate the question, but I'm specifically designed to help with software development, web development, and mobile app development topics. Please ask me about topics like Flutter, Node.js, REST APIs, databases, deployment, or other programming-related subjects.`;
      
      // Still log the out-of-scope question
      const connection = await pool.getConnection();
      await connection.execute(
        `INSERT INTO chat_logs (question, answer, response_type, model_used) 
         VALUES (?, ?, ?, ?)`,
        [question, refusalMessage, 'text', 'scope-validator']
      );
      connection.release();

      return res.status(200).json({
        success: true,
        message: 'Out of scope question detected',
        answer: refusalMessage,
        response_type: 'text',
        image_url: null,
        pdf_url: null,
        word_url: null,
        model_used: 'scope-validator',
      });
    }

    // Search for relevant resources
    const relevantResources = await searchRelevantResources(question);
    
    // Build context from relevant resources
    let context = 'Use the following learning resources as context when answering:';
    if (relevantResources.length > 0) {
      context += relevantResources
        .map(r => `\n- ${r.title}: ${r.short_description}`)
        .join('');
    }

    // Call AI service
    const aiResponse = await aiService.generateAnswer(question, context);

    if (!aiResponse.success) {
      return res.status(500).json({
        success: false,
        message: 'Error generating AI response',
        error: aiResponse.error,
      });
    }

    // Determine response type and relevant URLs
    let responseType = 'text';
    let imageUrl = null;
    let pdfUrl = null;
    let wordUrl = null;

    if (relevantResources.length > 0) {
      const firstResource = relevantResources[0];
      if (firstResource.image_url) imageUrl = firstResource.image_url;
      if (firstResource.pdf_url) pdfUrl = firstResource.pdf_url;
      if (firstResource.word_url) wordUrl = firstResource.word_url;

      if (imageUrl && pdfUrl && wordUrl) {
        responseType = 'text_image_document';
      } else if (imageUrl && (pdfUrl || wordUrl)) {
        responseType = 'text_with_image';
      } else if (pdfUrl || wordUrl) {
        responseType = 'text_with_document';
      } else if (imageUrl) {
        responseType = 'text_with_image';
      }
    }

    // Save chat log
    const connection = await pool.getConnection();
    const [result] = await connection.execute(
      `INSERT INTO chat_logs (question, answer, response_type, image_url, pdf_url, word_url, model_used) 
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        question,
        aiResponse.answer,
        responseType,
        imageUrl,
        pdfUrl,
        wordUrl,
        aiResponse.model,
      ]
    );
    connection.release();

    res.status(200).json({
      success: true,
      message: 'Chat response generated successfully',
      answer: aiResponse.answer,
      response_type: responseType,
      image_url: imageUrl,
      pdf_url: pdfUrl,
      word_url: wordUrl,
      model_used: aiResponse.model,
      chat_id: result.insertId,
    });
  } catch (error) {
    console.error('Error in chat endpoint:', error);
    res.status(500).json({
      success: false,
      message: 'Error processing chat request',
      error: error.message,
    });
  }
};

// GET chat history
exports.getChatHistory = async (req, res) => {
  try {
    const { limit = 20 } = req.query;
    const connection = await pool.getConnection();
    const [rows] = await connection.execute(
      'SELECT * FROM chat_logs ORDER BY created_at DESC LIMIT ?',
      [parseInt(limit)]
    );
    connection.release();

    res.status(200).json({
      success: true,
      message: 'Chat history fetched successfully',
      count: rows.length,
      data: rows,
    });
  } catch (error) {
    console.error('Error fetching chat history:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching chat history',
      error: error.message,
    });
  }
};

// GET specific chat by ID
exports.getChatById = async (req, res) => {
  try {
    const { id } = req.params;
    const connection = await pool.getConnection();
    const [rows] = await connection.execute(
      'SELECT * FROM chat_logs WHERE id = ?',
      [id]
    );
    connection.release();

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Chat not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Chat fetched successfully',
      data: rows[0],
    });
  } catch (error) {
    console.error('Error fetching chat:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching chat',
      error: error.message,
    });
  }
};
