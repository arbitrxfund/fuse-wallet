import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:supervecina/generated/i18n.dart';
import 'package:supervecina/models/app_state.dart';
import 'package:supervecina/models/views/bottom_bar.dart';
import 'package:supervecina/redux/actions/pro_mode_wallet_actions.dart';
import 'package:supervecina/screens/pro_mode/pro_drawer.dart';
import 'package:supervecina/screens/pro_mode/pro_header.dart';
import 'package:supervecina/screens/pro_mode/pro_home.dart';
import 'package:supervecina/screens/send/contacts_list.dart';
import 'package:supervecina/screens/send/receive.dart';
import 'package:supervecina/screens/send/send_contact.dart';
import 'package:supervecina/widgets/bottom_bar_item.dart';
import 'package:supervecina/widgets/coming_soon.dart';
import 'package:supervecina/widgets/my_app_bar.dart';
import 'package:supervecina/widgets/tabs_scaffold.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:redux/redux.dart';

class ProModeScaffold extends StatefulWidget {
  final int tabIndex;
  ProModeScaffold({Key key, this.tabIndex = 0}) : super(key: key);
  @override
  _ProModeScaffoldState createState() => _ProModeScaffoldState();
}

class _ProModeScaffoldState extends State<ProModeScaffold> {
  int _currentIndex = 0;

  RateMyApp rateMyApp;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.tabIndex;
    rateMyApp = RateMyApp(
      minDays: 0,
      minLaunches: 0,
      googlePlayIdentifier: 'io.fuse.supervecina',
      appStoreIdentifier: '1491783654',
    );
    rateMyApp.init().then((_) {
      if (rateMyApp.shouldOpenDialog) {
        Future.delayed(const Duration(milliseconds: 2500), () {
          rateMyApp.showStarRateDialog(
            context,
            title: 'Rate this app',
            message:
                'You like this app ? Then take a little bit of your time to leave a rating :', // The dialog message.
            actionsBuilder: (_, stars) {
              return [
                FlatButton(
                  child: Text('OK'),
                  onPressed: () async {
                    print('Thanks for the ' +
                        (stars == null ? '0' : stars.round().toString()) +
                        ' star(s) !');
                    await rateMyApp
                        .callEvent(RateMyAppEventType.rateButtonPressed);
                    Navigator.pop<RateMyAppDialogButton>(
                        context, RateMyAppDialogButton.rate);
                  },
                ),
              ];
            },
            ignoreIOS: false,
            dialogStyle: DialogStyle(
              titleAlign: TextAlign.center,
              dialogShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0))),
              messageAlign: TextAlign.center,
              messagePadding: EdgeInsets.only(bottom: 20),
            ),
            starRatingOptions: StarRatingOptions(),
            onDismissed: () =>
                rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
          );
        });
      }
    });
  }

  List<Widget> _pages(contacts) {
    bool hasContactsInStore = contacts.isNotEmpty;
    return [
      ProModeHomeScreen(),
      !hasContactsInStore
          ? SendToContactScreen()
          : ContactsList(contacts: contacts),
      Container(),
      ReceiveScreen()
    ];
  }

  void _onTap(int itemIndex) {
    if (itemIndex == 2) {
      comingSoon(context);
      return;
    } else {
      setState(() {
        _currentIndex = itemIndex;
      });
    }
  }

  BottomNavigationBar _bottomNavigationBar() => BottomNavigationBar(
        selectedFontSize: 13,
        unselectedFontSize: 13,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        backgroundColor: Theme.of(context).bottomAppBarColor,
        showUnselectedLabels: true,
        items: [
          bottomBarItem(I18n.of(context).home, 'home'),
          bottomBarItem(I18n.of(context).send_button, 'send'),
          bottomBarItem(I18n.of(context).trade, 'trade'),
          bottomBarItem(I18n.of(context).receive, 'receive'),
        ],
        onTap: _onTap,
      );

  onInit(Store<AppState> store) {
    bool isListenToTransferEvents =
        store.state.proWalletState?.isListenToTransferEvents ?? false;
    bool isFetchTransferEvents =
        store.state.proWalletState?.isFetchTransferEvents ?? false;
    bool isProcessingTokensJobs =
        store.state.proWalletState?.isProcessingTokensJobs ?? false;
    if (!isListenToTransferEvents) {
      store.dispatch(startListenToTransferEvents());
    }
    if (!isFetchTransferEvents) {
      store.dispatch(startFetchTransferEventsCall());
    }
    if (!isProcessingTokensJobs) {
      store.dispatch(startProcessingTokensJobsCall());
    }
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, BottomBarViewModel>(
        converter: BottomBarViewModel.fromStore,
        onInit: onInit,
        builder: (_, vm) {
          final List<Widget> pages = _pages(vm.contacts);
          return TabsScaffold(
              drawer: DrawerWidget(),
              header: MyAppBar(
                child: ProHeader(),
                backgroundColor: Colors.red,
                height: 230.0,
              ),
              drawerEdgeDragWidth: 0,
              pages: pages,
              currentIndex: _currentIndex,
              bottomNavigationBar: _bottomNavigationBar());
        });
  }
}