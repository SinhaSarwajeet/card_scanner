// Regular expressions to identify different fields
final phoneRegex = RegExp(r'(\+?\d{1,4}[\s-]?)?(\(?\d{2,3}\)?[\s-]?)?\d{3}[\s-]?\d{3,4}');
final emailRegex = RegExp(r'\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b', caseSensitive: false);
final addressRegex = RegExp(r'\b\d+\s+[A-Za-z0-9\s.,]+'); // Rough address pattern