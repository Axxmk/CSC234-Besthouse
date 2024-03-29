// packages
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:besthouse/models/house.dart';
import 'package:besthouse/models/response/info_response.dart';
import 'package:besthouse/services/api/search.dart';
import 'package:besthouse/services/provider/house_lists.dart';
import 'package:besthouse/services/provider/offer.dart';
import 'package:besthouse/services/share_preference.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// screens
import './screens/customer_profile.dart';
import 'screens/favorite.dart';
import './screens/get_start.dart';
import './screens/guide.dart';
import './screens/home.dart';
import './screens/house_detailed.dart';
import './screens/offer_form.dart';
import './screens/search.dart';
import '../screens/google_location.dart';
import './screens/sign_in.dart';
import './screens/sign_up.dart';
// import './screens/splash.dart';
import './screens/forget_password.dart';

// services
import './services/dio.dart';
import 'services/provider/location.dart';
import './services/location_api.dart';
import 'screens/land_lord_profile.dart';

void main() {
  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }

  runApp(
    /// Providers are above [MyApp] instead of inside it, so that tests
    /// can use [MyApp] while mocking the providers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FeatureHousesList()),
        ChangeNotifierProvider(create: (_) => NearbyHousesList()),
        ChangeNotifierProvider(create: (_) => SearchList()),
        ChangeNotifierProvider(create: (_) => CurrentLocation()),
        ChangeNotifierProvider(create: (_) => DesireLocation()),
        ChangeNotifierProvider(create: (_) => OfferFormProvider()),
      ],
      child: const MyApp(),
    ),
  );
  SharePreference.init();
  DioInstance.init();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Best House',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF24577A),
          secondary: const Color.fromARGB(255, 84, 156, 160),
          tertiary: const Color.fromARGB(255, 240, 241, 243),
        ),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 84, 156, 160),
        ),
        textTheme: TextTheme(
            headline3: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF24577A),
            ),
            headline2: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF24577A)),
            headline1: GoogleFonts.poppins(
                fontSize: 38,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF022B3A)),
            headline4: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
            headline5: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color.fromARGB(255, 5, 5, 5),
            ),
            headline6: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color.fromARGB(80, 0, 0, 0),
            ),
            bodyText1: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xff0E2B39)),
            bodyText2: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF022B3A),
              fontWeight: FontWeight.w600,
            ),
            subtitle1: GoogleFonts.poppins(fontSize: 14)),
      ),
      home: Scaffold(
        body: AnimatedSplashScreen(
          duration: 3000,
          centered: true,
          splash: 'assets/logo.png',
          nextScreen: const GetStart(),
          splashTransition: SplashTransition.fadeTransition,
          pageTransitionType: PageTransitionType.fade,
        ),
      ),
      routes: {
        HouseDetailed.routeName: (context) => HouseDetailed(
            args: ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>),
        GetStart.routeName: (context) => const GetStart(),
        MyHomePage.routeName: (context) => const MyHomePage(),
        SignIn.routeName: (context) => const SignIn(),
        SignUp.routeName: (context) => const SignUp(),
        Guide.routeName: (context) => const Guide(),
        OfferForm.routeName: (context) => const OfferForm(),
        ForgetPassword.routeName: (context) => const ForgetPassword(),
        GoogleLocation.routeName: (context) => const GoogleLocation(),
        LandLordProfile.routeName: (context) => LandLordProfile(
            args: ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);
  static const String routeName = "/homepage";

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  bool isSwapRight = true;
  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndex > index) {
        isSwapRight = false;
      } else if (_selectedIndex < index) {
        isSwapRight = true;
      }
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    Provider.of<SearchList>(context, listen: false).changeLoadState(true);

    LocationApi.getLocation().then((value) {
      var latlong = value;
      return context.read<CurrentLocation>().updateLocation(CameraPosition(
          target: LatLng(latlong[1] as double, latlong[0] as double),
          zoom: 18));
    }).then((_) {
      SearchApi.getFeatureHouses(
              Provider.of<CurrentLocation>(context, listen: false).longitude,
              Provider.of<CurrentLocation>(context, listen: false).latitude)
          .then((value) {
        if (value is InfoResponse) {
          List<House> temp = [...value.data.map((e) => House.fromJson(e))];
          Provider.of<FeatureHousesList>(context, listen: false)
              .updateList(temp);
          Provider.of<FeatureHousesList>(context, listen: false)
              .changeLoadState(false);
        }
      });
      SearchApi.getNearByHouses(
              Provider.of<CurrentLocation>(context, listen: false).longitude,
              Provider.of<CurrentLocation>(context, listen: false).latitude)
          .then((value) {
        if (value is InfoResponse) {
          List<House> temp = [...value.data.map((e) => House.fromJson(e))];

          Provider.of<NearbyHousesList>(context, listen: false)
              .updateList(temp);
          Provider.of<SearchList>(context, listen: false).updateList(temp);
          Provider.of<NearbyHousesList>(context, listen: false)
              .changeLoadState(false);
          Provider.of<SearchList>(context, listen: false)
              .changeLoadState(false);
        }
      });
    });

    // print(context.watch<CurrentLocation>().currentLocation);

    super.initState();
  }

  void changeIndex() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screen = <Widget>[
      Home(
        onTapHandler: changeIndex,
      ),
      const Search(),
      const Favorite(),
      const CustomerProfile()
    ];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: _selectedIndex == 3
              ? const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xff173550),
                      Color(0xff24577a),
                    ],
                  ),
                )
              : const BoxDecoration(color: Colors.white),
        ),
        title: Row(
          children: [
            GestureDetector(
              child: Image.asset(
                  _selectedIndex == 3
                      ? "assets/logo_alt.png"
                      : "assets/logo.png",
                  scale: 24),
              onTap: () {
                setState(() {
                  isSwapRight = false;
                  _selectedIndex = 0;
                });
              },
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              "Best house",
              textAlign: TextAlign.left,
              style: _selectedIndex == 3
                  ? GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)
                  : Theme.of(context).textTheme.bodyText2,
            ),
          ],
        ),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            splashRadius: 20.0,
            icon: const Icon(
              Icons.menu_book,
            ),
            color: _selectedIndex == 3
                ? Colors.white
                : Theme.of(context).colorScheme.secondary,
            tooltip: 'Go to guide page',
            onPressed: () => Navigator.pushNamed(context, Guide.routeName,
                arguments: {"type": "customer"}),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        layoutBuilder: (currentChild, previousChildren) =>
            currentChild as Widget,
        switchInCurve: Curves.easeOutExpo,
        transitionBuilder: (child, animation) => SlideTransition(
          position: isSwapRight
              ? Tween<Offset>(
                      begin: const Offset(2, 0), end: const Offset(0, 0))
                  .animate(animation)
              : Tween<Offset>(
                      begin: const Offset(-2, 0), end: const Offset(0, 0))
                  .animate(animation),
          child: child,
        ),
        child: screen.elementAt(_selectedIndex),
        duration: const Duration(milliseconds: 500),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.black,
            spreadRadius: -4,
            blurRadius: 5,
          )
        ]),
        child: BottomNavigationBar(
          selectedItemColor: const Color(0xff24577A),
          unselectedItemColor: const Color(0xff7E95A6),
          selectedLabelStyle: GoogleFonts.poppins(),
          unselectedLabelStyle: GoogleFonts.poppins(),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
              ),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite,
              ),
              label: 'Favourite',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
              ),
              label: 'Profile',
            ),
          ],
          showUnselectedLabels: true,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          // showSelectedLabels: false,
        ),
      ),
    );
  }
}
