import ballerina/io;
import ballerinax/openai.text;
import ballerinax/openai.audio;

configurable string openAIKey = ?;

const string AUDIOFILEPATH = "./audo_clips/german_hello.mp3";
const string AUDIOFILE = "german_hello.mp3";
const string TRANSLATINGLANGUAGE = "French";

public function main() returns error? {
    // Creates a request to translate the audio file to text (English)
    audio:CreateTranslationRequest translationsReq = {
        file: {fileContent: check io:fileReadBytes(AUDIOFILEPATH), fileName: AUDIOFILE},
        model: "whisper-1"
    };

    // Translates the audio file to text (English)
    audio:Client openAIAudio = check new ({auth: {token: openAIKey}});
    audio:CreateTranscriptionResponse transcriptionRes = check openAIAudio->/audio/translations.post(translationsReq);
    io:println("Audio text in English: ", transcriptionRes.text);

    // Creates a request to translate the text from English to other language
    string prmt = string `Translate the following text from English to ${TRANSLATINGLANGUAGE} : ${transcriptionRes.text}`;
    text:CreateCompletionRequest completionReq = {
        model: "text-davinci-003",
        prompt: prmt,
        temperature: 0.7,
        max_tokens: 256,
        top_p: 1,
        frequency_penalty: 0,
        presence_penalty: 0
    };

    // Translates the text from English to other language
    text:Client openAIText = check new ({auth: {token: openAIKey}});
    text:CreateCompletionResponse completionRes = check openAIText->/completions.post(completionReq);
    string translatedText = check completionRes.choices[0].text.ensureType();
    io:println("Translated text: ", translatedText);
}
