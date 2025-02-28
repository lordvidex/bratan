import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:bratan/ad_manager.dart';
import 'package:flutter/material.dart';

int times = 0;
void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) await initAdMob();
  runApp(MyApp());
}

Future<void> initAdMob() {
  return MobileAds.instance.initialize();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
        routes: {
          SecondPage.routeName: (_) => SecondPage(),
          HomePage.routeName: (_) => HomePage(),
        });
  }
}

class HomePage extends StatefulWidget {
  static const routeName = '/home';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;
  bool _isInterstitialAdReady;
  @override
  void initState() {
    _bannerAd = BannerAd(
        adUnitId: AdManager.bannerAdUnitId,
        size: AdSize.banner,
        listener: AdListener(),
        request: AdRequest());
    _isInterstitialAdReady = false;
    _interstitialAd = InterstitialAd(
        request: AdRequest(),
        adUnitId: AdManager.interstitialAdUnitId,
        listener: AdListener(
            onAdLoaded: (_) => _isInterstitialAdReady = true,
            onAdClosed: (_) {
              if (_isInterstitialAdReady) {
                _isInterstitialAdReady = false;
                times++;
              }
              _moveToSecond();
            }));
    super.initState();

    loadBannerAd();
    loadInterstitialAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  // void _onInterstitalAdEvent(MobileAdEvent event) {
  //   switch (event) {
  //     case MobileAdEvent.loaded:
  //       _isInterstitialAdReady = true;
  //       break;
  //     case MobileAdEvent.failedToLoad:
  //       _isInterstitialAdReady = false;
  //       print('Failed to load an interstitial ad');
  //       break;
  //     case MobileAdEvent.closed:
  //       if (_isInterstitialAdReady) times++;
  //       _isInterstitialAdReady = false;
  //       _moveToSecond();
  //       break;
  //     default:
  //     // do nothing
  //   }
  // }

  void _moveToSecond() {
    Navigator.of(context).pushReplacementNamed(SecondPage.routeName);
  }

  void loadInterstitialAd() async {
    await _interstitialAd.load();
  }

  void loadBannerAd() async {
    await _bannerAd.load();
    // ..show(anchorType: AnchorType.bottom);
  }

  @override
  Widget build(BuildContext context) {
    final adBanner = AdWidget(
      ad: _bannerAd,
    );
    return Scaffold(
        appBar: AppBar(title: Text('My Counter')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Text('Welcome to my APp!', style: TextStyle(fontSize: 30)),
            ElevatedButton(
                onPressed: () => _interstitialAd.show(),
                child: Text('Show Big Ad', style: TextStyle(fontSize: 25))),
            Spacer(),
            Container(
                child: adBanner,
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble())
          ]),
        ));
  }
}

class SecondPage extends StatelessWidget {
  static const routeName = '/result';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () =>
                Navigator.of(context).pushNamed(HomePage.routeName),
          ),
          title: Text('You have clicked: ')),
      body: Center(
        child: Text('$times times'),
      ),
    );
  }
}
