import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

const currency = {'name': 'Currency', 'route': 'currency'};

class API {
  final httpClient = HttpClient();
  final url = 'flutter.udacity.com';

  Future<double> getConversion(
      String category, String amount, String from, String to) async {
    final uri = Uri.https(
        url, '$category/convert', {'amount': amount, 'from': from, 'to': to});
    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null || jsonResponse['conversion'] == null) {
      return null;
    } else if (jsonResponse['status'] == 'error') {
      print(jsonResponse['message']);
      return null;
    }
    return jsonResponse['conversion'].toDouble();
  }

  Future<List> getUnits(String category) async {
    final uri = Uri.https(url, '$category');
    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null || jsonResponse['units'] == null) {
      return null;
    }
    return jsonResponse['units'];
  }

  Future _getJson(Uri uri) async {
    assert(uri != null);
    try {
      final httpRequest = await httpClient.getUrl(uri);
      final httpResponse = await httpRequest.close();

      if (httpResponse.statusCode != HttpStatus.ok) {
        return null;
      }

      final responseBody = await httpResponse.transform(utf8.decoder).join();
      return json.decode(responseBody);
    } on Exception catch (e) {
      print('$e');
      return null;
    }
  }
}
