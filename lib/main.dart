import 'dart:html';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hovering/hovering.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_web3/ethereum.dart';
import 'package:flutter_web3/ethers.dart';
import 'package:toggle_switch/toggle_switch.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XCoin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        primaryColor: HexColor.fromHex("59B2AE"),
        fontFamily: "SFPro",
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.black,
              fontFamily: "SFPro",
              displayColor: Colors.black,
            ),
        buttonTheme: ButtonThemeData(
          buttonColor: HexColor.fromHex("59B2AE"),
          textTheme: ButtonTextTheme.primary,
        ),
        disabledColor: Colors.blueGrey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        secondaryHeaderColor: Colors.grey,
        iconTheme: IconThemeData(color: Colors.black.withOpacity(0.7)),
      ),
      darkTheme: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          unselectedWidgetColor: Colors.white,
          primaryColor: HexColor.fromHex("59B2AE"),
          fontFamily: "SFPro",
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                fontFamily: "SFPro",
                displayColor: Colors.white,
              ),
          buttonTheme: ButtonThemeData(
            buttonColor: HexColor.fromHex("59B2AE"),
            textTheme: ButtonTextTheme.primary,
          ),
          inputDecorationTheme: const InputDecorationTheme(
              focusColor: Colors.grey,
              labelStyle: TextStyle(color: Colors.white)),
          disabledColor: Colors.blueGrey,
          scaffoldBackgroundColor: HexColor.fromHex("#121212"),
          cardColor: Colors.grey[850],
          secondaryHeaderColor: Colors.grey,
          iconTheme: IconThemeData(color: Colors.white.withOpacity(0.7))),
      home: const HomePage(),
    );
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? connectedAccount;

  late Future<int> _getBlockNumberFuture;
  late Future<Block> _getLatestBlockFuture;
  late Future<BigInt> _getGasPriceFuture;
  Future<BigInt>? _getBalanceFuture;
  Future<int>? _getTransactionCountFuture;

  bool complexLayout = false;

  JsonRpcProvider provider = JsonRpcProvider('https://xcoin.bxplus.co');
  @override
  void initState() {
    super.initState();
    _getBlockNumberFuture = provider.getBlockNumber();
    _getLatestBlockFuture = provider.getLastestBlock();
    _getGasPriceFuture = provider.getGasPrice();
    if (ethereum != null) {
      connectWallet();
    }
  }

  Future<void> connectWallet() async {
    if (ethereum != null) {
      try {
        await ethereum!.walletSwitchChain(34258879, () async {
          await ethereum!.walletAddChain(
              chainId: 34258879,
              chainName: "XCoin",
              nativeCurrency:
                  CurrencyParams(name: "XCoin", symbol: "XCO", decimals: 0),
              rpcUrls: ['https://xcoin.bxplus.co']);
        });
        final a = await ethereum!.requestAccount();
        if (a.isNotEmpty) {
          setState(() {
            connectedAccount = a.first;
          });
          _getBalanceFuture = provider.getBalance(a.first);
          _getTransactionCountFuture = provider.getTransactionCount(a.first);
        }
      } on EthereumUserRejected {
        print('User rejected the modal');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.xmark_circle,
              color: Theme.of(context).primaryColor,
              size: 35,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Text(
                'Coin',
                style: Theme.of(context)
                    .textTheme
                    .headline4!
                    .copyWith(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ToggleSwitch(
              initialLabelIndex: complexLayout ? 1 : 0,
              minWidth: 80,
              cornerRadius: 20.0,
              activeFgColor: Colors.white,
              inactiveBgColor:
                  Theme.of(context).secondaryHeaderColor.withOpacity(0.2),
              inactiveFgColor: Colors.white,
              totalSwitches: 2,
              labels: ['Wallet', 'Full'],
              icons: [CupertinoIcons.folder, CupertinoIcons.settings],
              activeBgColors: [
                [Theme.of(context).primaryColor],
                [Theme.of(context).primaryColor]
              ],
              onToggle: (index) {
                setState(() {
                  complexLayout = index == 1;
                });
              },
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          connectedAccount == null
              ? Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: TextButton.icon(
                    onPressed: () {
                      connectWallet();
                    },
                    label: Text(
                      "Connect to wallet",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    icon: Icon(
                      CupertinoIcons.cube,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.check_mark,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Connected to wallet",
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1!
                            .copyWith(color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: complexLayout
            ? SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: StaggeredGrid.extent(
                  maxCrossAxisExtent: 150,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  axisDirection: AxisDirection.down,
                  children: [
                    connectedAccount == null
                        ? StaggeredGridTile.count(
                            crossAxisCellCount: 3,
                            mainAxisCellCount: 1,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withAlpha(200),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "Get started with XCoin",
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                  ),
                                  HoverButton(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          CupertinoIcons.arrow_right,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text("I've already setup a wallet",
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1),
                                      ],
                                    ),
                                    onpressed: () {},
                                  ),
                                  HoverButton(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          CupertinoIcons.arrow_right,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text("Get started from scratch",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6),
                                      ],
                                    ),
                                    onpressed: () {},
                                  )
                                ],
                              ),
                            ))
                        : Container(),
                    StaggeredGridTile.count(
                        crossAxisCellCount: 1,
                        mainAxisCellCount: 1,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Block number",
                                style: Theme.of(context).textTheme.subtitle2,
                                textAlign: TextAlign.center,
                              ),
                              FutureBuilder<int>(
                                  future: _getBlockNumberFuture,
                                  builder: ((context, snapshot) =>
                                      snapshot.hasData
                                          ? Center(
                                              child: AutoSizeText(
                                                snapshot.data.toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline4!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w300),
                                              ),
                                            )
                                          : const CupertinoActivityIndicator()))
                            ],
                          ),
                        )),
                    StaggeredGridTile.count(
                        crossAxisCellCount: 1,
                        mainAxisCellCount: 1,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Gas price",
                                style: Theme.of(context).textTheme.subtitle2,
                                textAlign: TextAlign.center,
                              ),
                              FutureBuilder<BigInt>(
                                  future: _getGasPriceFuture,
                                  builder: ((context, snapshot) => snapshot
                                          .hasData
                                      ? Text(
                                          snapshot.data.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4!
                                              .copyWith(
                                                  fontWeight: FontWeight.w300),
                                        )
                                      : const CupertinoActivityIndicator()))
                            ],
                          ),
                        )),
                    StaggeredGridTile.count(
                        crossAxisCellCount: 2,
                        mainAxisCellCount: 1,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Last activity",
                                style: Theme.of(context).textTheme.subtitle2,
                                textAlign: TextAlign.center,
                              ),
                              Expanded(
                                child: FutureBuilder<Block>(
                                    future: _getLatestBlockFuture,
                                    builder: ((context, snapshot) => snapshot
                                            .hasData
                                        ? Center(
                                            child: AutoSizeText(
                                              timeago.format(
                                                  snapshot.data!.timestamp),
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline4!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w300),
                                            ),
                                          )
                                        : const CupertinoActivityIndicator())),
                              )
                            ],
                          ),
                        )),
                    StaggeredGridTile.count(
                        crossAxisCellCount: 2,
                        mainAxisCellCount: 2,
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Last block",
                                style: Theme.of(context).textTheme.subtitle2,
                                textAlign: TextAlign.center,
                              ),
                              FutureBuilder<Block>(
                                  future: _getLatestBlockFuture,
                                  builder: ((context, snapshot) => snapshot
                                          .hasData
                                      ? Column(
                                          children: [
                                            AutoSizeText(
                                              snapshot.data!.transactions.length
                                                      .toString() +
                                                  " transactions",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w300),
                                            ),
                                            AutoSizeText(
                                              "difficulty: " +
                                                  snapshot.data!.difficulty
                                                      .toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w300),
                                            ),
                                            AutoSizeText(
                                              "gas limit: " +
                                                  snapshot.data!.gasLimit
                                                      .toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w300),
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            AutoSizeText(
                                              "hash: " + snapshot.data!.hash,
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Theme.of(context)
                                                          .secondaryHeaderColor),
                                            ),
                                            ListView.builder(
                                              itemBuilder: ((context, index) {
                                                return Text(snapshot
                                                    .data!.transactions[index]);
                                              }),
                                              itemCount: snapshot
                                                  .data!.transactions.length,
                                              shrinkWrap: true,
                                            ),
                                          ],
                                        )
                                      : const CupertinoActivityIndicator()))
                            ],
                          ),
                        )),
                    StaggeredGridTile.count(
                        crossAxisCellCount: 2,
                        mainAxisCellCount: 1,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: connectedAccount != null
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.6)
                                  : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Account balance",
                                style: Theme.of(context).textTheme.subtitle2,
                                textAlign: TextAlign.center,
                              ),
                              connectedAccount == null
                                  ? const Center(
                                      child: Icon(CupertinoIcons.bolt),
                                    )
                                  : FutureBuilder<BigInt>(
                                      future: _getBalanceFuture,
                                      builder: ((context, snapshot) => snapshot
                                              .hasData
                                          ? Column(
                                              children: [
                                                Text(
                                                  (snapshot.data! /
                                                              BigInt.from(
                                                                  1000000000000000000))
                                                          .toString() +
                                                      " XCO",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline4!
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.w300),
                                                ),
                                                Text(
                                                  ((snapshot.data! ~/
                                                                      BigInt.from(
                                                                          1000000000000000000))
                                                                  .toInt() /
                                                              1000)
                                                          .toStringAsFixed(2) +
                                                      " €",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle1!
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          color: Theme.of(
                                                                  context)
                                                              .secondaryHeaderColor),
                                                ),
                                              ],
                                            )
                                          : const CupertinoActivityIndicator()))
                            ],
                          ),
                        )),
                    StaggeredGridTile.count(
                        crossAxisCellCount: 1,
                        mainAxisCellCount: 1,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Transaction count",
                                style: Theme.of(context).textTheme.subtitle2,
                                textAlign: TextAlign.center,
                              ),
                              connectedAccount == null
                                  ? const Center(
                                      child: Icon(CupertinoIcons.bolt),
                                    )
                                  : FutureBuilder<int>(
                                      future: _getTransactionCountFuture,
                                      builder: ((context, snapshot) => snapshot
                                              .hasData
                                          ? Text(
                                              snapshot.data.toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline4!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w300),
                                            )
                                          : const CupertinoActivityIndicator()))
                            ],
                          ),
                        )),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 1,
                      mainAxisCellCount: 1,
                      child: HoverContainer(
                          padding: const EdgeInsets.all(12),
                          hoverDecoration: BoxDecoration(
                              color: connectedAccount == null
                                  ? Theme.of(context).cardColor
                                  : Theme.of(context)
                                      .primaryColor
                                      .withAlpha(200),
                              borderRadius: BorderRadius.circular(20)),
                          decoration: BoxDecoration(
                              color: connectedAccount == null
                                  ? Theme.of(context).cardColor
                                  : Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(20)),
                          child: connectedAccount == null
                              ? const Center(
                                  child: Icon(CupertinoIcons.bolt),
                                )
                              : Column(
                                  children: const [
                                    Icon(CupertinoIcons.paperplane),
                                    Text("Send coins")
                                  ],
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                )),
                    )
                  ],
                ),
              )
            : connectedAccount == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/images/pay.svg",
                          height: MediaQuery.of(context).size.height / 3,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Text(
                          "Welcome to the XCoin platform!",
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          "It looks like you haven't set up a wallet yet...",
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            window.open(
                                "https://metamask.io/download/", "MetaMask");
                          },
                          child: HoverContainer(
                            child: Text(
                              "Get MetaMask",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            hoverDecoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withAlpha(200),
                                borderRadius: BorderRadius.circular(20)),
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Text(
                          "Once you are done with the wallet setup, click on \"Connect to wallet\" on this page",
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor),
                        )
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "CURRENT WALLET VALUE",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color:
                                      Theme.of(context).secondaryHeaderColor),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        FutureBuilder<BigInt>(
                          builder: (context, snapshot) => SizedBox(
                            width: 220,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      (snapshot.data! /
                                              BigInt.from(1000000000000000000))
                                          .toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline2!
                                          .copyWith(
                                              fontWeight: FontWeight.w300,
                                              height: 1),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, top: 12),
                                      child: Text("XCO",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 50),
                                  child: Wrap(
                                    spacing: 25,
                                    direction: Axis.horizontal,
                                    children: [
                                      Column(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Theme.of(context)
                                                .textTheme
                                                .headline1!
                                                .color,
                                            foregroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            child: const Icon(
                                                CupertinoIcons.up_arrow),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text("Send")
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                Theme.of(context).primaryColor,
                                            foregroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            child:
                                                const Icon(CupertinoIcons.cart),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text("Purchase")
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Theme.of(context)
                                                .textTheme
                                                .headline1!
                                                .color,
                                            foregroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            child: const Icon(
                                                CupertinoIcons.down_arrow),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text("Receive")
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          future: _getBalanceFuture,
                        )
                      ],
                    ),
                  ),
      ),
    );
  }
}
