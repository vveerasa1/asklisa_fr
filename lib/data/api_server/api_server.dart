import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../../utils/log.dart';
import '../prefs/current_user.dart';
import 'release_config.dart';


class AuthClient extends http.BaseClient {
  final String baseUrl = ReleaseConfig.baseUrl;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers.addAll(await _getHeaders());
    return request.send();
  }

  static Future<Map<String, String>> _getHeaders() async {
    String? token =  CurrentUser().getToken;

    if (token.isNotEmpty) {
      return {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      };
    } else {
      return {
        'Content-Type': 'application/json; charset=UTF-8',
      };
    }
  }

  Future<Map<String, String>> addHeaders(
      Map<String, String>? headers, Uri url) async {
    Map<String, String> mergedHeaders = await _getHeaders();
    if (headers != null) {
      mergedHeaders.addAll(headers);
    }
    Log.d(mergedHeaders);
    return mergedHeaders;
  }


  @override
  Future<Response> post(url,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) async {
    Map<String, String> mergedHeaders = await addHeaders(headers, url);
    return http.post(Uri.parse("$baseUrl$url"),
        headers: mergedHeaders, body: body, encoding: encoding);
  }

  @override
  Future<Response> get(url,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) async {
    Map<String, String> mergedHeaders = await addHeaders(headers, url);
    return http.get(Uri.parse("$baseUrl$url"), headers: mergedHeaders);
  }

  @override
  Future<Response> put(url,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) async {
    Map<String, String> mergedHeaders = await addHeaders(headers, url);
    return http.put(Uri.parse("$baseUrl$url"),
        headers: mergedHeaders, body: body, encoding: encoding);
  }

  @override
  Future<Response> patch(url,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) async {
    Map<String, String> mergedHeaders = await addHeaders(headers, url);
    return http.patch(Uri.parse("$baseUrl$url"),
        headers: mergedHeaders, body: body, encoding: encoding);
  }

  @override
  Future<Response> delete(url,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) async {
    Map<String, String> mergedHeaders = await addHeaders(headers, url);
    return http.delete(Uri.parse("$baseUrl$url"),
        headers: mergedHeaders, body: body, encoding: encoding);
  }

  Future<Response> multipartRequest(String url, String method,
      Map<String, dynamic> fields, List<Map<String, Object>> files,
      {Map<String, String>? headers}) async {
    Map<String, String> stringFields = {};

    fields.forEach((key, value) {
      // If value is a complex object, convert it to a JSON string
      if (value is Map || value is List) {
        stringFields[key] = jsonEncode(value); // Serialize complex objects
      } else {
        stringFields[key] = value.toString(); // Ensure all values are strings
      }
    });

    Map<String, String> mergedHeaders =
    await addHeaders(headers, Uri.parse(url));
    var request = http.MultipartRequest(method, Uri.parse("$baseUrl$url"));
    if (fields != {}) {
      request.fields.addAll(stringFields);
    }
    request.headers.addAll(mergedHeaders);

    for (Map<String, Object> data in files) {
      File file = data['file'] as File;
      request.files.add(http.MultipartFile(
        data['fileName'] as String,
        http.ByteStream(file.openRead()),
        await file.length(),
        filename: file.path.split('/').last,
      ));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    return response;
  }

  Future<Response> multipleMultipartRequest(String url, String method,
      Map<String, String> fields, List<Map<String, MultipartFile>> files,
      {Map<String, String>? headers}) async {
    Map<String, String> mergedHeaders =
    await addHeaders(headers, Uri.parse(url));
    var request = http.MultipartRequest(method, Uri.parse("$baseUrl$url"));
    if (fields.isNotEmpty) {
      request.fields.addAll(fields);
    }
    request.headers.addAll(mergedHeaders);

    for (Map<String, MultipartFile> data in files) {
      MultipartFile file = data['file']!;
      request.files.add(http.MultipartFile(
        'file',
        file.finalize(),
        file.length,
        filename: file.filename,
      ));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    return response;
  }
}
