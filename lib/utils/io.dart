import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:optiread/locale/tr_TR.dart';
import 'dart:convert';

import '../models/sheet.dart';
import 'constants.dart';


Future<XFile> pickCameraImage() async {
  final imagesPath = await CunningDocumentScanner.getPictures(
    noOfPages: 1,
    isGalleryImportAllowed: true,
  );
  if (imagesPath == null) {
    throw Exception('No image selected');
  }
  return XFile(imagesPath[0]);
}



Future<XFile> pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  if (image == null) {
    throw Exception('No image selected');
  }
  return image;
}

Future<List<String>> uploadImage(XFile image) async {

  var request = http.MultipartRequest(
    'POST',
    Uri.parse(serverUrl),
  );
  request.files.add(await http.MultipartFile.fromPath('image', image.path));
  var response = await request.send();

  if (response.statusCode == 200) {
    final Map parsed = json.decode(await response.stream.bytesToString());
    final Sheet sheet = Sheet.fromJson(parsed);
    return sheet.answers;
  }
  throw Exception('$stringExamEditorUploadError${response.statusCode}');
}

