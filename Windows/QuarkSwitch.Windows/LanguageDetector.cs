namespace QuarkSwitch.Windows;

internal readonly record struct DetectionResult(string Converted, ConversionDirection Direction, double Improvement);

internal sealed class LanguageDetector
{
    private readonly LayoutConverter _converter;
    private static readonly HashSet<string> EnglishWords = new(StringComparer.OrdinalIgnoreCase)
    {
        "about", "after", "again", "all", "also", "and", "another", "are", "because", "been", "before", "between", "but", "can", "come", "could", "day", "did", "do", "does", "done", "down", "each", "even", "every", "first", "for", "from", "get", "give", "good", "great", "had", "has", "have", "hello", "help", "here", "home", "how", "into", "just", "know", "last", "like", "look", "make", "many", "may", "more", "most", "much", "need", "new", "next", "not", "now", "one", "only", "other", "our", "out", "please", "right", "same", "see", "should", "some", "still", "take", "than", "thank", "that", "the", "their", "them", "then", "there", "these", "they", "thing", "think", "this", "time", "today", "two", "use", "very", "want", "was", "way", "we", "well", "were", "what", "when", "where", "which", "who", "will", "with", "work", "world", "would", "write", "yes", "you", "your"
    };
    private static readonly HashSet<string> RussianWords = new(StringComparer.OrdinalIgnoreCase)
    {
        "без", "больше", "будет", "бы", "был", "была", "были", "быть", "вам", "вас", "ваш", "вот", "все", "всего", "вы", "где", "да", "давай", "даже", "два", "для", "день", "до", "его", "если", "есть", "еще", "же", "здесь", "или", "как", "когда", "который", "кто", "ли", "мне", "может", "можно", "мой", "мы", "на", "надо", "наш", "не", "нет", "но", "новый", "ну", "он", "она", "они", "оно", "от", "очень", "первый", "по", "под", "пока", "после", "почему", "привет", "при", "про", "просто", "работа", "раз", "сейчас", "спасибо", "так", "также", "там", "тебя", "теперь", "то", "тогда", "только", "тут", "ты", "уже", "хорошо", "хочу", "чем", "что", "чтобы", "это", "этот", "я"
    };
    private static readonly string[] EnglishPairs = ["th", "he", "in", "er", "an", "re", "on", "at", "en", "nd", "ti", "es", "or", "te", "of", "ed", "is", "it", "al", "ar", "st", "to", "nt", "ng", "se", "ha", "as", "ou", "io", "le", "ve", "co", "me", "de", "hi", "ri", "ro", "ic", "ne", "ea"];
    private static readonly string[] RussianPairs = ["ст", "но", "то", "на", "ен", "ов", "ни", "ра", "во", "ко", "ро", "по", "ос", "го", "ал", "ли", "ер", "от", "пр", "та", "ет", "ло", "ре", "ол", "ка", "ит", "ор", "те", "ть", "де", "ла", "не", "ри", "ва", "об", "че", "ск", "ак", "ил", "тр"];

    public LanguageDetector(LayoutConverter converter) => _converter = converter;

    public DetectionResult? Evaluate(string original)
    {
        var candidate = _converter.ConvertAutomatically(original);
        if (candidate is null) return null;
        var sourceIsEnglish = candidate.Value.Direction == ConversionDirection.EnglishToRussian;
        var originalScore = Score(original, sourceIsEnglish);
        var convertedScore = Score(candidate.Value.Text, !sourceIsEnglish);
        return new DetectionResult(candidate.Value.Text, candidate.Value.Direction, convertedScore - originalScore);
    }

    private static double Score(string word, bool english)
    {
        var normalized = word.ToLowerInvariant();
        var dictionary = english ? EnglishWords : RussianWords;
        var pairs = english ? EnglishPairs : RussianPairs;
        var score = dictionary.Contains(normalized) ? 8.0 : 0.0;
        if (normalized.Length > 1)
        {
            var matches = Enumerable.Range(0, normalized.Length - 1).Count(i => pairs.Contains(normalized.Substring(i, 2)));
            score += (double)matches / (normalized.Length - 1) * 4.0;
        }
        var vowels = english ? "aeiouy" : "аеёиоуыэюя";
        if (!normalized.Any(vowels.Contains)) score -= 2.0;
        var unlikely = english ? new[] { "ghb", "hbd", "bdt", "dtn", "jjj", "qq", "zx" } : new[] { "ъъ", "ыы", "ьь", "щщ", "дщ", "жэ" };
        if (unlikely.Any(normalized.Contains)) score -= 3.0;
        return score;
    }
}
