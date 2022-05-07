import 'package:besthouse/services/api/search.dart';
import 'package:besthouse/services/location_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//model
import '../models/house.dart';
import '../models/location.dart';

//widget
import '../services/provider/offer.dart';
import '../widgets/home/house_card.dart';
import '../widgets/common/button.dart';

//screen
import '../screens/google_location.dart';
import '../screens/house_detailed.dart';

//dio
import 'package:besthouse/models/response/info_response.dart';
import 'package:besthouse/services/api/user.dart';
import 'package:besthouse/services/dio.dart';
import 'package:besthouse/services/share_preference.dart';
import 'package:besthouse/widgets/common/alert.dart';
import 'package:dio/dio.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.onTapHandler}) : super(key: key);
  static const routeName = "/home";
  final Function onTapHandler;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _searchController = TextEditingController();
  final controller1 = PageController(initialPage: 1);
  List<House> housesFeature = [];

  List<House> housesRec = [];

  void houseHandler() async {
    try {
      var location = await LocationApi.getLocation();
      var result = await SearchApi.getHousesList(location[0], location[1]);
      if (result is InfoResponse) {
        List<dynamic> houses = result.data;
        var temp = houses
            .map(
              (e) => House(
                id: e['_id'],
                name: e['name'],
                pictureUrl: e['picture_url'],
                price: e['price'],
                address: e['address'],
                location: Location(coordinates: [
                  e['location']['coordinates'][1],
                  e['location']['coordinates'][0]
                ]),
              ),
            )
            .toList();
        setState(() {
          Future.delayed(const Duration(seconds: 0), () {
            setState(() {
              housesFeature = temp;
              housesRec = temp;
            });
          });
        });
        Alert.successAlert(
          result,
          'Success',
          () => Navigator.of(context).pop(),
          context,
        );
      }
    } on DioError catch (e) {
      Alert.errorAlert(e, context);
    }
  }

  @override
  void initState() {
    if (mounted) {
      houseHandler();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Where ?',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, GoogleLocation.routeName)
                        .then((value) => {widget.onTapHandler()});
                  },
                  child: TextFormField(
                    enabled: false,
                    controller: _searchController,
                    obscureText: false,
                    decoration: const InputDecoration(
                      hintText: "Search your desire location!",
                      fillColor: Color(0xFFE9E9E9),
                      filled: true,
                      suffixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Image.asset(
              "assets/house_image.png",
              scale: 1.2,
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: double.infinity,
              child: Text(
                'Featured House',
                style: Theme.of(context).textTheme.headline2,
                textAlign: TextAlign.left,
              ),
            ),
            housesFeature.isNotEmpty
                ? SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: housesFeature.length,
                      itemBuilder: (BuildContext context, int index) {
                        return HouseCard(
                          house: housesFeature[index],
                          showInfoHandler: _showInfo,
                        );
                      },
                    ),
                  )
                : const Text('No houses found'),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: Text(
                'Discover around you',
                style: Theme.of(context).textTheme.headline2,
                textAlign: TextAlign.left,
              ),
            ),
            housesRec.isNotEmpty
                ? SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: housesRec.length,
                      itemBuilder: (BuildContext context, int index) {
                        return HouseCard(
                          house: housesRec[index],
                          showInfoHandler: _showInfo,
                        );
                      },
                    ),
                  )
                : const Text('No houses found'),
            // Button(
            //   clickHandler: houseHandler,
            //   text: "Add offer",
            // ),
          ],
        ),
      ),
    );
  }

  void _showInfo(String id) {
    context.read<OfferFormProvider>().updateHouseId(id);
    Navigator.of(context).pushNamed(HouseDetailed.routeName, arguments: {
      'id': id,
    });
  }
}
