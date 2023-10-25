import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:zen/openai_service.dart';
import 'package:zen/pallete.dart';
import 'package:zen/feature_box.dart';
import 'package:zen/Message.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;
  TextEditingController textEditingController = TextEditingController();
  List<Message> messages = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }


  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async{
    await flutterTts.speak(content);
  }
  Future<void> sendMessage() async {
    final speech = await openAIService.isArtPromptAPI(lastWords);
    if (speech.contains('https')) {
      messages.add(Message(content: lastWords, isUserMessage: true));
      generatedImageUrl = speech;
      generatedContent = null;
      setState(() {});
    } else {
      setState(() {
        messages.add(Message(content: lastWords, isUserMessage: true));
        messages.add(Message(content: speech, isUserMessage: false));
      });
      await systemSpeak(speech);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZenChat'),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // virtual assistant image
            Stack(
              children: [

                Center(
                child: Container(
                  height: 120,
                  width: 120,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: Pallete.assistantCircleColor,
                    shape: BoxShape.circle,
                  ),
                ),
                ),
                Container(
                  height: 123,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image:DecorationImage(image: AssetImage('assets/images/virtualAssistant.png'))
                  ),
                ),
              ],
            ),
            // chat bubble
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: messages.length,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                itemBuilder: (BuildContext context, int index) {
                  final message = messages[index];
                  final isUserMessage = message.isUserMessage;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Pallete.greyColor,
                      border: Border.all(
                        color: Pallete.borderColor,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: isUserMessage ? Radius.circular(20) : Radius.zero,
                        topRight: isUserMessage ? Radius.zero : Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        fontFamily: 'Cera Pro',
                        color: Pallete.mainFontColor,
                        fontSize: 18,
                      ),
                    ),
                  );
                },
              ),
            ),
             if (generatedImageUrl !=null) Padding(
               padding: const EdgeInsets.all(10.0),
               child: ClipRRect(borderRadius: BorderRadius.circular(20),
                   child: Image.network(generatedImageUrl!)),
             ),
             Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
               child: Container(
               padding: EdgeInsets.all(10),
                 alignment: Alignment.centerLeft,
               margin: const EdgeInsets.only(
                 top: 10,
                 left: 22,

               ),
                 child: const Text(
                'I am your virtual companion, feel free to use me as you please!',
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
            ),
               ),
             ),
            // features list
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: const Column(
                children:  [
                  FeatureBox(
                    color: Pallete.firstSuggestionBoxColor,
                    headerText: 'Virtual Companion',
                    descriptionText:
                    'Experience Intelligence chat',
                  ),
                  FeatureBox(
                    color: Pallete.secondSuggestionBoxColor,
                    headerText: 'Image generation',
                    descriptionText:'Unleash Your Creativity',
                  ),
                  FeatureBox(
                    color: Pallete.thirdSuggestionBoxColor,
                    headerText: 'Voice Input and Output',
                    descriptionText:'Multiverse of both worlds using your voice',
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.all(6.0),
                      color: Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: textEditingController,
                              decoration: InputDecoration(
                                hintText: 'Type your message...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                              ),
                              onChanged: (value) {
                                lastWords = value;
                              },
                            ),
                          ),
                          SizedBox(width: 3.0),
                          TextButton(
                            onPressed: () async {
                              await sendMessage();
                              textEditingController.clear();

                            },
                            child: const Icon(Icons.send),
                          ),
                          SizedBox(
                            width: 50.0,
                            child: FloatingActionButton(
                                    onPressed: () async {
                                      if (await speechToText.hasPermission && speechToText.isNotListening) {
                                      await startListening();
                                        } else if (speechToText.isListening) {
                                      final speech = await openAIService.isArtPromptAPI(lastWords);
                                      if (speech.contains('https')) {
                                        messages.add(Message(content: lastWords, isUserMessage: true));
                                      generatedImageUrl = speech;
                                      generatedContent = null;
                                      setState(() {});
                                      } else {
                                      generatedImageUrl = null;
                                      generatedContent = speech;
                                      setState(() {
                                        messages.add(Message(content: lastWords, isUserMessage: true));
                                        messages.add(Message(content: speech, isUserMessage: false));
                                      });
                                      await systemSpeak(speech);
                                      }
                                      await stopListening();
                                      } else {
                                      initSpeechToText();
                                      }
                                      },
                                      child: const Icon(Icons.mic),
                                      ),
                                      ),
                     ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

        ),
      ),

    );
  }
}
