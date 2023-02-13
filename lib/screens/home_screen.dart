import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import '../modelClass/category_item.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    Size mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomPaint(
        painter:
            BackgroundCircle(height: mediaSize.height, width: mediaSize.width),
        child: Stack(
          children: [
            ListView(
              children: const [
                SizedBox(
                  height: 48,
                ),
                Header(),
                CustomTextFiled(),
                MenuCard(),
                CategoryItems(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: ItemsGrid(),
                )
              ],
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: CustomNabBar(),
            )
          ],
        ),
      ),
    );
  }
}

class CustomNabBar extends StatefulWidget {
  const CustomNabBar({
    super.key,
  });

  @override
  State<CustomNabBar> createState() => _CustomNabBarState();
}

class _CustomNabBarState extends State<CustomNabBar> {
  int selectedIndex = 1;
  List<String> navIcons = ["profile", "home", "category"];

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: 1,
      height: 70,
      onTap: (index) {
        setState(() {
          selectedIndex = index;
        });
      },
      color: Colors.white,
      backgroundColor: Colors.transparent,
      buttonBackgroundColor: const Color(0xff00424E),
      items: [
        for (int iconIndex = 0; iconIndex < navIcons.length; iconIndex++)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image(
              width: 27,
              height: 27,
              image: selectedIndex == iconIndex
                  ? AssetImage("assets/enable_${navIcons[iconIndex]}.png")
                  : AssetImage("assets/${navIcons[iconIndex]}.png"),
            ),
          ),
      ],
    );
  }
}

