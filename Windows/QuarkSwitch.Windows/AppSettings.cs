using System.Text.Json;
using Microsoft.Win32;

namespace QuarkSwitch.Windows;

internal sealed class AppSettings
{
    public bool AutoSwitch { get; set; } = true;
    public bool Paused { get; set; }
    public bool StartWithWindows { get; set; }
    public int Sensitivity { get; set; } = 55;
    public HashSet<string> Exceptions { get; set; } = new(StringComparer.OrdinalIgnoreCase);
    private static string Folder => Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Quarks", "QuarkSwitch");
    private static string FilePath => Path.Combine(Folder, "settings.json");

    public static AppSettings Load()
    {
        try { return JsonSerializer.Deserialize<AppSettings>(File.ReadAllText(FilePath)) ?? new(); }
        catch { return new(); }
    }

    public void Save()
    {
        Directory.CreateDirectory(Folder);
        File.WriteAllText(FilePath, JsonSerializer.Serialize(this, new JsonSerializerOptions { WriteIndented = true }));
        using var key = Registry.CurrentUser.OpenSubKey(@"Software\Microsoft\Windows\CurrentVersion\Run", true);
        if (StartWithWindows) key?.SetValue("QuarkSwitch", $"\"{Application.ExecutablePath}\"");
        else key?.DeleteValue("QuarkSwitch", false);
    }
}
