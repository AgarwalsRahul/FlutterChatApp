import 'package:flutter/material.dart';

class CategorySelector extends StatefulWidget {
  final AppBar appBar;
  CategorySelector({this.appBar});
  @override
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  int _selectedIndex = 0;
  final List<String> categories = ['Messages', 'Online', 'Groups', 'Requests'];
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context);
    return Container(
      height: (deviceSize.size.height -
              deviceSize.padding.top -
              widget.appBar.preferredSize.height) *
          0.12,
      color:Theme.of(context).primaryColor,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: (){
              setState(() {
                _selectedIndex=index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 25.0,
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color:
                      index == _selectedIndex ? Colors.white : Colors.white60,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          );
        },
        itemCount: categories.length,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
