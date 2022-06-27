import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:flutter/material.dart' as m;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:open_file/open_file.dart';

Widget pdfTableText(String text, [int? maxLen]) {
  if (maxLen != null && text.length > maxLen) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(text.substring(0, maxLen)),
    );
  }
  return Padding(
    padding: const EdgeInsets.only(left: 2, top: 2, bottom: 2),
    child: Text(text),
  );
}

Directory? _tempDir;
Future<void> purchasePDF({
  required CompneyInfo compneyInfo,
  required Iterable<Entry> entries,
  required ProductDoc productDoc,
  required m.DateTimeRange range,
}) async {
  final dir = _tempDir ??= await getTemporaryDirectory();
  final file = File("${dir.path}/buyers.pdf");
  if (await file.exists()) await file.delete();
  final pdf = Document();
  _createBuyersBoughtPage(
    pdf,
    compneyInfo.id,
    compneyInfo.name,
    entries.whereType<SoldEntry>(),
    productDoc,
    range,
  );
  await file.writeAsBytes(await pdf.save());
  await OpenFile.open(file.path);
}

class _Stock {
  int q = 0;
  int p = 0;

  @override
  String toString() {
    if (p == 0) {
      if (q == 0) return "";
      return IntQuntity(q).toString();
    }
    return "${IntQuntity(q)}, ${IntQuntity(p)}";
  }
}

void _createBuyersBoughtPage(
  Document pdf,
  String phoneNumber,
  String name,
  Iterable<SoldEntry> entries,
  ProductDoc productData,
  m.DateTimeRange range,
) {
  final data = <String, Map<int, _Stock>>{};
  final total = <String, int>{};
  final productIDsInUse = <int>{};
  for (var entry in entries) {
    final date = entry.belongToDate.formateDate(withYear: false);
    total[date] = (total[date] ?? 0) + entry.sellOut.amount.money;
    final stocks = data[date] ??= {};
    for (var item in entry.itemSold) {
      productIDsInUse.add(item.id);
      final stock = stocks[item.id] ??= _Stock();
      stock.q += item.quntity.quntity;
      stock.p += item.pack.quntity;
    }
  }
  final products = productIDsInUse
      .map((e) => productData.getItem(e.toString()))
      .toList()
    ..sort((a, b) => a.rankOrderValue.compareTo(b.rankOrderValue));
  final dates = Dates.fromRange(range);
  final dateColl = <List<String>>[];
  for (var i = 0; i < dates.length; i++) {
    final val =
        DateTimeString.fromDateTime(dates[i]).formateDate(withYear: false);
    if (i % 7 == 0) {
      dateColl.add([val]);
    } else {
      dateColl.last.add(val);
    }
  }
  for (var date in dateColl) {
    pdf.addPage(Page(
      pageFormat: PdfPageFormat.a4,
      margin: const EdgeInsets.all(5),
      build: (context) {
        return Column(
          children: [
            Text("$name - $phoneNumber", style: Theme.of(context).header2),
            Table(
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 2,
                        top: 2,
                        bottom: 2,
                      ),
                      child: Text(
                        "May 2022",
                        style: Theme.of(context).header3,
                      ),
                    ),
                    ...date.map(pdfTableText),
                  ],
                ),
                ...products.map(
                  (product) => TableRow(
                    children: [
                      pdfTableText(product.name),
                      ...date.map(
                        (date) => SizedBox(
                          width: 50,
                          child:
                              pdfTableText("${data[date]?[product.id] ?? ""}"),
                        ),
                      ),
                    ],
                  ),
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 2,
                        top: 2,
                        bottom: 2,
                      ),
                      child: Text(
                        "Total (in Rs)",
                        style: Theme.of(context).header3,
                      ),
                    ),
                    ...date.map((e) => pdfTableText(
                        IntMoney(((total[e] ?? 0) ~/ 1000) * 1000)
                            .toString(lead: false, trail: false))),
                  ],
                ),
              ],
              border: TableBorder.all(),
            ),
          ],
        );
      },
    ));
  }
}
