import 'package:flutter/material.dart';
import 'data.dart' as gameInfo;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: gameInfo.categories.length,
              itemBuilder: (context, index) {
                print(gameInfo.gameNames[0].length);
                return Category(index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Category extends StatelessWidget {
  const Category({
    Key? key,
    required this.index,
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      child: Column(
        children: [
          Text(
            gameInfo.categories[index],
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 32,
            ),
          ),
          Expanded(
            child: ListView.builder(
              //physics: ScrollPhysics(),
              scrollDirection: Axis.horizontal,
              //shrinkWrap: true,
              itemCount: gameInfo.gameNames[index].length,
              itemBuilder: (BuildContext context, index2) {
                return Info(
                    name: gameInfo.gameNames[index][index2],
                    route: gameInfo.gameRoutes[index][index2],
                    imagePath: gameInfo.gameImgs[index][index2]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Info extends StatelessWidget {
  const Info({
    Key? key,
    required this.name,
    required this.route,
    required this.imagePath,
  }) : super(key: key);

  final String name;
  final String route;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 10 / 10,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: GestureDetector(
          onTap: () {
            print("tapped");
            Navigator.of(context).pushNamed(route); // route
          },
          child: Card(
            elevation: 5,
            color: Colors.tealAccent,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Column(
              children: [
                Flexible(
                  flex: 4,
                  child: Image.asset(imagePath),
                ),
                SizedBox(height: 20),
                Flexible(
                  flex: 1,
                  child: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 30,
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Text(
                    route,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
