import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pet_match/Models/pet_model.dart';
import 'package:pet_match/Services/firebase_services.dart';
import 'package:pet_match/main.dart';
import 'package:provider/provider.dart';
import '../../Constants/global_variables.dart';
import '../../Models/user_model.dart';
import '../../Services/location_services.dart';
import '../../Styles/app_style.dart';
import '../../Widgets/category_icon.dart';
import '../../Widgets/search_field.dart';
import '../categories_screen.dart';
import '../search_screen.dart';
import 'FavoriteWidgets/nearest_favorite.dart';
import 'HomeScreenWidgets/categories_header.dart';
import 'HomeScreenWidgets/location_header.dart';
import 'HomeScreenWidgets/pet_details.dart';
import 'bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String location = '';
  late Placemark place;
  LocationServices locationServices = LocationServices();
  TextEditingController searchController = TextEditingController();
  User? user;
  bool isGettingLocation = false;

  @override
  void initState() {
    updatePlace();
    init();
    super.initState();
  }

  init() async {
    await GlobalVariables.getCurrentUser();
    await GlobalVariables.getCategories();
    await GlobalVariables.getAllAccessories();
    setState(() {});
  }

  showBottomSheet() {
    final mq = MediaQuery.of(context).size;
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: mq.height * .3,
            width: mq.width,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(CupertinoIcons.arrow_up),
                  title: const Text('Name'),
                  onTap: () {
                    context.read<GlobalVariables>().setSortIndex(0);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(CupertinoIcons.arrow_down),
                  title: const Text('Name'),
                  onTap: () {
                    context.read<GlobalVariables>().setSortIndex(1);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(CupertinoIcons.arrow_up),
                  title: const Text('Age'),
                  onTap: () {
                    context.read<GlobalVariables>().setSortIndex(2);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(CupertinoIcons.arrow_down),
                  title: const Text('Age'),
                  onTap: () {
                    context.read<GlobalVariables>().setSortIndex(3);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(CupertinoIcons.arrow_up),
                  title: const Text('Breed'),
                  onTap: () {
                    context.read<GlobalVariables>().setSortIndex(4);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(CupertinoIcons.arrow_down),
                  title: const Text('Breed'),
                  onTap: () {
                    context.read<GlobalVariables>().setSortIndex(5);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(CupertinoIcons.arrow_up),
                  title: const Text('Weight'),
                  onTap: () {
                    context.read<GlobalVariables>().setSortIndex(6);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(CupertinoIcons.arrow_down),
                  title: const Text('Weight'),
                  onTap: () {
                    context.read<GlobalVariables>().setSortIndex(7);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(CupertinoIcons.arrow_up),
                  title: const Text('Last Vaccinated Date'),
                  onTap: () {
                    context.read<GlobalVariables>().setSortIndex(8);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(CupertinoIcons.arrow_down),
                  title: const Text('Last Vaccinated Date'),
                  onTap: () {
                    context.read<GlobalVariables>().setSortIndex(9);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(CupertinoIcons.arrow_up),
                  title: const Text('Created Date'),
                  onTap: () {
                    context.read<GlobalVariables>().setSortIndex(10);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(CupertinoIcons.arrow_down),
                  title: const Text('Created Date'),
                  onTap: () {
                    context.read<GlobalVariables>().setSortIndex(11);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(CupertinoIcons.arrow_up),
                  title: const Text('Distance'),
                  onTap: () {
                    context.read<GlobalVariables>().setSortIndex(12);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(CupertinoIcons.arrow_down),
                  title: const Text('Distance'),
                  onTap: () {
                    context.read<GlobalVariables>().setSortIndex(13);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  getPlaceMark() async {
    if (enableLocation != false) {
      setState(() {
        isGettingLocation = true;
      });
      LocationServices locationServices = LocationServices();
      try {
        Position position = await locationServices.getCurrentPosition();
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        Placemark place = placemarks[0];
        final data = ({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'location':
              '${place.name}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}',
        });
        FirebaseServices.firestore
            .collection(FirebaseServices.usersCollection)
            .doc(GlobalVariables.currentUser.id!)
            .update(data);
        setState(() {
          location = (place.subLocality!.isNotEmpty
              ? place.subLocality
              : place.locality ?? 'Location failed')!;
        });
        context.read<GlobalVariables>().setUserLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            location: location);
        setState(() {
          isGettingLocation = false;
        });
      } catch (e) {
        setState(() {
          isGettingLocation = false;
        });
        return Future.error(e);
      }
    }
  }

  updatePlace() async {
    if (enableLocation != false) {
      setState(() {
        isGettingLocation = true;
      });
      final userData = await FirebaseServices.firestore
          .collection(FirebaseServices.usersCollection)
          .doc(FirebaseServices.auth.currentUser!.uid)
          .get();
      user = User.fromJson(userData.data()!);
      if (user!.location == null ||
          user!.location!.isEmpty ||
          user!.latitude == null ||
          user!.longitude == null ||
          user!.latitude == 0 ||
          user!.longitude == 0) {
        LocationServices locationServices = LocationServices();
        try {
          Position position = await locationServices.getCurrentPosition();
          List<Placemark> placemarks = await placemarkFromCoordinates(
              position.latitude, position.longitude);
          Placemark place = placemarks[0];
          final data = ({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'location':
                '${place.name}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}',
          });
          FirebaseServices.firestore
              .collection(FirebaseServices.usersCollection)
              .doc(FirebaseServices.auth.currentUser!.uid)
              .update(data);
          setState(() {
            location = (place.subLocality!.isNotEmpty
                ? place.subLocality
                : place.locality ?? 'Location failed')!;
          });
          context.read<GlobalVariables>().setUserLocation(
              latitude: position.latitude,
              longitude: position.longitude,
              location: location);
          setState(() {
            isGettingLocation = false;
          });
        } catch (e) {
          setState(() {
            isGettingLocation = false;
          });
          return Future.error(e);
        }
      } else {
        List<Placemark> placemarks =
            await placemarkFromCoordinates(user!.latitude!, user!.longitude!);
        Placemark place = placemarks[0];
        setState(() {
          location = (place.subLocality!.isNotEmpty
              ? place.subLocality
              : place.locality ?? 'Location failed')!;
        });
        setState(() {
          isGettingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    List<PetModel> favPets = context
        .watch<GlobalVariables>()
        .approvedPets
        .where(
          (element) =>
              GlobalVariables.currentUser.favouritePets.contains(element.id!),
        )
        .toList();
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: mq.height * .05),
          child: Column(
            children: [
              Animate(
                effects: const [
                  SlideEffect(duration: Duration(milliseconds: 300)),
                  FadeEffect(
                      duration: Duration(
                    milliseconds: 300,
                  ))
                ],
                child: LocationHeader(
                  getLocation: getPlaceMark,
                  location: location,
                  isGettingLocation: isGettingLocation,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18.0, vertical: 25),
                child: Row(
                  children: [
                    Expanded(
                        child: SearchField(
                      controller: searchController,
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                child: const SearchScreen(),
                                type: PageTransitionType.fade));
                      },
                    )),
                    const SizedBox(
                      width: 30,
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: AppStyle.mainColor,
                          borderRadius: BorderRadius.circular(50)),
                      child: IconButton(
                        onPressed: () {
                          showBottomSheet();
                        },
                        icon: const Icon(
                          CupertinoIcons.sort_down,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ).animate().fade(),
              CategoriesHeader(
                category: "Categories",
                action: "View all",
                onTap: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          child: const CategoriesScreen(),
                          type: PageTransitionType.rightToLeft));
                },
              ).animate().slideY(begin: 1, end: 0),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: GlobalVariables.categories.length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8),
                      child: CategoryIcon(
                          category: GlobalVariables.categories[index]),
                    );
                  },
                ),
              ).animate().slideX(begin: 1, end: 0),
              const PetDetails().animate().blurXY(begin: 10, end: 0),
              SizedBox(
                height: mq.height * .04,
              ),
              favPets.isEmpty
                  ? const SizedBox()
                  : CategoriesHeader(
                          category: 'Favorites',
                          action: 'View All',
                          onTap: () {
                            navigationKey.currentState!.setPage(2);
                          })
                      .animate()
                      .scale(
                          begin: const Offset(2, 2), end: const Offset(1, 1)),
              favPets.isEmpty
                  ? const SizedBox()
                  : NearestFavorite(pets: favPets).animate().saturate(),
              SizedBox(
                height: mq.height * .05,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
