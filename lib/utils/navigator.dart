import 'package:flutter/material.dart';

navigation(BuildContext context, Widget widget) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
}

navigationCallBack(BuildContext context, Widget widget,{required void Function(dynamic) callBack}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => widget)).then(callBack);
}

navPushRemoveUntil(BuildContext context, Widget widget){
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => widget),
          (Route<dynamic> route) => false);
}
navigationReplace(BuildContext context, Widget widget) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => widget));
}