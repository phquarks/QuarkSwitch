using System.Threading;

namespace QuarkSwitch.Windows;

internal static class Program
{
    [STAThread]
    private static void Main()
    {
        using var instance = new Mutex(true, "Quarks.QuarkSwitch.Windows", out var isFirst);
        if (!isFirst)
        {
            MessageBox.Show("QuarkSwitch is already running.", "QuarkSwitch", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        Application.SetHighDpiMode(HighDpiMode.PerMonitorV2);
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);
        Application.Run(new TrayApplicationContext());
    }
}
