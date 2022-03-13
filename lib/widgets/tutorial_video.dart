import 'package:dojo_app/style/style_misc.dart';
import 'package:flutter/material.dart';

class TutorialVideo extends StatelessWidget {
  const TutorialVideo({Key? key, this.gifAsset = 'images/pushup_with_cat4.gif'}) : super(key: key);

  final String gifAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius2(),
        boxShadow: [boxShadow1()],
      ),
      height: (MediaQuery.of(context).size.height) * .40,
      width: (MediaQuery.of(context).size.width) * .70,
      child: ClipRRect(
        borderRadius: borderRadius2(),
        child: Image(image: AssetImage(gifAsset), fit: BoxFit.fill),
        //child: Image(image: NetworkImage(gifAsset), fit: BoxFit.fill),
      ),
    );
  }
} // end gameBloc()
