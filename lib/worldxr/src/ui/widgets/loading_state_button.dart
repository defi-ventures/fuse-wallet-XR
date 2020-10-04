import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusecash/worldxr/src/ui/style.dart';

class LoadingStateButton<LoadingState> extends StatelessWidget {
  final dynamic button;
  final Bloc bloc;

  const LoadingStateButton({Key key, this.button, this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      cubit: bloc,
      builder: (context, state) {
        if (state is LoadingState) {
          return Container(
            color: Colors.transparent,
            child: Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue_grey),
            )),
          );
        }
        return button;
      },
    );
  }
}
