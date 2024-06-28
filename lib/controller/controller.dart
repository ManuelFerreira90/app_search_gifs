import 'package:app_gifs/model/get_key.dart';
import 'package:http/http.dart' as http;

class Controller {

  static Future<http.Response> getGifsApi({ required int offset}) async{
    String apiKey = GetKey.apiKey;
    final url = Uri.parse('https://api.giphy.com/v1/gifs/trending?api_key=$apiKey&limit=20&offset=$offset&rating=g&bundle=messaging_non_clips');

    final response = await http.get(url);

    return response;
  }

  static Future<http.Response> getSearchGifApi({ required String search, required int offset}) async {
    String apiKey = GetKey.apiKey;
    final url = Uri.parse('https://api.giphy.com/v1/gifs/search?api_key=$apiKey&q=$search&limit=20&offset=$offset&rating=g&lang=en&bundle=messaging_non_clips');
  
    final response = await http.get(url);

    return response;
  }
}