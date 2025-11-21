import 'package:flutter/material.dart';
import '../models/treatment.dart';
import 'package:intl/intl.dart';

class TreatmentTile extends StatelessWidget {
  final Treatment treatment;

  const TreatmentTile({
    super.key,
    required this.treatment,
  });

  String _getTypeLabel(String type) {
    switch (type) {
      case 'insulin_injection':
        return 'זריקת אינסולין';
      case 'pump_bolus':
        return 'בולוס במשאבה';
      default:
        return 'אחר';
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.medication, color: Colors.blue),
        title: Text(
          _getTypeLabel(treatment.type),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(timeFormat.format(treatment.givenAt)),
            if (treatment.units != null)
              Text('יחידות: ${treatment.units}'),
            if (treatment.note != null && treatment.note!.isNotEmpty)
              Text(
                treatment.note!,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}

