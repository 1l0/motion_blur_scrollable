import 'package:flutter/material.dart';

import 'package:scroll_experiments/motion_blur_scrollable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scrollable Demo',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: Content(),
      ),
    );
  }
}

class Content extends StatelessWidget {
  const Content({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: ScrollableBlur(
          child: ColoredBox(
            color: const Color(0xFFFFFFFF),
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                if (index % 5 == 0) {
                  return const Title('Oslo photos');
                }
                return RandomOsloPhoto(
                  key: ValueKey(index),
                  index: index,
                );
              },
              itemCount: 100,
            ),
          ),
        ),
      ),
    );
  }
}

class RandomOsloPhoto extends StatefulWidget {
  const RandomOsloPhoto({
    super.key,
    required this.index,
  });

  final int index;

  @override
  State<RandomOsloPhoto> createState() => _RandomOsloPhotoState();
}

class _RandomOsloPhotoState extends State<RandomOsloPhoto>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Image.network(
        'https://source.unsplash.com/800x600/?vikings,oslo,${widget.index}',
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class Title extends StatelessWidget {
  const Title(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Text(
        title,
        style: style,
      ),
    );
  }
}
