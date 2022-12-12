List<String> categories = [
  '記憶力',
  '注意力',
];

List<List<String>> gameNames = [
  [
    '配對遊戲',
    '記憶力遊戲2',
    '記憶力遊戲3',
    '記憶力遊戲4',
  ],
  [
    '注意力遊戲1',
    '注意力遊戲2',
  ],
];

List<List<String>> gameImgs = [
  [
    "assets/gameinfos/puzzle.png",
    "assets/images/circle.png",
    "assets/images/circle.png",
    "assets/images/circle.png",
  ],
  [
    "assets/images/star.png",
    "assets/images/star.png",
  ],
];

List<List<String>> gameRoutes = [
  [
    "/match",
    "/empty",
    "/empty",
    "/empty",
  ],
  [
    "/",
    "/",
  ],
];
class GameInfo {
  String name;
  String image;

  GameInfo({
    required this.name,
    required this.image,
  });
}

class GameList {
  List<String> gameCateNames = [
    '記憶力',
    '注意力',
  ];

  static const List<List<String>> gameNames = [
    [
      '配對遊戲',
      '記憶力遊戲2',
      '記憶力遊戲3',
      '記憶力遊戲4',
    ],
    [
      '注意力遊戲1',
      '注意力遊戲2',
    ],
  ];

  List<List<String>> gameImgs = [
    [
      "assets/images/circle.png",
      "assets/images/circle.png",
      "assets/images/circle.png",
      "assets/images/circle.png",
    ],
    [
      "assets/images/circle.png",
      "assets/images/circle.png",
    ],
  ];
}
