import 'package:cloud_functions/cloud_functions.dart';

class SystemResetService {
  SystemResetService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  Future<Map<String, dynamic>> resetAllExceptAdmins() async {
    final callable = _functions.httpsCallable('resetSystemExceptAdmins');
    final response = await callable.call();
    final data = response.data;

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return <String, dynamic>{};
  }
}