import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:master_aid/screens/pdf_import_screen.dart';

void main() {
  testWidgets('PdfImportScreen renders without error', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PdfImportScreen()));

    expect(find.text('Importa Personaggio da PDF'), findsOneWidget);
    expect(find.text('Seleziona PDF'), findsOneWidget);
  });
}
