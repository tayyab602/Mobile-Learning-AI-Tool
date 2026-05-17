const axios = require('axios');
require('dotenv').config();

const AI_PROVIDER = process.env.AI_PROVIDER || 'gemini';
const AI_API_KEY = process.env.AI_API_KEY;
const AI_MODEL = process.env.AI_MODEL || 'gemini-2.5-flash';

// System prompt to ensure responses are development-focused
const SYSTEM_PROMPT = `You are Dev Assistant, an AI tutor specialized in software development, web development, and mobile app development. 

Your role is to:
1. Answer questions about programming, web development, mobile app development, databases, APIs, and related topics
2. Provide clear, concise explanations suitable for students
3. Include practical examples and best practices
4. Explain concepts in terms of real-world applications

Always keep responses focused on development-related topics. If a question is outside your domain, politely redirect the user.`;

// Generate answer using Gemini API
const generateWithGemini = async (question, context) => {
  try {
    if (!AI_API_KEY) {
      throw new Error('Gemini API key not configured');
    }

    const fullPrompt = `${SYSTEM_PROMPT}\n\nContext: ${context}\n\nQuestion: ${question}`;

    const response = await axios.post(
      `https://generativelanguage.googleapis.com/v1beta/models/${AI_MODEL}:generateContent`,
      {
        contents: [{
          parts: [{ text: fullPrompt }]
        }]
      },
      {
        headers: {
          'x-goog-api-key': AI_API_KEY,
        }
      }
    );

    const answer = response.data?.candidates?.[0]?.content?.parts?.[0]?.text || 'Unable to generate response';
    return {
      success: true,
      answer,
      model: `${AI_MODEL} (Gemini)`,
    };
  } catch (error) {
    console.error('Gemini API Error:', error.message);
    return {
      success: false,
      error: error.message,
    };
  }
};

// Generate answer using Ollama (local)
const generateWithOllama = async (question, context) => {
  try {
    const ollamaUrl = process.env.OLLAMA_BASE_URL || 'http://localhost:11434';
    const fullPrompt = `${SYSTEM_PROMPT}\n\nContext: ${context}\n\nQuestion: ${question}`;

    const response = await axios.post(`${ollamaUrl}/api/generate`, {
      model: AI_MODEL,
      prompt: fullPrompt,
      stream: false,
    }, {
      timeout: 60000,
    });

    const answer = response.data?.response || 'Unable to generate response';
    return {
      success: true,
      answer,
      model: `${AI_MODEL} (Ollama Local)`,
    };
  } catch (error) {
    console.error('Ollama API Error:', error.message);
    return {
      success: false,
      error: error.message,
    };
  }
};

// Generate answer using OpenRouter
const generateWithOpenRouter = async (question, context) => {
  try {
    if (!AI_API_KEY) {
      throw new Error('OpenRouter API key not configured');
    }

    const fullPrompt = `${SYSTEM_PROMPT}\n\nContext: ${context}\n\nQuestion: ${question}`;

    const response = await axios.post(
      'https://openrouter.ai/api/v1/chat/completions',
      {
        model: AI_MODEL,
        messages: [
          {
            role: 'system',
            content: SYSTEM_PROMPT,
          },
          {
            role: 'user',
            content: `${context}\n\nQuestion: ${question}`,
          }
        ],
      },
      {
        headers: {
          'Authorization': `Bearer ${AI_API_KEY}`,
          'HTTP-Referer': 'http://localhost:3000',
        }
      }
    );

    const answer = response.data?.choices?.[0]?.message?.content || 'Unable to generate response';
    return {
      success: true,
      answer,
      model: `${AI_MODEL} (OpenRouter)`,
    };
  } catch (error) {
    console.error('OpenRouter API Error:', error.message);
    return {
      success: false,
      error: error.message,
    };
  }
};

// Main function to generate answer based on configured provider
exports.generateAnswer = async (question, context) => {
  console.log(`\n→ Using AI Provider: ${AI_PROVIDER}`);
  console.log(`→ Question: ${question}`);

  switch (AI_PROVIDER.toLowerCase()) {
    case 'gemini':
      return await generateWithGemini(question, context);
    case 'ollama':
      return await generateWithOllama(question, context);
    case 'openrouter':
      return await generateWithOpenRouter(question, context);
    default:
      return {
        success: false,
        error: `Unknown AI provider: ${AI_PROVIDER}`,
      };
  }
};
