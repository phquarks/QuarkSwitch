namespace QuarkSwitch.Windows;

internal sealed class TrayApplicationContext : ApplicationContext
{
    private readonly AppSettings _settings = AppSettings.Load();
    private readonly AutoSwitchEngine _engine;
    private readonly KeyboardHook _hook;
    private readonly NotifyIcon _tray;
    private readonly HotKeyWindow _hotKeys;
    private readonly ToolStripMenuItem _autoItem;
    private readonly ToolStripMenuItem _pauseItem;
    private readonly SynchronizationContext _ui = SynchronizationContext.Current ?? new WindowsFormsSynchronizationContext();

    public TrayApplicationContext()
    {
        _engine = new AutoSwitchEngine(_settings);
        _engine.StatusChanged += status => _ui.Post(_ => ShowStatus(status), null);
        _hook = new KeyboardHook(_engine);
        _hotKeys = new HotKeyWindow(_engine);

        _autoItem = new ToolStripMenuItem("Auto Switch", null, (_, _) => ToggleAuto()) { Checked = _settings.AutoSwitch, CheckOnClick = false };
        _pauseItem = new ToolStripMenuItem(_settings.Paused ? "Resume" : "Pause", null, (_, _) => TogglePause());
        var menu = new ContextMenuStrip();
        menu.Items.AddRange([
            _autoItem,
            _pauseItem,
            new ToolStripSeparator(),
            new ToolStripMenuItem("Convert selected text    Ctrl+Alt+Space", null, (_, _) => _engine.ConvertSelection()),
            new ToolStripMenuItem("Convert last word    Ctrl+Alt+Shift+Space", null, (_, _) => _engine.ConvertLastWord()),
            new ToolStripSeparator(),
            new ToolStripMenuItem("Settings", null, (_, _) => new SettingsForm(_settings, RefreshMenu).Show()),
            new ToolStripMenuItem("About QuarkSwitch", null, (_, _) => new AboutForm().Show()),
            new ToolStripSeparator(),
            new ToolStripMenuItem("Exit", null, (_, _) => ExitThread())
        ]);

        _tray = new NotifyIcon
        {
            Icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath) ?? SystemIcons.Application,
            Text = "QuarkSwitch — keyboard layout correction",
            ContextMenuStrip = menu,
            Visible = true
        };
        _tray.DoubleClick += (_, _) => new SettingsForm(_settings, RefreshMenu).Show();
        ShowStatus("QuarkSwitch is running");
    }

    private void ToggleAuto() { _settings.AutoSwitch = !_settings.AutoSwitch; _settings.Save(); RefreshMenu(); }
    private void TogglePause() { _settings.Paused = !_settings.Paused; _settings.Save(); RefreshMenu(); }
    private void RefreshMenu()
    {
        _autoItem.Checked = _settings.AutoSwitch;
        _pauseItem.Text = _settings.Paused ? "Resume" : "Pause";
        _tray.Text = _settings.Paused ? "QuarkSwitch — paused" : _settings.AutoSwitch ? "QuarkSwitch — active" : "QuarkSwitch — off";
    }

    private void ShowStatus(string status)
    {
        _tray.BalloonTipTitle = "QuarkSwitch";
        _tray.BalloonTipText = status;
        if (status.Contains('→')) _tray.ShowBalloonTip(1200);
    }

    protected override void ExitThreadCore()
    {
        _tray.Visible = false;
        _tray.Dispose();
        _hotKeys.Dispose();
        _hook.Dispose();
        _settings.Save();
        base.ExitThreadCore();
    }

    private sealed class HotKeyWindow : NativeWindow, IDisposable
    {
        private const int WmHotKey = 0x0312;
        private readonly AutoSwitchEngine _engine;

        public HotKeyWindow(AutoSwitchEngine engine)
        {
            _engine = engine;
            CreateHandle(new CreateParams());
            NativeMethods.RegisterHotKey(Handle, 1, NativeMethods.ModControl | NativeMethods.ModAlt, 0x20);
            NativeMethods.RegisterHotKey(Handle, 2, NativeMethods.ModControl | NativeMethods.ModAlt | NativeMethods.ModShift, 0x20);
        }

        protected override void WndProc(ref Message message)
        {
            if (message.Msg == WmHotKey && message.WParam == 1) _engine.ConvertSelection();
            else if (message.Msg == WmHotKey && message.WParam == 2) _engine.ConvertLastWord();
            base.WndProc(ref message);
        }

        public void Dispose()
        {
            NativeMethods.UnregisterHotKey(Handle, 1);
            NativeMethods.UnregisterHotKey(Handle, 2);
            DestroyHandle();
        }
    }
}
