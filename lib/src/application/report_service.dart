import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../domain/besoin.dart';

class ReportService {
  Future<void> exportToPdf(List<Besoin> besoins) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Header(level: 0, child: pw.Text('Rapport des Dépenses', style: const pw.TextStyle(fontSize: 24))),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Titre', 'Description', 'Prix (MGA)', 'Date'],
                  ...besoins.map((b) => [b.titre, b.description ?? '', b.prix.toString(), b.date.toIso8601String()])
                ],
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/rapport.pdf");
    await file.writeAsBytes(await pdf.save());
  }

  Future<void> exportToExcel(List<Besoin> besoins) async {
    final excel = Excel.createExcel();
    final sheet = excel['Dépenses'];

    sheet.appendRow([
      TextCellValue('Titre'),
      TextCellValue('Description'),
      TextCellValue('Prix (MGA)'),
      TextCellValue('Date')
    ]);
    for (var besoin in besoins) {
      sheet.appendRow([
        TextCellValue(besoin.titre),
        TextCellValue(besoin.description ?? ''),
        DoubleCellValue(besoin.prix),
        TextCellValue(besoin.date.toIso8601String())
      ]);
    }

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/rapport.xlsx");
    final excelData = excel.save();
    if (excelData != null) {
      await file.writeAsBytes(excelData);
    }
  }
}