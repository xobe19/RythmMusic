import 'package:hive/hive.dart';

Future getSongIdList() async {
   var lazyBox4 = await Hive.openLazyBox('main');
return lazyBox4.get('ids');

}
