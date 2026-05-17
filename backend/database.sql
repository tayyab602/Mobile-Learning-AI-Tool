-- Dev Assistant Database Schema
-- Full-Stack Mobile Learning App

CREATE DATABASE IF NOT EXISTS dev_assistant_db;
USE dev_assistant_db;

-- Users Table
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) UNIQUE,
  role ENUM('admin', 'student') DEFAULT 'student',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_role (role)
);

-- Learning Resources Table
CREATE TABLE IF NOT EXISTS learning_resources (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  category ENUM('software_development', 'web_development', 'mobile_app_development') NOT NULL,
  short_description TEXT NOT NULL,
  detailed_content LONGTEXT NOT NULL,
  worth TEXT,
  popularity_level ENUM('low', 'medium', 'high', 'very_high') DEFAULT 'high',
  popularity_score INT DEFAULT 80,
  difficulty ENUM('beginner', 'intermediate', 'advanced') DEFAULT 'intermediate',
  image_url VARCHAR(500),
  pdf_url VARCHAR(500),
  word_url VARCHAR(500),
  documentation_url VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FULLTEXT INDEX ft_search (title, short_description, detailed_content),
  INDEX idx_category (category),
  INDEX idx_difficulty (difficulty),
  INDEX idx_popularity (popularity_score DESC),
  INDEX idx_created_at (created_at DESC)
);

-- FAQs Table
CREATE TABLE IF NOT EXISTS faqs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  category VARCHAR(100),
  related_resource_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (related_resource_id) REFERENCES learning_resources(id) ON DELETE SET NULL,
  INDEX idx_category (category),
  INDEX idx_resource (related_resource_id)
);

-- Chat Logs Table (for storing all chatbot conversations)
CREATE TABLE IF NOT EXISTS chat_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  question TEXT NOT NULL,
  answer LONGTEXT NOT NULL,
  response_type ENUM('text', 'text_with_image', 'text_with_document', 'text_image_document') DEFAULT 'text',
  image_url VARCHAR(500),
  pdf_url VARCHAR(500),
  word_url VARCHAR(500),
  model_used VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_created_at (created_at DESC),
  INDEX idx_model (model_used)
);

-- Insert Sample Learning Resources
INSERT INTO learning_resources 
(title, category, short_description, detailed_content, worth, popularity_level, popularity_score, difficulty, image_url, pdf_url, word_url)
VALUES

-- Software Development Topics
('REST APIs in Node.js', 'software_development', 
'REST APIs expose GET, POST, PUT and DELETE endpoints so Flutter can communicate with backend services.',
'REST APIs are the backbone of modern web and mobile development. They allow clients to communicate with servers using standard HTTP methods. In this topic, you will learn how to design, implement, and test RESTful services using Node.js and Express. REST follows the principles of statelessness, resource-oriented design, and standard HTTP methods. This makes APIs scalable, maintainable, and easy to integrate with multiple front-end applications.',
'Essential for full-stack apps. REST APIs are used in nearly every modern web and mobile application.',
'very_high', 95, 'intermediate',
'/uploads/rest-api-architecture.jpg',
'/uploads/REST-API-Guide.pdf',
'/uploads/REST-API-Guide.docx'),

('MySQL Database Design', 'software_development',
'MySQL stores structured learning records, chatbot logs, URLs and FAQs using SQL tables.',
'Databases are essential for storing, organizing, and retrieving data efficiently. MySQL is a popular open-source relational database management system (RDBMS) that follows ACID principles. In this topic, you will learn database design principles including normalization, indexing, relationships (1-to-1, 1-to-many, many-to-many), and query optimization. Understanding proper database design prevents data redundancy, improves performance, and ensures data integrity.',
'Strong foundation for any backend system. High demand in the industry.',
'very_high', 92, 'intermediate',
'/uploads/database-schema.jpg',
'/uploads/MySQL-Design-Guide.pdf',
'/uploads/MySQL-Design-Guide.docx'),

('Software Development Lifecycle', 'software_development',
'SDLC encompasses planning, analysis, design, implementation, testing, deployment, and maintenance phases.',
'The Software Development Lifecycle (SDLC) is a structured process that guides the development of software applications. Understanding SDLC helps teams deliver quality software on time and within budget. Key phases include requirements gathering, system design, development, testing, deployment, and maintenance. Different SDLC models (Waterfall, Agile, DevOps) suit different project needs. Knowledge of SDLC is crucial for professional software development and career advancement.',
'Fundamental for professional software engineering. Very high demand across all tech companies.',
'very_high', 90, 'beginner',
'/uploads/sdlc-phases.jpg',
'/uploads/SDLC-Guide.pdf',
'/uploads/SDLC-Guide.docx'),

-- Web Development Topics
('Web Development Fundamentals', 'web_development',
'Web development includes frontend, backend, APIs, database integration, security and deployment.',
'Web development is the process of building and maintaining websites and web applications. It encompasses both frontend development (user interface and experience) and backend development (server logic and databases). Modern web development also includes responsive design for mobile devices, progressive web apps, security practices, and performance optimization. Web developers are among the most sought-after professionals in the tech industry.',
'Broad career pathway with high earning potential. Very high demand globally.',
'very_high', 93, 'beginner',
'/uploads/web-dev-roadmap.jpg',
'/uploads/Web-Development-Guide.pdf',
'/uploads/Web-Development-Guide.docx'),

