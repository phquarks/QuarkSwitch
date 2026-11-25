namespace QuarkSwitch.Windows;

internal readonly record struct WordSnapshot(string Word, string Delimiter, DateTime Time, nint Window);
internal readonly record struct Correction(string Original, string Replacement, string Delimiter, DateTime Time, nint Window);

internal sealed class AutoSwitchEngine
{
    private readonly AppSettings _settings;
    private readonly LayoutConverter _converter = new();
    private readonly LanguageDetector _detector;
    private static readonly HashSet<string> Protected = new(StringComparer.OrdinalIgnoreCase)
    { "npm", "npx", "sudo", "git", "github", "localhost", "swift", "swiftui", "chatgpt", "openai", "codex", "windows", "json", "http", "https", "api", "ssh", "docker", "python", "java", "node", "sql" };
    private static readonly HashSet<string> ExcludedProcesses = new(StringComparer.OrdinalIgnoreCase)
    { "cmd", "powershell", "pwsh", "WindowsTerminal", "wt" };

    public WordSnapshot? LastWord { get; set; }
    public Correction? LastCorrection { get; private set; }
    public event Action<string>? StatusChanged;

    public AutoSwitchEngine(AppSettings settings)
    {
        _settings = settings;
        _detector = new LanguageDetector(_converter);
    }

    public bool ProcessBoundary(WordSnapshot snapshot)
    {
        LastWord = snapshot;
        if (!_settings.AutoSwitch || _settings.Paused || !ShouldAnalyze(snapshot.Word)) return false;
        var result = _detector.Evaluate(snapshot.Word);
        var threshold = 1.6 + _settings.Sensitivity / 100.0 * 2.8;
        if (result is null || result.Value.Improvement < threshold) return false;
        Replace(snapshot, result.Value.Converted, true, result.Value.Direction, false);
        return true;
    }

    public void ConvertLastWord()
    {
        if (LastWord is not { } snapshot || DateTime.UtcNow - snapshot.Time > TimeSpan.FromSeconds(12))
        { StatusChanged?.Invoke("No recent word to convert"); return; }
        var converted = _converter.ConvertAutomatically(snapshot.Word);
        if (converted is null) return;
        Replace(snapshot, converted.Value.Text, false, converted.Value.Direction, true);
    }

    public void ConvertSelection()
    {
        IDataObject? previous = null;
        try { previous = Clipboard.GetDataObject(); } catch { }
        NativeMethods.SendShortcut(0x43);
        Thread.Sleep(120);
        string selected;
        try { selected = Clipboard.ContainsText() ? Clipboard.GetText() : string.Empty; }
        catch { selected = string.Empty; }
        var converted = _converter.ConvertAutomatically(selected);
        if (converted is null || string.IsNullOrWhiteSpace(selected)) { StatusChanged?.Invoke("Select text to convert"); return; }
        Clipboard.SetText(converted.Value.Text);
        NativeMethods.SendShortcut(0x56);
        Thread.Sleep(80);
        try { if (previous is not null) Clipboard.SetDataObject(previous); } catch { }
        SwitchLayout(converted.Value.Direction);
        StatusChanged?.Invoke("Selection converted");
    }

    public bool TryUndo()
    {
        if (LastCorrection is not { } correction || DateTime.UtcNow - correction.Time > TimeSpan.FromSeconds(8) || NativeMethods.GetForegroundWindow() != correction.Window) return false;
        NativeMethods.SendBackspaces(correction.Replacement.Length + correction.Delimiter.Length);
        NativeMethods.SendUnicode(correction.Original + correction.Delimiter);
        LastCorrection = null;
        _settings.Exceptions.Add(correction.Original.ToLowerInvariant());
        _settings.Save();
        StatusChanged?.Invoke("Correction undone and learned");
        return true;
    }

    private bool ShouldAnalyze(string word)
    {
        if (word.Length is < 3 or > 32 || Protected.Contains(word) || _settings.Exceptions.Contains(word.ToLowerInvariant())) return false;
        if (ExcludedProcesses.Contains(NativeMethods.ForegroundProcessName()) || NativeMethods.IsPasswordField()) return false;
        if (word.Any(char.IsDigit) || word.IndexOfAny("@/:\\=+_#&?".ToCharArray()) >= 0) return false;
        return word.Any(char.IsLetter);
    }

    private void Replace(WordSnapshot snapshot, string converted, bool automatic, ConversionDirection direction, bool delimiterAlreadyTyped)
    {
        if (NativeMethods.GetForegroundWindow() != snapshot.Window) return;
        NativeMethods.SendBackspaces(snapshot.Word.Length + (delimiterAlreadyTyped ? snapshot.Delimiter.Length : 0));
        NativeMethods.SendUnicode(converted + snapshot.Delimiter);
        SwitchLayout(direction);
        LastCorrection = automatic ? new Correction(snapshot.Word, converted, snapshot.Delimiter, DateTime.UtcNow, snapshot.Window) : null;
        StatusChanged?.Invoke(automatic ? $"{snapshot.Word} → {converted}" : "Last word converted");
    }

    private static void SwitchLayout(ConversionDirection direction)
    {
        var id = direction == ConversionDirection.EnglishToRussian ? "00000419" : "00000409";
        var layout = NativeMethods.LoadKeyboardLayout(id, 1);
        NativeMethods.PostMessage(NativeMethods.GetForegroundWindow(), NativeMethods.WmInputLangChangeRequest, nint.Zero, layout);
    }
}
