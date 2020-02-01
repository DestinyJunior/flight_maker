import 'package:flightmaker/CustomShapeClipper.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


final Color discountBackgroundColor = Color(0xFFFFE08D);
final Color flightBorderColor = Color(0xFFE6E6E6);
final Color chipBackgroundColor = Color(0xFFF6F6F6);

class InheritedFlightListing extends InheritedWidget {
  final String fromLocation, toLocation;

  InheritedFlightListing({this.fromLocation, this.toLocation, Widget child})
      : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static InheritedFlightListing of(BuildContext context) => 
  context.inheritFromWidgetOfExactType(InheritedFlightListing);

}

class FlightListingScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Search Results'),
        centerTitle: true,
        // leading: InkWell(
        //   child: Icon(Icons.arrow_back),
        //   onTap: () {
        //     Navigator.pop(context);
        //   },
        // ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            FlightListTopPart(),
            SizedBox(
              height: 20.0,
            ),
            FlightListBottomPart()
          ],
        ),
      ),
    );
  }
}

class FlightListTopPart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: CustomShapeClipper(),
          child: Container(
            height: 160.0,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [firstColor, secondColor])),
          ),
        ),
        Column(
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6))),
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              elevation: 10.0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 22.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${InheritedFlightListing.of(context).fromLocation}',
                              style: TextStyle(fontSize: 16.0)),
                          Divider(color: Colors.grey, height: 20.0),
                          Text('${InheritedFlightListing.of(context).toLocation}',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    // Spacer(),
                    Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.import_export,
                          color: Colors.black,
                          size: 32.0,
                        )),
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}

class FlightListBottomPart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Best Deals for Next 6 Months',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          StreamBuilder(
            stream: Firestore.instance.collection('deals').snapshots(),
            builder: (context, snapshot) {
                return !snapshot.hasData 
                ? Center(child : CircularProgressIndicator()) :
                _buildDealsList(context , snapshot.data.documents);
            },
          )
        ],
      ),
    );
  }
}

Widget _buildDealsList(BuildContext context, List<DocumentSnapshot> snapshots){
        return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshots.length,
            scrollDirection: Axis.vertical,
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              return FlightCard(
                flightDetails: FlightDetails.fromSnapshot(snapshots[index]),  
              );
            },
                  
        );
}

class FlightDetails {
  final int newPrice , oldPrice;
  final String date, airways, rate, discount;
 
    FlightDetails.fromMap(Map<String, dynamic > map )
          : assert (map['airlines'] != null),
           assert (map['date'] != null),
           assert (map['discount'] != null),
           assert (map['rating'] != null),

           airways = map['airlines'],
           date = map['date'],
           discount = map['discount'],
           rate = map['rating'],
           newPrice = map['newPrice'],
           oldPrice = map['oldPrice']; 

  FlightDetails.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);

}
class FlightCard extends StatelessWidget {

  final FlightDetails flightDetails;


  FlightCard({this.flightDetails});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              border: Border.all(color: flightBorderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        '${formatCurrency.format(flightDetails.newPrice)}',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        "(${formatCurrency.format(flightDetails.oldPrice)})",
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 3.5,
                    runSpacing: -3.5,
                    children: <Widget>[
                      FlightDetailChip(
                          iconData: Icons.calendar_today, label: '${flightDetails.date}'),
                      FlightDetailChip(
                          iconData: Icons.flight_takeoff, label: '${flightDetails.airways}'),
                      FlightDetailChip(iconData: Icons.star, label: '${flightDetails.rate}'),
                    ],
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 10.0,
            right: 0.0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                '${flightDetails.discount}%',
                style: TextStyle(
                    color: appTheme.primaryColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold),
              ),
              decoration: BoxDecoration(
                  color: discountBackgroundColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
            ),
          ),
        ],
      ),
    );
  }
}

class FlightDetailChip extends StatelessWidget {
  @required
  final IconData iconData;
  @required
  final String label;
  FlightDetailChip({this.iconData, this.label});

  @override
  Widget build(BuildContext context) {
    return RawChip(
      label: Text(label),
      labelStyle: TextStyle(color: Colors.black, fontSize: 9),
      backgroundColor: chipBackgroundColor,
      avatar: Icon(
        iconData,
        size: 11.0,
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
    );
  }
}
