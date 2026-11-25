namespace QuarkSwitch.Windows;

internal sealed class SettingsForm : Form
{
    private readonly AppSettings _settings;
    private readonly Action _saved;

    public SettingsForm(AppSettings settings, Action saved)
    {
        _settings = settings;
        _saved = saved;
        Text = "QuarkSwitch Settings";
        Icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath);
        StartPosition = FormStartPosition.CenterScreen;
        ClientSize = new Size(560, 410);
        MinimumSize = new Size(520, 390);
        Font = new Font("Segoe UI", 10);
        BackColor = Color.FromArgb(246, 246, 248);

        var heading = new Label { Text = "QuarkSwitch", Font = new Font("Segoe UI Semibold", 22), AutoSize = true, Location = new Point(28, 25) };
        var subtitle = new Label { Text = "Keep your typing in the right language.", ForeColor = Color.DimGray, AutoSize = true, Location = new Point(31, 68) };
        var auto = new CheckBox { Text = "Automatically correct the last word", Checked = settings.AutoSwitch, AutoSize = true, Location = new Point(32, 118) };
        var startup = new CheckBox { Text = "Start QuarkSwitch with Windows", Checked = settings.StartWithWindows, AutoSize = true, Location = new Point(32, 155) };
        var sensitivityLabel = new Label { Text = "Correction sensitivity", AutoSize = true, Location = new Point(32, 205) };
        var sensitivity = new TrackBar { Minimum = 0, Maximum = 100, TickFrequency = 10, Value = Math.Clamp(settings.Sensitivity, 0, 100), Location = new Point(28, 232), Width = 490 };
        var low = new Label { Text = "More corrections", ForeColor = Color.DimGray, AutoSize = true, Location = new Point(32, 278) };
        var high = new Label { Text = "Fewer false positives", ForeColor = Color.DimGray, AutoSize = true, Location = new Point(395, 278) };
        var shortcuts = new Label { Text = "Ctrl+Alt+Space  Convert selection\nCtrl+Alt+Shift+Space  Convert last word\nCtrl+Z  Undo a recent automatic correction", ForeColor = Color.FromArgb(60, 60, 68), AutoSize = true, Location = new Point(32, 315) };
        var save = new Button { Text = "Save", AutoSize = true, Location = new Point(458, 354), Padding = new Padding(10, 3, 10, 3) };
        save.Click += (_, _) =>
        {
            settings.AutoSwitch = auto.Checked;
            settings.StartWithWindows = startup.Checked;
            settings.Sensitivity = sensitivity.Value;
            settings.Save();
            _saved();
            Close();
        };
        Controls.AddRange([heading, subtitle, auto, startup, sensitivityLabel, sensitivity, low, high, shortcuts, save]);
    }
}
