import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/resource.dart';

class ResourceDetailScreen extends StatelessWidget {
  final Resource resource;

  const ResourceDetailScreen({Key? key, required this.resource})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(resource.title),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display image if available
            if (resource.imageUrl != null && resource.imageUrl!.isNotEmpty)
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    resource.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[600],
                          size: 64,
                        ),
                      );
                    },
                  ),
                ),
              ),
            // Metadata
            _buildMetadataRow('Category', resource.getCategoryDisplayName()),
            _buildMetadataRow('Difficulty', resource.difficulty.toUpperCase()),
            _buildMetadataRow(
              'Popularity',
              '${resource.popularityScore}% - ${resource.popularityLevel}',
            ),
            const SizedBox(height: 16),
            // Description
            const Text(
              'Short Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              resource.shortDescription,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            // Detailed content
            const Text(
              'Detailed Content',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              resource.detailedContent,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.6,
              ),
            ),
            // Worth/Importance
            if (resource.worth != null && resource.worth!.isNotEmpty) ...
              [
                const SizedBox(height: 16),
                const Text(
                  'Why This Skill Matters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  resource.worth!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.6,
                  ),
                ),
              ],
            const SizedBox(height: 24),
            // Download/View buttons
            _buildResourceButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Learning Resources',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (resource.imageUrl != null && resource.imageUrl!.isNotEmpty)
          _buildActionButton(
            'View Image',
            Icons.image,
            () => _launchUrl(resource.imageUrl!),
          ),
        if (resource.pdfUrl != null && resource.pdfUrl!.isNotEmpty)
          _buildActionButton(
            'Download PDF',
            Icons.picture_as_pdf,
            () => _launchUrl(resource.pdfUrl!),
          ),
        if (resource.wordUrl != null && resource.wordUrl!.isNotEmpty)
          _buildActionButton(
            'Download Word Document',
            Icons.description,
            () => _launchUrl(resource.wordUrl!),
          ),
        if (resource.documentationUrl != null &&
            resource.documentationUrl!.isNotEmpty)
          _buildActionButton(
            'View Documentation',
            Icons.open_in_browser,
            () => _launchUrl(resource.documentationUrl!),
          ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }
}
