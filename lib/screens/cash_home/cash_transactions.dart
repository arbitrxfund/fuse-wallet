
import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:math';
import 'package:fusecash/models/views/cash_wallet.dart';
import 'package:fusecash/models/transfer.dart';
import 'package:contacts_service/contacts_service.dart';  
import 'package:fusecash/utils/phone.dart';

class CashTransactios extends StatefulWidget {
  CashTransactios({@required this.viewModel});

  final CashWalletViewModel viewModel;
  @override
  createState() => new CashTransactiosState();
}

String deduceSign(Transfer transfer) {
  if (transfer.type == 'SEND') {
    return '-';
  } else {
    return '+';
  }
}

String formatAddress(String address) {
  return '${address.substring(0, 6)}...${address.substring(36, 42)}';
}

String deducePhoneNumber(Transfer transfer, Map<String, String> reverseContracts) {
  String accountAddress = transfer.type == 'SEND' ? transfer.to : transfer.from;
  if (reverseContracts.containsKey(accountAddress)) {
    return reverseContracts[accountAddress];
  }
  return formatAddress(accountAddress);
}

// Future<Contact> getContact(Transfer transfer, CashWalletViewModel vm) async {
//   String accountAddress = transfer.type == 'SEND' ? transfer.to : transfer.from;
//   if (vm.reverseContracts.containsKey(accountAddress)) {
//     String phoneNumber = vm.reverseContracts[accountAddress];
//      ContactsService.getContactsForPhone(phoneNumber, withThumbnails: false).then((Iterable<Contact> contacts) {
//       if (contacts.isEmpty) {
//         return null;
//       }
//       return contacts.first;
//      });

//   }
//   return null;
// }


Contact getContact(Transfer transfer, CashWalletViewModel vm) {
  String accountAddress = transfer.type == 'SEND' ? transfer.to : transfer.from;
  if (vm.reverseContracts.containsKey(accountAddress.toLowerCase())) {
    String phoneNumber = vm.reverseContracts[accountAddress.toLowerCase()];
    if (vm.contacts == null) return null;
    for (Contact contact in vm.contacts) {
      for (Item contactPhoneNumber in contact.phones.toList()) {
        if (formatPhoneNumber(contactPhoneNumber.value, vm.countryCode) == phoneNumber) {
          return contact;
        }
      }
    }
  }
  return null;
}

Color deduceColor(Transfer transfer) {
  if (transfer.type == 'SEND') {
    return Color(0xFFFF0000);
  } else {
    return Color(0xFF00BE66);
  }
}

class CashTransactiosState extends State<CashTransactios> {
  CashTransactiosState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext _context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
            padding: EdgeInsets.only(left: 15, top: 15, bottom: 8),
            child: Text("Pending",
                style: TextStyle(
                    color: Color(0xFF979797),
                    fontSize: 14.0,
                    fontWeight: FontWeight.normal))),
        ListView(
            shrinkWrap: true,
            primary: false,
            padding: EdgeInsets.symmetric(vertical: 8.0),
            children: this
                .widget
                .viewModel
                .pendingTransfers
                .map((transfer) =>
                    _TransactionListItem(transfer, getContact(transfer, this.widget.viewModel), this.widget.viewModel, ))
                .toList()),
        Container(
            padding: EdgeInsets.only(left: 15, top: 15, bottom: 8),
            child: Text("Transactions",
                style: TextStyle(
                    color: Color(0xFF979797),
                    fontSize: 14.0,
                    fontWeight: FontWeight.normal))),
        ListView(
            shrinkWrap: true,
            primary: false,
            padding: EdgeInsets.symmetric(vertical: 8.0),
            children: this
                .widget
                .viewModel
                .tokenTransfers
                .map((transfer) =>
                    _TransactionListItem(transfer, getContact(transfer, this.widget.viewModel), this.widget.viewModel))
                .toList())
      ],
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final Transfer _transfer;
  final Contact _contact;
  final CashWalletViewModel _vm;

  _TransactionListItem(this._transfer, this._contact, this._vm);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: new BoxDecoration(
            border: Border(bottom: BorderSide(color: const Color(0xFFDCDCDC)))),
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
        child: ListTile(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_contact != null ? _contact.displayName : deducePhoneNumber(_transfer, _vm.reverseContracts),
                  style: TextStyle(color: Color(0xFF333333), fontSize: 18))
              // Text("For coffee",
              //     style: TextStyle(color: Color(0xFF8D8D8D), fontSize: 15))
            ],
          ),
          leading: Stack(
            children: <Widget>[
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.black,
                child: Image.asset('assets/images/pep.png', width: 59.0),
              ),
            ],
          ),
          trailing: Container(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: Text(
                    deduceSign(_transfer) +
                        (_transfer.value /
                                BigInt.from(pow(10, _vm.token.decimals)))
                            .toString(),
                    style: TextStyle(
                        color: deduceColor(_transfer),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  " ${_vm.token.symbol}",
                  style: TextStyle(
                      color: deduceColor(_transfer),
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal),
                )
              ],
            ),
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
          ),
        ));
  }
}
