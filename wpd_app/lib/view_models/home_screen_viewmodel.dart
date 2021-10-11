import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wpd_app/api/http_client.dart';
import 'package:wpd_app/api/json_parsers/case_list_parser.dart';
import 'package:wpd_app/models/case/case.dart';
import 'package:wpd_app/services/service_locator.dart';

abstract class HomeScreenViewModelProvider {
  static final provider = ChangeNotifierProvider(
    (ref) => HomeScreenViewModel(),
  );
}

class HomeScreenViewModel extends ChangeNotifier {
  final _requestRest = serviceLocator<RequestREST>();

  List<Case> myCases = [];

  bool _loading = false;
  bool get isLoading => _loading;

  Future<void> getCases({bool refresh = false}) async {
    try {
      _loading = true;

      if (refresh == true) {
        notifyListeners();
      }

      var data = await _requestRest.executeGet<List<Case>>(
        '/cases?sort=title&limit=1000',
        const CaseListParser(),
      );

      myCases = data;
      _loading = false;
      notifyListeners();
    } on DioError catch (e) {
      BotToast.showText(text: e.message);

      _loading = false;
      notifyListeners();
    } catch (e) {
      BotToast.showText(text: 'Error');
      _loading = false;
      notifyListeners();
    }
  }
}
