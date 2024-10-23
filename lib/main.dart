import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 애플리케이션의 루트 위젯입니다.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenAI 연동 계산기',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'OpenAI 연동 계산기'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 변수 선언
  final TextEditingController inputController = TextEditingController();
  List<String> resultList = [];
  String resultText = "";

  // OpenAI API 호출 함수
  Future<void> getOpenAIResponse(String input) async {
    const apiKey =
        'sk-proj-soEA';
    final url = 'https://api.openai.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'OpenAI-Organization': 'org-qGKqo4eFq3qP4FoVarwAEhdY',
        'OpenAI-Project': 'proj_rzRFceMjLlY7VWfYPTsNO6we',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are an assistant specialized in helping only with calculations.'
          },
          {'role': 'user', 'content': input}, // 사용자의 입력을 반영
        ],
        'max_tokens': 100,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        print(data);
        resultText = data['choices'][0]['message']['content'];
      });
    } else {
      // 에러 메시지를 상세히 표시
      setState(() {
        resultText =
            'Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI 빌드 메서드
    return Scaffold(
      appBar: AppBar(
        title: Text('OpenAI 연동 계산기'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // 컬럼 위젯을 사용하여 위젯들을 수직으로 배치
        child: Column(
          children: [
            // 텍스트 입력 필드
            TextField(controller: inputController),
            SizedBox(height: 20),
            // 계산하기 버튼
            ElevatedButton(
              onPressed: () {
                if (inputController.text.trim().isNotEmpty) {
                  getOpenAIResponse(inputController.text.trim());
                }
              },
              child: Text('계산하기'),
            ),
            SizedBox(height: 20),
            // 결과를 표시하는 텍스트
            Text(resultText),
            SizedBox(height: 20),
            // 리스트에 추가하는 버튼
            ElevatedButton(
              onPressed: () {
                // 입력된 텍스트가 비어있지 않을 때만 추가
                if (inputController.text.trim().isNotEmpty) {
                  setState(() {
                    resultList.add(inputController.text.trim());
                    inputController.clear(); // 입력 필드 초기화
                  });
                }
              },
              child: Text('Add to List'),
            ),
            SizedBox(height: 20),
            // 리스트뷰를 Expanded로 감싸서 남은 공간을 차지하도록 함
            Expanded(
              child: ListView.builder(
                itemCount: resultList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(resultList[index]),
                    // 아이템을 길게 누르면 삭제하는 기능 추가
                    onLongPress: () {
                      setState(() {
                        resultList.removeAt(index);
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
