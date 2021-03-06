import 'package:fukiya/fukiya.dart';
import 'fukiya_get_tests.dart';
import 'fukiya_delete_tests.dart';
import 'fukiya_post_tests.dart';
import 'fukiya_put_tests.dart';
import 'dart:io';
import 'dart:async';

void main() {
  Fukiya app = new Fukiya();
  app..get('/', getHandler)
     ..put('/', putHandler)
     ..delete('/', deleteHandler)
     ..delete('/testing', (FukiyaContext context) {
       context.send("DELETE OK - testing");
     })
     ..post('/', postHandler)
     ..get('/testing', (FukiyaContext context) {
       context.send("GET OK - testing");
     })
     ..get('/jsontest', getJsonHandler)
     ..get('/:userid', getDynamicHandler)
     ..get('/:module/:controller/:action', (FukiyaContext context) {
       context.send("Test");
     })
     ..put('/:userid', putDynamicHandler)
     ..delete('/:userid', deleteDynamicHandler)
     ..post('/:userid', postDynamicHandler)
     ..post('/postData', postFileDataHandler)
     ..get('/error', getHandlerErrorThrow)
     ..staticFiles('./test/static')
     ..addMimeType('ogg', 'video/ogg')
     ..addMimeTypes({'opus': 'audio/opus', 'mkv': 'video/x-matroska'})
     ..use(new FukiyaFormParser())
     ..use(new FukiyaJsonParser())
     ..listen('127.0.0.1', 3333);

  FukiyaGetTests.runTests().then((bool status) => status);
  FukiyaPostTests.runTests().then((bool status) => status);
  FukiyaPutTests.runTests().then((bool status) => status);
  FukiyaDeleteTests.runTests().then((bool status) => app.stop());

}

void getHandler(FukiyaContext context) {
  context.send("GET OK");
  throw new Exception("This is a successful test exception catch for GET /");
}

void getHandlerErrorThrow(FukiyaContext context) {
  throw new Exception("Actual failure and returns 500");
}

void getJsonHandler(FukiyaContext context) {
  Map<String, dynamic> map = {};
  map['test'] = 'Yulian';
  map['lastTest'] = { "test": "Yulian", "lastTest": "Kuncheff" };
  context.jsonResponse(map);
}

void putHandler(FukiyaContext context) {
  context.send("PUT OK ${context.parsedBody['username']} - ${context.parsedBody['password']}");
}

void deleteHandler(FukiyaContext context) {
  context.send("DELETE OK");
}

void postHandler(FukiyaContext context) {
  context.send("POST OK ${context.parsedBody['username']} - ${context.parsedBody['password']}");
}

void getDynamicHandler(FukiyaContext context) {
  context.send("Dynamic GET OK ${context.params['userid']}");
}

void putDynamicHandler(FukiyaContext context) {
  context.send("Dynamic PUT OK ${context.params['userid']} - ${context.parsedBody['username']}");
}

void deleteDynamicHandler(FukiyaContext context) {
  context.send("Dynamic DELETE OK ${context.params['userid']}");
}

void postDynamicHandler(FukiyaContext context) {
  context.send("Dynamic POST OK ${context.params['userid']} - ${context.parsedBody['username']}");
}

void postFileDataHandler(FukiyaContext context) {
  List<int> fileData = context.parsedBody['file']['data'];
  String filename = context.parsedBody['file']['filename'];

  File file = new File("./test/r-${filename}");
  file.writeAsBytesSync(fileData);
  context.send("Form File Upload POST OK");
}
