import 'package:flutter/material.dart';

class TooManyResultsBanner extends StatelessWidget {
  const TooManyResultsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      color: Colors.orange.shade50,
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Colors.orange.shade800,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Trop de résultats trouvés. Veuillez affiner votre recherche pour voir plus de restaurants.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}