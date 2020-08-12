import 'package:country_code_picker/country_code.dart';
import 'package:country_code_picker/country_codes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:seedbed/redux/actions/cash_wallet_actions.dart';
import 'package:seedbed/models/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:seedbed/utils/addresses.dart';
import 'cash_transactions.dart';
import 'package:seedbed/models/views/cash_wallet.dart';

class CashHomeScreen extends StatelessWidget {
  onInit(Store<AppState> store) async {
    Segment.screen(screenName: '/cash-home-screen');
    String walletStatus = store.state.cashWalletState.walletStatus;
    String accountAddress = store.state.userState.accountAddress;
    if (walletStatus != 'deploying' &&
        walletStatus != 'created' &&
        accountAddress != '') {
      store.dispatch(createAccountWalletCall(accountAddress));
    }

    final communities = store.state.cashWalletState.communities;
    if (walletStatus == 'created' &&
        !communities.containsKey(defaultCommunityAddress)) {
      store.dispatch(switchCommunityCall(defaultCommunityAddress));
    }
  }

  void onChange(CashWalletViewModel viewModel, BuildContext context) async {
    if (viewModel.isoCode == null) {
      Locale myLocale = Localizations.localeOf(context);
      Map localeData = codes.firstWhere(
          (Map code) => code['code'] == myLocale.countryCode,
          orElse: () => null);
      viewModel.setCountyCode(CountryCode(
          dialCode: localeData['dial_code'], code: localeData['code']));
    }
    if (!viewModel.isJobProcessingStarted) {
      viewModel.startProcessingJobs();
    }
    if (!viewModel.isListeningToBranch) {
      viewModel.listenToBranch();
    }
    if (!viewModel.isCommunityLoading &&
        viewModel.branchAddress != null &&
        viewModel.branchAddress != "" &&
        viewModel.walletAddress != '') {
      viewModel.branchCommunityUpdate();
    }
    if (!viewModel.isCommunityLoading &&
        !viewModel.isCommunityFetched &&
        viewModel.isBranchDataReceived &&
        viewModel.walletAddress != '') {
      viewModel.switchCommunity(viewModel.communityAddress);
    }
    if (viewModel.token != null) {
      if (!viewModel.isTransfersFetchingStarted) {
        viewModel.startTransfersFetching();
      }
    }
    if (viewModel.identifier == null) {
      viewModel.setIdentifier();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, CashWalletViewModel>(
        distinct: true,
        converter: CashWalletViewModel.fromStore,
        onInit: onInit,
        onInitialBuild: (viewModel) async {
          onChange(viewModel, context);
        },
        onWillChange: (prevViewModel, nextViewModel) async {
          onChange(nextViewModel, context);
        },
        builder: (_, viewModel) {
          return Scaffold(
              key: key,
              body: Column(children: <Widget>[
                Expanded(
                    child: ListView(children: <Widget>[
                  CashTransactios(viewModel: viewModel)
                ])),
              ]));
        });
  }
}
