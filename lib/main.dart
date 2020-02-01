import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flightmaker/CustomShapeClipper.dart';
import 'package:flightmaker/customAppBar.dart';
import 'package:flightmaker/flight_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cached_network_image/cached_network_image.dart';

Future<void> main() async {
  
      final FirebaseApp app = await FirebaseApp.configure(  
        name: 'flight-app-prac',
        options: Platform.isAndroid ? 
        const FirebaseOptions(
          googleAppID: '1:458007309770:android:87105adac13ead7b',
          apiKey: 'AIzaSyBaTPLqRdn4zOLFSNnlPR4RGXkjeDo8zPg',
          databaseURL: 'https://flight-app-prac.firebaseio.com/',          
          ) : 

        const FirebaseOptions(
          googleAppID: '1:458007309770:ios:87105adac13ead7b',
          gcmSenderID: '458007309770',
          databaseURL: 'https://flight-app-prac.firebaseio.com/',          
          ) 
          

      );
  
   runApp(MaterialApp(
      title: 'Flight List Mock Up',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
      theme: appTheme,
    ));

    }

Color firstColor = Color(0xFFF47D15);
Color secondColor = Color(0xFFEF772C);

ThemeData appTheme =
    ThemeData(primaryColor: Color(0xFFF3791A), fontFamily: 'Roboto');

List<String> locations = List();

class Locations {
  final String name;
 
    Locations.fromMap(Map<String, dynamic > map )
          : assert (map['name'] != null),          
           name = map['name'];
           
  Locations.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);

}

addLocations(BuildContext context, List<DocumentSnapshot> snapshots){
    for(int i= 0; i < snapshots.length; i++){
        final Locations location = Locations.fromSnapshot(snapshots[i]);
        locations.add(location.name);
    }
}

List<PopupMenuItem<int>>  _buildPopupMenuItem(){
  List<PopupMenuItem<int>> popupMenuItems = List();

  for(int i= 0; i < locations.length; i++){
    popupMenuItems.add(
      PopupMenuItem(
          child: Text(
            locations[i],
            style: dropDownMenuItemStyle,
          ),
          value: i,
      )
    );
  }
  return popupMenuItems;
}
const TextStyle dropDownLabelStyle =
    TextStyle(color: Colors.white, fontSize: 16.0);
const TextStyle dropDownMenuItemStyle =
    TextStyle(color: Colors.black, fontSize: 16.0);
final _searchFieldController = TextEditingController(); 

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomAppBAr(),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: <Widget>[
            HomeScreenTopPart(),
            homeScreenBottomPart,
          ],
        ),
      ),
    );
  }
}

class HomeScreenTopPart extends StatefulWidget {
  @override
  _HomeScreenTopPartState createState() => _HomeScreenTopPartState();
}

class _HomeScreenTopPartState extends State<HomeScreenTopPart> {
  var selectedLocationIndex = 0;
  var isFlightSelected = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: CustomShapeClipper(),
          child: Container(
            height: 400,
            //  color: Colors.orange,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [firstColor, secondColor])),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 50.0,
                ),
                StreamBuilder(
                  stream: Firestore.instance.collection('locations').snapshots(),
                  builder: (context , snapshot) {
                    if(snapshot.hasData)
                      addLocations(context, snapshot.data.documents);

                    return !snapshot.hasData
                    ? Container() :                  
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      PopupMenuButton(
                        onSelected: (index) {
                          setState(() {
                            selectedLocationIndex = index;
                          });
                        },
                        child: Row(
                          children: <Widget>[
                            Text(
                              locations[selectedLocationIndex],
                              style: dropDownLabelStyle,
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                            )
                          ],
                        ),
                        itemBuilder: (BuildContext context) => _buildPopupMenuItem(),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.settings),
                        color: Colors.white,
                        onPressed: () {},
                      )
                    ],
                  ),
                  );
                },
                ),
                SizedBox(
                  height: 50.0,
                ),
                Text(
                  // 'where would you \n \b\b want to go?',
                  'where would you \n want to go?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    child: TextField(
                      controller: _searchFieldController,
                      style: dropDownMenuItemStyle,
                      cursorColor: appTheme.primaryColor,                      
                      decoration: InputDecoration(
                        hintText: 'Type location',
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 32.0, vertical: 14.0),
                        suffixIcon: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    InheritedFlightListing(
                                          fromLocation: locations[selectedLocationIndex],
                                          toLocation: _searchFieldController.text,
                                          child: FlightListingScreen(),
                                        )
                                        ));
                          },
                          child: Material(
                            elevation: 0.3,
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                            child: Icon(Icons.search, color: Colors.black),
                          ),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                      child: ChoiceChip(
                        icon: Icons.flight_takeoff,
                        text: "Flights",
                        isSelected: isFlightSelected,
                      ),
                      onTap: () {
                        setState(() {
                          isFlightSelected = true;
                        });
                      },
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    InkWell(
                      child: ChoiceChip(
                        icon: Icons.hotel,
                        text: "Hotels",
                        isSelected: !isFlightSelected,
                      ),
                      onTap: () {
                        setState(() {
                          isFlightSelected = false;
                        });
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ChoiceChip extends StatefulWidget {
  final IconData icon;
  final text;
  final bool isSelected;

  ChoiceChip({this.icon, this.text, this.isSelected});

  @override
  _ChoiceChipState createState() => _ChoiceChipState();
}

class _ChoiceChipState extends State<ChoiceChip> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: widget.isSelected
          ? BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.all(Radius.circular(20.0)))
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Icon(
            widget.icon,
            size: 20.0,
            color: Colors.white,
          ),
          SizedBox(
            width: 8.0,
          ),
          Text(
            widget.text,
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          )
        ],
      ),
    );
  }
}

