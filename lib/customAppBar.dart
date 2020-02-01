import 'package:flutter/material.dart';

class CustomAppBAr extends StatelessWidget {
  final List<BottomNavigationBarItem> bottomBarItems = [];

  final bottomNavigationBarItemStyle =
      TextStyle(color: Colors.black, fontStyle: FontStyle.normal);

  CustomAppBAr() {
    bottomBarItems.add(
      BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.black),
          title: Text('Explore', style: bottomNavigationBarItemStyle)),
    );
    bottomBarItems.add(
      BottomNavigationBarItem(
          icon: Icon(Icons.favorite, color: Colors.black),
          title: Text('WatchList', style: bottomNavigationBarItemStyle)),
    );
    bottomBarItems.add(
      BottomNavigationBarItem(
          icon: Icon(Icons.local_offer, color: Colors.black),
          title: Text('Deals', style: bottomNavigationBarItemStyle)),
    );
    bottomBarItems.add(
      BottomNavigationBarItem(
          icon: Icon(Icons.notifications, color: Colors.black),
          title: Text('Notifications', style: bottomNavigationBarItemStyle)),
    );
  }
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: bottomBarItems,
      elevation: 0.0,
      type: BottomNavigationBarType.fixed,
    );
  }
}
