class Resource {
  final int id;
  final String title;
  final String category;
  final String shortDescription;
  final String detailedContent;
  final String? worth;
  final String popularityLevel;
  final int popularityScore;
  final String difficulty;
  final String? imageUrl;
  final String? pdfUrl;
  final String? wordUrl;
  final String? documentationUrl;
  final String createdAt;

  Resource({
    required this.id,
    required this.title,
    required this.category,
    required this.shortDescription,
    required this.detailedContent,
    this.worth,
    required this.popularityLevel,
    required this.popularityScore,
    required this.difficulty,
    this.imageUrl,
    this.pdfUrl,
    this.wordUrl,
    this.documentationUrl,
    required this.createdAt,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      shortDescription: json['short_description'] ?? '',
      detailedContent: json['detailed_content'] ?? '',
      worth: json['worth'],
      popularityLevel: json['popularity_level'] ?? 'high',
      popularityScore: json['popularity_score'] ?? 80,
      difficulty: json['difficulty'] ?? 'intermediate',
      imageUrl: json['image_url'],
      pdfUrl: json['pdf_url'],
      wordUrl: json['word_url'],
      documentationUrl: json['documentation_url'],
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'short_description': shortDescription,
      'detailed_content': detailedContent,
      'worth': worth,
      'popularity_level': popularityLevel,
      'popularity_score': popularityScore,
      'difficulty': difficulty,
      'image_url': imageUrl,
      'pdf_url': pdfUrl,
      'word_url': wordUrl,
      'documentation_url': documentationUrl,
      'created_at': createdAt,
    };
  }

  String getCategoryDisplayName() {
    switch (category) {
      case 'software_development':
        return 'Software Development';
      case 'web_development':
        return 'Web Development';
      case 'mobile_app_development':
        return 'Mobile App Development';
      default:
        return category;
    }
  }

  String getDifficultyColor() {
    switch (difficulty) {
      case 'beginner':
        return '#4CAF50';
      case 'intermediate':
        return '#FF9800';
      case 'advanced':
        return '#F44336';
      default:
        return '#2196F3';
    }
  }
}
