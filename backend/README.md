# Dev Assistant Backend - Node.js REST API

Backend server for the Dev Assistant Mobile Learning Application built with Express.js, MySQL, and AI integration.

## Features

✅ **RESTful API** - Clean routing with Express.js
✅ **MySQL Database** - Structured storage for learning resources
✅ **AI Chatbot** - Multi-provider support (Gemini, Ollama, OpenRouter)
✅ **Scope Validation** - Chatbot restricted to development topics
✅ **Static File Serving** - Serve images, PDFs, and Word documents
✅ **Security** - Helmet headers, CORS, input validation
✅ **Error Handling** - Comprehensive error handling and logging

## Prerequisites

- Node.js LTS (v14 or higher)
- MySQL/XAMPP
- Postman (for API testing)
- One AI Provider:
  - **Gemini**: API key from [Google AI Studio](https://ai.google.dev/)
  - **Ollama**: Downloaded from [ollama.com](https://ollama.com/)
  - **OpenRouter**: API key from [openrouter.ai](https://openrouter.ai/)

## Installation

### 1. Clone the Repository

```bash
cd backend
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Setup Database

```bash
# Start MySQL (via XAMPP or command line)
# Then import the database schema:
mysql -u root < database.sql
```

### 4. Configure Environment

```bash
# Copy the example file
cp .env.example .env

# Edit .env with your configuration
# Add your AI API key if using Gemini or OpenRouter
```

### 5. Start the Server

```bash
# Development (with auto-reload)
npm run dev

# Production
npm start
```

Server will run on `http://localhost:3000`

## API Endpoints

### Health Check
- `GET /api/health` - Check server status

### Learning Resources
- `GET /api/resources` - Get all resources
- `GET /api/resources?category=software_development` - Filter by category
- `GET /api/resources/:id` - Get single resource
- `POST /api/resources` - Create new resource
- `PUT /api/resources/:id` - Update resource
- `DELETE /api/resources/:id` - Delete resource

### Chatbot
- `POST /api/chat` - Ask a question
- `GET /api/chat/history` - Get chat history
- `GET /api/chat/:id` - Get specific chat

### Static Files
- `GET /uploads/:filename` - Download/view files

## Example Requests

### Get All Resources
```bash
curl http://localhost:3000/api/resources
```

### Create a New Resource
```bash
curl -X POST http://localhost:3000/api/resources \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Git Version Control",
    "category": "software_development",
    "short_description": "Learn Git basics",
    "detailed_content": "Git is a version control system...",
    "popularity_level": "very_high"
  }'
```

### Ask a Question
```bash
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"question": "How do I create a REST API in Node.js?"}'
```

## Testing with Postman

1. Import the collection (coming soon)
2. Update the base URL: `http://localhost:3000`
3. Test each endpoint
4. Verify responses

## Project Structure

```
backend/
├── server.js                 # Main Express server
├── db.js                     # MySQL connection pool
├── package.json              # Dependencies
├── .env.example              # Environment template
├── database.sql              # Database schema
├── controllers/
│   ├── documentController.js # Resource CRUD logic
│   └── chatController.js     # Chatbot logic
├── routes/
│   ├── documentRoutes.js     # Resource endpoints
│   └── chatRoutes.js         # Chatbot endpoints
├── services/
│   └── aiService.js          # AI provider integration
└── uploads/                  # Static files (images, PDFs, docs)
```

## Configuration Options

### AI Providers

**Google Gemini (Recommended)**
```
AI_PROVIDER=gemini
AI_API_KEY=your_gemini_api_key
AI_MODEL=gemini-2.5-flash
```

**Ollama (Local/Offline)**
```
AI_PROVIDER=ollama
AI_MODEL=qwen2.5-coder
OLLAMA_BASE_URL=http://localhost:11434
```

**OpenRouter**
```
AI_PROVIDER=openrouter
AI_API_KEY=your_openrouter_key
AI_MODEL=openrouter/auto
```

## Troubleshooting

### MySQL Connection Error
- Ensure XAMPP MySQL is running
- Verify DB_HOST, DB_USER, DB_PASSWORD in .env
- Default: `root` with blank password

### AI API Error
- Check API key in .env
- Verify API provider limits/quotas
- Check internet connection

### CORS Error in Flutter
- Ensure `cors()` middleware is enabled in server.js
- Use correct base URL: `http://10.0.2.2:3000` for Android Emulator

### Port Already in Use
```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9
```

## Next Steps

1. Set up Flutter mobile app
2. Configure Flask endpoints for AI models (optional)
3. Deploy to cloud (AWS, Azure, Heroku)
4. Add authentication (JWT)
5. Implement rate limiting

## License

MIT

## Support

For issues or questions, please open an issue in the repository.