String locationName = "";
bool called = true;

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  late Geolocator geolocator;
  bool isLoadedSecondTime = false;
  Future<void> _determinePosition(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    try {
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          locationName = "The current location is unknown";
          return;
        } else if (permission == LocationPermission.deniedForever) {
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                "Allow GPS Permisson",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      openAppSettings();
                      return;
                    },
                    child: const Text(
                      "Open Settings",
                    ),
                  ),
                )
              ],
            ),
          );
        }
      }
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> place =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      locationName = place[0].locality.toString();
      setState(() {});
      return;
    } catch (e) {
      if (!isLoadedSecondTime) {
        try {
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text(
                  "Location Permission",
                  textAlign: TextAlign.center,
                ),
                actionsAlignment: MainAxisAlignment.spaceAround,
                actions: [
                  Center(
                    child: ElevatedButton(
                      style: Theme.of(context).elevatedButtonTheme.style,
                      onPressed: () {
                        Navigator.pop(context);
                        _determinePosition(context);
                        isLoadedSecondTime = true;
                      },
                      child: const Text("Allow Permission"),
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      style: Theme.of(context).elevatedButtonTheme.style,
                      onPressed: () {
                        locationName = "The current location is unknown";
                        Navigator.pop(context);
                        if (permission != LocationPermission.deniedForever) {
                          Navigator.pop(context);
                        }
                        return;
                      },
                      child: const Text("Continue without Location"),
                    ),
                  )
                ],
              );
            },
          );
        } catch (e) {}
      }
    }
    locationName = "The current location is unknown";
  }

  @override
  void initState() {
    if (locationName == "" && called) {
      called = false;
      _determinePosition(context);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 80,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    "Your Location",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 12, fontWeight: FontWeight.w200),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  Container(
                    height: 4,
                    width: 7,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/down.png',
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xffF2994A),
                  ),
                  Text(
                    locationName == ""
                        ? "The current location is unknown"
                        : locationName,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  )
                ],
              )
            ],
          ),
          const Spacer(),
          Container(
            height: 20.75,
            width: 23,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/shoping.png"),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CustomTextFiled extends StatelessWidget {
  const CustomTextFiled({super.key});

  @override
  Widget build(BuildContext context) {
    double mediaWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: mediaWidth - 32,
        decoration: BoxDecoration(
          color: const Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          cursorColor: Colors.black,
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.center,
          style: Theme.of(context).textTheme.bodySmall,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            filled: true,
            hintText: "Search",
            hintStyle: Theme.of(context).textTheme.bodySmall,
            prefixIcon: Container(
              height: 10,
              width: 10,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/search.png'),
                ),
              ),
            ),
            fillColor: Colors.transparent,
            border: const OutlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  const MenuCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 1,
                    spreadRadius: 1,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image(
                  image: index % 2 != 0
                      ? const AssetImage('assets/test.png')
                      : const AssetImage('assets/bur.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryItems extends StatelessWidget {
  const CategoryItems({super.key});

  @override
  Widget build(BuildContext context) {
    List<CategoryItemData> items = [
      CategoryItemData(fileName: "pizza_icon", itemName: "Pizza"),
      CategoryItemData(fileName: "burger_icon", itemName: "Burger"),
      CategoryItemData(fileName: "hotdog_icon", itemName: "Hotdog")
    ];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index != 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: const MaterialStatePropertyAll(
                        Color(0xffF8F8F8),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    onPressed: () {},
                    child: Row(
                      children: [
                        Container(
                          height: 24,
                          width: 24,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: AssetImage(
                                  'assets/${items.elementAt(index - 1).fileName}.png'),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          items.elementAt(index - 1).itemName,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: SizedBox(
                width: 60,
                height: 40,
                child: ElevatedButton(
                  style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                          shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      )),
                  onPressed: () {},
                  child: Text(
                    "All",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ItemsGrid extends StatelessWidget {
  const ItemsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: const [
              FoodsCard(foodType: "Meet"),
              Spacer(),
              FoodsCard(
                foodType: "Neapolitan",
              )
            ],
          ),
        );
      },
    );
  }
}

class FoodsCard extends StatelessWidget {
  const FoodsCard({required this.foodType, super.key});
  final String foodType;

  @override
  Widget build(BuildContext context) {
    double mediaheight = 216;
    double mediaWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: mediaWidth * 0.4,
      child: Stack(
        children: [
          SizedBox(
            height: mediaheight,
            width: mediaWidth * 0.4,
            child: Column(
              children: [
                Container(
                  color: Colors.transparent,
                  height: 32,
                ),
                Container(
                  height: (mediaheight) - 32,
                  width: mediaWidth * 0.4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xffF8F8F8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        spreadRadius: 0,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 84,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              foodType,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xff4F4F4F)),
                            ),
                            const Spacer(),
                            Container(
                              height: 16,
                              width: 16,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("assets/star.png"),
                                ),
                              ),
                            ),
                            Text(
                              "5.0",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          child: Text(
                            "Pizza is made with maida and some ingredients,kknjjjhljkhjk",
                            maxLines: 2,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    fontWeight: FontWeight.w300, fontSize: 10),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const SizedBox(
                            width: 16,
                          ),
                          Text(
                            "125\$",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: const Color(0xff4F4F4F)),
                          ),
                          const Spacer(),
                          Container(
                            width: 56,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xffB4DC2F),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                            ),
                            child: const Center(
                              child: Image(
                                width: 23.01,
                                height: 20.75,
                                image: AssetImage('assets/outlIne_cart.png'),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const Align(
            alignment: Alignment.topCenter,
            child: ClipOval(
              child: Image(
                width: 120,
                height: 120,
                image: AssetImage(
                  "assets/pizza.png",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundCircle extends CustomPainter {
  double height;
  double width;
  BackgroundCircle({required this.height, required this.width});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xffB4DC2F)
      ..strokeWidth = 1;

    canvas.drawOval(
        Rect.fromPoints(
          const Offset(230, 190),
          Offset(width + 122.5, 5),
        ),
        paint);

    canvas.drawOval(
        Rect.fromPoints(
          const Offset(200, 200),
          Offset(width + 150, 1),
        ),
        paint);

    canvas.drawOval(
        Rect.fromPoints(
          const Offset(170, 210),
          Offset(width + 100, 1),
        ),
        paint);

    Paint top = Paint()..color = Colors.white;
    canvas.drawRect(const Offset(0, 0) & Size(width, 36), top);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
