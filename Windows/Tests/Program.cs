using QuarkSwitch.Windows;

var converter = new LayoutConverter();
var detector = new LanguageDetector(converter);

Expect(converter.Convert("ghbdtn", ConversionDirection.EnglishToRussian), "привет");
Expect(converter.Convert("руддщ", ConversionDirection.RussianToEnglish), "hello");
Expect(converter.Convert("[jhjij", ConversionDirection.EnglishToRussian), "хорошо");

var wrongRussian = detector.Evaluate("ghbdtn");
if (wrongRussian is null || wrongRussian.Value.Converted != "привет" || wrongRussian.Value.Improvement <= 1.6)
    throw new Exception("ghbdtn must be detected as привет");

var correctEnglish = detector.Evaluate("hello");
if (correctEnglish is not null && correctEnglish.Value.Improvement > 1.6)
    throw new Exception("hello must not be autocorrected");

Console.WriteLine("Windows layout regression checks passed.");

static void Expect(string actual, string expected)
{
    if (actual != expected) throw new Exception($"Expected {expected}, got {actual}");
}