var viewStyleAll =
    TextStyle(fontSize: 14.0, color: appTheme.primaryColor, letterSpacing: 1.0);

var homeScreenBottomPart = Column(
  children: <Widget>[
    Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text('Currently Watched Items', style: TextStyle(fontSize: 15)),
        Text(
          'View All(12)',
          style: viewStyleAll,
        ),
      ],
    ),
    SizedBox(height: 10),
    Container(
      height: 230.0,
      child: StreamBuilder(
        stream: Firestore.instance.collection('cities').orderBy('newPrice').snapshots(),
         builder :(context, snapshot) {
           print('${snapshot.hasData}');
                return !snapshot.hasData 
                ? Center(child : CircularProgressIndicator()) :
                _buildCitiesList(context , snapshot.data.documents);
            },
      )
    ),
  ],
);

final formatCurrency = NumberFormat.simpleCurrency();


Widget _buildCitiesList(BuildContext context, List<DocumentSnapshot> snapshots){
  return  ListView.builder(
        itemCount: snapshots.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
              return CityCard(city: City.fromSnapshot(snapshots[index]));
        },
      );
}

class City {
  final int newPrice , oldPrice;
  final String name, imagePath, monthYear, discount;
 
    City.fromMap(Map<String, dynamic > map )
          : assert (map['name'] != null),
           assert (map['monthYear'] != null),
           assert (map['discount'] != null),
           assert (map['imagePath'] != null),

           imagePath = map['imagePath'],
           name = map['name'],
           discount = map['discount'],
           monthYear = map['monthYear'],
           newPrice = map['newPrice'],
           oldPrice = map['oldPrice']; 

  City.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);

}

class CityCard extends StatelessWidget {
  
  final City city;

  CityCard({this.city});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            child: Stack(
              children: <Widget>[
                Container(
                  height: 194,
                  width: 160,
                  child: CachedNetworkImage(
                    imageUrl: '${city.imagePath}',
                    fit: BoxFit.cover,
                    fadeInDuration: Duration(milliseconds: 500),
                    fadeInCurve: Curves.easeIn,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error)
                  ),
                ),
                Positioned(
                  left: 0.0,
                  top: 0.0,
                  height: 60,
                  width: 160,
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.black12.withOpacity(0.0)
                        ])),
                  ),
                ),
                Positioned(
                  left: 10.0,
                  top: 10.0,
                  right: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${city.name}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 17.0),
                          ),
                          Text(
                           '${city.monthYear}',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                                fontSize: 14.0),
                          ),
                        ],
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            color: Colors.white,
                          ),
                          child: Text(
                            "${city.discount}%",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ))
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 5.0,
              ),
              Text(
                '${formatCurrency.format(city.newPrice)}',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                "(${formatCurrency.format(city.oldPrice)})",
                style: TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.normal),
              )
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
        ],
      ),
    );
  }
}
