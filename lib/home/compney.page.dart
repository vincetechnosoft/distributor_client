import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:distributor_client/gateway/init.dart';
import 'package:distributor_client/home/create_return_boxes_entry.page.dart';
import 'package:distributor_client/home/display_entry.page.dart';
import 'package:distributor_client/utils/purchase_pdf.dart';
import 'package:flutter/material.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({Key? key, required this.compneyID}) : super(key: key);
  final String compneyID;

  @override
  Widget build(BuildContext context) {
    final configDoc = DocProvider.of<ConfigDoc>(context);
    final userDoc = DocProvider.of<UserDoc>(context);
    final info = configDoc.distributor(compneyID);
    final compney = userDoc.distributor(compneyID);
    return Scaffold(
      appBar: AppBar(
        title: Text(info?.name ?? "Unknown"),
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return _CompneyInfoModal(compneyID: compneyID);
                  },
                );
              },
              icon: const Icon(Icons.info_outline_rounded))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: compney == null
            ? const Center(child: Text("NO Data"))
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: compney.messages.length,
                      itemBuilder: (context, i) {
                        final message = compney.messages
                            .elementAt(compney.messages.length - i - 1);
                        return _Message(message: message, compneyID: compneyID);
                      },
                      reverse: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return CreateReturnBoxesEntry(
                                  compneyID: compneyID,
                                );
                              },
                            );
                          },
                          child: const Text("Return Boxes"),
                        )
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }
}

class _CompneyInfoModal extends StatefulWidget {
  const _CompneyInfoModal({Key? key, required this.compneyID})
      : super(key: key);
  final String compneyID;

  @override
  State<_CompneyInfoModal> createState() => _CompneyInfoModalState();
}

class _CompneyInfoModalState extends State<_CompneyInfoModal> {
  @override
  Widget build(BuildContext context) {
    final configDoc = DocProvider.of<ConfigDoc>(context);
    final userDoc = DocProvider.of<UserDoc>(context);
    final info = configDoc.distributor(widget.compneyID);
    final compney = userDoc.distributor(widget.compneyID);
    final productDoc = getProductDoc(context, widget.compneyID).doc;
    final messages = compney?.messages;
    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          title: const Text("Due Payment"),
          trailing: Text(compney?.dueAmount.toString() ?? "loading"),
        ),
        const Divider(),
        ListTile(
          title: const Text("Due Boxes"),
          trailing: Text(compney?.dueBoxes.toString() ?? "loading"),
        ),
        const Divider(),
        ListTile(
          title: const Text("Generate Pdf"),
          trailing: ElevatedButton(
            onPressed: info == null || productDoc == null || messages == null
                ? null
                : () => generatePDF(info, productDoc, messages),
            child: const Text("Select Dates"),
          ),
        ),
        const SizedBox(height: 20)
      ],
    );
  }

  void generatePDF(CompneyInfo compneyInfo, ProductDoc productDoc,
      Iterable<EntryMessage> messages) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: messages.first.belongTo.dateTime,
      lastDate: messages.last.belongTo.dateTime,
    );
    if (range == null) return;
    purchasePDF(
      compneyInfo: compneyInfo,
      entries: messages.map((e) => e.entry),
      range: range,
      productDoc: productDoc,
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({Key? key, required this.message, required this.compneyID})
      : super(key: key);
  final Message message;
  final String compneyID;
  @override
  Widget build(BuildContext context) {
    final m = message;
    if (m is EntryMessage) {
      final payment = m.entry.sellOut;
      final boxes = m.entry.dueBoxes;
      if (payment == null) {
        if (boxes != null) {
          return ChatTile(
            title: "Boxes Returned",
            subtitle: " ( ${boxes.boxes} )",
            chatTilePosition: ChatTilePosition.end,
            timeStamp: m.belongTo,
          );
        }
      } else if (payment.due) {
        return ChatTile(
          title: "Stock Boght",
          subtitle: "${payment.amount} ( ${boxes?.boxes} )",
          chatTilePosition: ChatTilePosition.start,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return DisplayEntryPage(
                entry: m.entry as SoldEntry,
                compneyID: compneyID,
              );
            }));
          },
          timeStamp: m.belongTo,
        );
      } else {
        return ChatTile(
          title: "Payment Done",
          subtitle: payment.amount.toString(),
          chatTilePosition: ChatTilePosition.end,
          timeStamp: m.belongTo,
        );
      }
    }
    return Center(child: Text(message.preview));
  }
}
