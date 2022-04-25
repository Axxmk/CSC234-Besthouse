import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../screens/house_detailed.dart';

// widgets
import '../services/provider.dart';
import '../widgets/common/tag.dart';
import '../widgets/common/house_detail_card.dart';
import '../widgets/search/filter_sheet.dart';

// models
import '../models/accommodation.dart';
import '../models/facilities.dart';
import '../models/house.dart';
import 'google_location.dart';

class Search extends StatefulWidget {
  static const routeName = "/search";

  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final String _apiKey = "AIzaSyBugQOo_mjZGdkM7ud_VGCNh-oriwAglv4";
  final List<House> houses = [
    House(
      id: "634gf3438",
      name: "Cosmo Home",
      pictureUrl:
          "https://images.theconversation.com/files/377569/original/file-20210107-17-q20ja9.jpg?ixlib=rb-1.1.0&rect=108%2C502%2C5038%2C2519&q=45&auto=format&w=1356&h=668&fit=crop",
      price: 4000,
      location: Location(
        coordinates: [-6.2108, 106.8451],
      ),
      address: 'Soi 45 Prachauthid Thungkru, Bangkok',
      type: 'CONDOMINIUM',
    ),
    House(
      id: "634gf3438",
      name: "Heliconia House",
      pictureUrl:
          "https://images.theconversation.com/files/377569/original/file-20210107-17-q20ja9.jpg?ixlib=rb-1.1.0&rect=108%2C502%2C5038%2C2519&q=45&auto=format&w=1356&h=668&fit=crop",
      price: 6000,
      location: Location(
        coordinates: [13.2108, 107.8451],
      ),
      address: 'KMUTT university Prachauthid Thungkru, Bangkok',
    ),
    House(
      id: "634gf3438",
      name: "Cosmo Home",
      pictureUrl:
          "https://images.theconversation.com/files/377569/original/file-20210107-17-q20ja9.jpg?ixlib=rb-1.1.0&rect=108%2C502%2C5038%2C2519&q=45&auto=format&w=1356&h=668&fit=crop",
      price: 4000,
      location: Location(
        coordinates: [-6.2108, 106.8451],
      ),
      address: 'Soi 45 Prachauthid Thungkru, Bangkok',
      type: 'CONDOMINIUM',
    ),
    House(
      id: "634gf3438",
      name: "Heliconia House",
      pictureUrl:
          "https://images.theconversation.com/files/377569/original/file-20210107-17-q20ja9.jpg?ixlib=rb-1.1.0&rect=108%2C502%2C5038%2C2519&q=45&auto=format&w=1356&h=668&fit=crop",
      price: 6000,
      location: Location(
        coordinates: [13.2108, 107.8451],
      ),
      address: 'KMUTT university Prachauthid Thungkru, Bangkok',
    ),
  ];
  RangeValues currentRangeValues = const RangeValues(0, 20000);

  List<AccommodationObject> radioList = [
    AccommodationObject("All", Accommodation.all),
    AccommodationObject("House", Accommodation.house),
    AccommodationObject("Condo", Accommodation.condo),
    AccommodationObject("Hotel", Accommodation.hotel),
  ];
  Accommodation? type = Accommodation.all;

  List<Facilities> checkboxList = [
    Facilities("Wifi", false),
    Facilities("Parking", false),
    Facilities("Aircondition", false),
    Facilities("Water heater", false),
    Facilities("Fitness", false),
    Facilities("Swimming pool", false),
    Facilities("Fan", false),
    Facilities("Furnishes", false),
  ];

  List<String> get selectedFacilities {
    var list = checkboxList.where((element) => element.checked);
    var result = list.map((e) => e.name);
    return result.toList();
  }

  void slideHandler(RangeValues values) {
    setState(() {
      currentRangeValues = values;
    });
  }

  void radioHandler(Accommodation? value) {
    setState(() {
      type = value;
    });
  }

  void checkBoxHandler(value, e) {
    setState(() {
      e.checked = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition location;
    bool isDesireLocation = context.watch<DesireLocation>().location.target.latitude != 90.0 &&
        context.watch<DesireLocation>().location.target.longitude != -160;
    if (isDesireLocation) {
      location = context.watch<DesireLocation>().location;
    } else {
      location = context.watch<CurrentLocation>().currentLocation;
    }

    return location.target.latitude == 100
        ? const SpinKitRing(
            color: Color(0xFF24577A),
            size: 50.0,
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/google_location',
                      arguments: GoogleLocationArgument(location),
                    ).then((value) {
                      setState(() {});
                    });
                  },
                  child: Image.network(
                    "https://maps.googleapis.com/maps/api/staticmap?center=${location.target.latitude},${location.target.longitude}&zoom=16&size=${MediaQuery.of(context).size.width.toInt()}x200&key=$_apiKey",
                    fit: BoxFit.cover,
                  ),
                ),
                // Map(currentLocation: widget.currentLocation),
                Padding(
                  padding: const EdgeInsets.only(top: 9.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 60,
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: selectedFacilities.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            return Tag(
                              title: index == 0
                                  ? radioList.firstWhere((e) => e.type == type).name
                                  : selectedFacilities[index - 1],
                            );
                          },
                        ),
                      ),
                      Ink(
                        width: 40,
                        height: 40,
                        decoration: ShapeDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          shape: const CircleBorder(),
                        ),
                        child: IconButton(
                          splashRadius: 20,
                          iconSize: 20,
                          icon: Icon(Icons.filter_list,
                              color: Theme.of(context).colorScheme.secondary),
                          onPressed: () {
                            _buildModal(context);
                          },
                          tooltip: 'Filter',
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(
                    indent: 12,
                    endIndent: 12,
                    color: Colors.grey,
                  ),
                ),
                houses.isNotEmpty
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height - 430,
                        child: ListView.builder(
                          itemCount: houses.length,
                          itemBuilder: (BuildContext context, int index) {
                            return HouseDetailCard(
                              house: houses[index],
                              showInfoHandler: _showInfo,
                            );
                          },
                        ),
                      )
                    : const Text('No houses found'),
              ],
            ),
          );
  }

  void _showInfo(String id) {
    Navigator.of(context).pushNamed(HouseDetailed.routeName, arguments: {
      'id': id,
    });
  }

  void _buildModal(BuildContext ctx) {
    showModalBottomSheet<dynamic>(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        context: ctx,
        builder: (_) {
          return FilterSheet(
            checkBoxHandler: checkBoxHandler,
            checkboxList: checkboxList,
            currentRangeValues: currentRangeValues,
            radioHandler: radioHandler,
            radioList: radioList,
            slideHandler: slideHandler,
            type: type,
          );
        });
  }
}