('Backend API Security', 'web_development',
'Implementing HTTPS, JWT authentication, input validation, and protection against common vulnerabilities.',
'Security is a critical aspect of backend development. APIs expose your application to potential attacks if not properly secured. This topic covers authentication (who you are), authorization (what you can do), encryption, CORS policies, SQL injection prevention, XSS protection, and rate limiting. Following security best practices protects user data, maintains system integrity, and builds trust with your users. Security knowledge is increasingly valued in the industry.',
'Critical for professional applications. Essential for protecting user data and company reputation.',
'very_high', 94, 'advanced',
'/uploads/api-security.jpg',
'/uploads/API-Security-Guide.pdf',
'/uploads/API-Security-Guide.docx'),

('Frontend with React', 'web_development',
'React is a JavaScript library for building interactive user interfaces with component-based architecture.',
'React is one of the most popular frontend frameworks for building modern web applications. It uses a component-based architecture that makes code reusable, maintainable, and scalable. Key concepts include JSX, virtual DOM, state management, lifecycle methods, hooks, and routing. React is maintained by Facebook and has strong community support. Learning React opens doors to high-paying frontend development positions.',
'Highly sought after skill in web development. Very high salary potential.',
'very_high', 91, 'intermediate',
'/uploads/react-components.jpg',
'/uploads/React-Guide.pdf',
'/uploads/React-Guide.docx'),

-- Mobile App Development Topics
('Flutter HTTP Calls', 'mobile_app_development',
'Flutter uses the http package to call Node.js APIs and display JSON, image URLs and document links.',
'Flutter is a mobile development framework that allows developers to build apps for Android and iOS from a single codebase. Communicating with backend services is essential for most mobile apps. The http package in Flutter provides a simple way to make HTTP requests to RESTful APIs. Understanding async/await programming, JSON parsing, and error handling is crucial for building connected mobile applications.',
'Mandatory for connected mobile apps. Very high demand in mobile development.',
'very_high', 89, 'intermediate',
'/uploads/flutter-http.jpg',
'/uploads/Flutter-HTTP-Guide.pdf',
'/uploads/Flutter-HTTP-Guide.docx'),

('Mobile App UI/UX Design', 'mobile_app_development',
'Creating responsive, user-friendly interfaces with Flutter widgets, proper spacing, colors, and animations.',
'Mobile UI/UX design focuses on creating intuitive and visually appealing user interfaces for mobile applications. Good UI/UX design improves user satisfaction, reduces bounce rates, and increases app adoption. In Flutter, this involves using widgets efficiently, implementing proper navigation, handling different screen sizes (responsive design), following platform guidelines (Material Design for Android, Cupertino for iOS), and creating smooth animations. Users remember apps that are easy to use and visually appealing.',
'High demand skill combining both technical and design thinking. Critical for app success.',
'high', 87, 'intermediate',
'/uploads/flutter-ui-design.jpg',
'/uploads/Flutter-UI-Design-Guide.pdf',
'/uploads/Flutter-UI-Design-Guide.docx'),

('Firebase Integration', 'mobile_app_development',
'Firebase provides backend services including authentication, real-time database, cloud storage, and hosting.',
'Firebase is a Backend-as-a-Service (BaaS) platform by Google that simplifies backend development for mobile and web apps. It provides pre-built services like Firebase Authentication (Google, Facebook login), Realtime Database or Firestore (cloud database), Cloud Storage, Cloud Functions, and Analytics. Using Firebase reduces development time and allows developers to focus on app logic rather than backend infrastructure. Firebase is widely used in production apps due to its reliability and scalability.',
'Highly valuable for rapid app development. Growing demand in the industry.',
'high', 85, 'intermediate',
'/uploads/firebase-architecture.jpg',
'/uploads/Firebase-Integration-Guide.pdf',
'/uploads/Firebase-Integration-Guide.docx');

-- Insert Sample FAQs
INSERT INTO faqs (question, answer, category, related_resource_id)
VALUES
('What is the difference between GET and POST?', 'GET requests retrieve data from the server and are idempotent (safe to repeat). POST requests send data to the server and can modify server state. GET parameters are visible in the URL, while POST data is in the request body.', 'REST APIs', 1),
('Why is database indexing important?', 'Indexing improves query performance by creating a sorted structure on columns. Indexed searches are much faster than full table scans. However, indexes consume storage space and slow down inserts/updates, so they should be used strategically on frequently searched columns.', 'Database', 2),
('What is CORS and why is it needed?', 'CORS (Cross-Origin Resource Sharing) is a browser security feature that controls which domains can access resources from your API. Without CORS headers, browsers block requests from different domains. Properly configured CORS allows legitimate frontend applications to access your API while protecting against unauthorized access.', 'Security', 5);
