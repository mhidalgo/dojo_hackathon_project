import 'package:flutter/cupertino.dart';
import 'package:simple_animations/simple_animations.dart';

class LoadingVideoOverlay extends StatelessWidget {
  const LoadingVideoOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: 0.5,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              tileMode: TileMode.mirror,
              begin: Alignment.bottomLeft,
              end: Alignment(0.1, -1.0),
              colors: [
                Color(0xfff44336),
                Color(0x4bf32166),
              ],
              stops: [
                0,
                1,
              ],
            ),
            backgroundBlendMode: BlendMode.saturation,
          ),
          child: PlasmaRenderer(
            type: PlasmaType.infinity,
            particles: 17,
            color: Color(0xafd5070b),
            blur: 0.5,
            size: 0.5830834600660535,
            speed: 3.916667302449544,
            offset: 0,
            blendMode: BlendMode.plus,
            particleType: ParticleType.atlas,
            variation1: 0,
            variation2: 0,
            variation3: 0,
            rotation: 0,
          ),
        )
    );
  }
}
