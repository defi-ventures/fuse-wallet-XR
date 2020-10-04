import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusecash/worldxr/src/bloc/wallet/wallet_bloc.dart';
import 'package:fusecash/worldxr/src/data/user.dart';
import 'package:fusecash/worldxr/src/ui/style.dart';

showWallet(BuildContext ctx, User user) {
  // ignore: close_sinks
  WalletBloc walletBloc = BlocProvider.of<WalletBloc>(ctx);
  return showDialog(
    context: ctx,
    builder: (context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        backgroundColor: AppColors.blue_grey,
        title: Container(
          width: MediaQuery.of(context).size.width,
          height: 100,
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.imageUrl),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.email,
                              color: AppColors.login_background,
                            ),
                          ),
                          AutoSizeText(
                            user.email,
                            maxLines: 1,
                            style: TextStyle(
                                color: AppColors.login_background,
                                fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.account_balance_wallet_sharp,
                              color: AppColors.login_background,
                            ),
                          ),
                          Flexible(
                            child: AutoSizeText(
                              walletBloc.address,
                              maxLines: 2,
                              style: TextStyle(
                                  color: AppColors.login_background,
                                  fontSize: 12),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        content: Container(
          height: MediaQuery.of(context).size.height * .3,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        "Total Value",
                        style: TextStyle(
                            color: AppColors.login_background, fontSize: 16),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: CircleAvatar(
                          radius: 25,
                          child: Icon(
                            Icons.send_sharp,
                            color: AppColors.login_background,
                            size: 20,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: CircleAvatar(
                          radius: 25,
                          child: Icon(
                            Icons.add,
                            color: AppColors.login_background,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    walletBloc.ethBalance ?? "\$0.00 USD",
                    style: TextStyle(
                        color: AppColors.login_background, fontSize: 10),
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                    color: AppColors.login_background,
                    child: Text(
                      "Open Wallet",
                      style: TextStyle(color: AppColors.blue_grey),
                    ),
                    onPressed: () {}),
              )
            ],
          ),
        ),
      );
    },
  );
}
