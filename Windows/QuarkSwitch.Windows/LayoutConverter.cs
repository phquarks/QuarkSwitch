namespace QuarkSwitch.Windows;

internal enum ConversionDirection { EnglishToRussian, RussianToEnglish }

internal sealed class LayoutConverter
{
    private const string English = "`qwertyuiop[]\\asdfghjkl;'zxcvbnm,./~QWERTYUIOP{}|ASDFGHJKL:\"ZXCVBNM<>?";
    private const string Russian = "ёйцукенгшщзхъ\\фывапролджэячсмитьбю.ЁЙЦУКЕНГШЩЗХЪ/ФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,";
    private readonly Dictionary<char, char> _toRussian = new();
    private readonly Dictionary<char, char> _toEnglish = new();

    public LayoutConverter()
    {
        for (var i = 0; i < Math.Min(English.Length, Russian.Length); i++)
        {
            _toRussian[English[i]] = Russian[i];
            _toEnglish[Russian[i]] = English[i];
        }
        _toRussian['’'] = 'э';
    }

    public string Convert(string value, ConversionDirection direction)
    {
        var map = direction == ConversionDirection.EnglishToRussian ? _toRussian : _toEnglish;
        return string.Concat(value.Select(character => map.TryGetValue(character, out var result) ? result : character));
    }

    public (string Text, ConversionDirection Direction)? ConvertAutomatically(string value)
    {
        var latin = value.Count(c => c is >= 'A' and <= 'Z' or >= 'a' and <= 'z');
        var cyrillic = value.Count(c => c is >= '\u0400' and <= '\u04FF');
        if (latin > cyrillic) return (Convert(value, ConversionDirection.EnglishToRussian), ConversionDirection.EnglishToRussian);
        if (cyrillic > latin) return (Convert(value, ConversionDirection.RussianToEnglish), ConversionDirection.RussianToEnglish);
        return null;
    }
}
