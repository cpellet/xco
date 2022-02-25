import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/credentials.dart';
import 'package:xco/pages/contacts.dart';
import 'package:xco/pages/home.dart';
import 'package:xco/pages/onboarding.dart';

void main() {
  runApp(const XCOApp());
}

class XCOApp extends StatelessWidget {
  const XCOApp({Key? key}) : super(key: key);

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
      home: const AppScaffold(),
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

class AppScaffold extends StatefulWidget {
  const AppScaffold({Key? key}) : super(key: key);

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold>
    with TickerProviderStateMixin {
  late TabController _tabController;
  EthereumAddress? _address;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (_address == null) {
      loadWallet();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadWallet() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    if (await storage.containsKey(key: "xco.wallet.privatekey")) {
      String? _pkey = await storage.read(key: "xco.wallet.privatekey");
      if (_pkey != null) {
        Credentials _creds = EthPrivateKey.fromHex(_pkey);
        _address = await _creds.extractAddress();
        return;
      }
    }
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const OnboardingPageView()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 150,
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Image.asset(
                  "assets/images/xco_dark.png",
                  filterQuality: FilterQuality.medium,
                ),
                const Spacer(),
                SidebarButton(
                  selected: _tabController.index == 0,
                  iconData: CupertinoIcons.home,
                  onClick: () {
                    setState(() {
                      _tabController.animateTo(0);
                    });
                  },
                ),
                SidebarButton(
                  selected: _tabController.index == 1,
                  iconData: CupertinoIcons.person_2,
                  onClick: () {
                    setState(() {
                      _tabController.animateTo(1);
                    });
                  },
                ),
                const Spacer()
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: const [HomePageView(), ContactsPageView()],
              controller: _tabController,
            ),
          )
        ],
      ),
    );
  }
}

class SidebarButton extends StatefulWidget {
  const SidebarButton(
      {Key? key,
      required this.selected,
      required this.iconData,
      required this.onClick})
      : super(key: key);

  final bool selected;
  final IconData iconData;
  final Function onClick;

  @override
  State<SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<SidebarButton> {
  bool hovered = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onClick(),
      onHover: (inside) {
        setState(() {
          hovered = inside;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        child: Icon(
          widget.iconData,
          color: widget.selected
              ? Theme.of(context).scaffoldBackgroundColor
              : Theme.of(context).secondaryHeaderColor,
        ),
        padding: EdgeInsets.all((widget.selected && hovered) ? 15 : 12),
        margin: EdgeInsets.symmetric(
            vertical: (widget.selected && hovered) ? 8 : 11),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.selected
                ? Theme.of(context).textTheme.headline1!.color
                : hovered
                    ? Theme.of(context).cardColor
                    : Theme.of(context).scaffoldBackgroundColor),
      ),
    );
  }
}
