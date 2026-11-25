using System.Diagnostics;

namespace QuarkSwitch.Windows;

internal sealed class AboutForm : Form
{
    public AboutForm()
    {
        Text = "About QuarkSwitch";
        Icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath);
        StartPosition = FormStartPosition.CenterScreen;
        FormBorderStyle = FormBorderStyle.FixedDialog;
        MaximizeBox = false;
        MinimizeBox = false;
        ClientSize = new Size(540, 430);
        BackColor = Color.FromArgb(20, 20, 25);
        ForeColor = Color.White;
        Font = new Font("Segoe UI", 10);

        var logo = new PictureBox { Image = Icon?.ToBitmap(), SizeMode = PictureBoxSizeMode.Zoom, Location = new Point(42, 44), Size = new Size(150, 150) };
        var name = new Label { Text = "QuarkSwitch", Font = new Font("Segoe UI Semibold", 27), AutoSize = true, Location = new Point(220, 66) };
        var tagline = new Label { Text = "Keep your typing\nin the right language.", Font = new Font("Segoe UI Semibold", 14), ForeColor = Color.FromArgb(180, 180, 190), AutoSize = true, Location = new Point(224, 119) };
        var developer = new Label { Text = "Developer      Quarks\nRequires         Windows 10 or later", ForeColor = Color.FromArgb(210, 210, 218), AutoSize = true, Location = new Point(44, 238) };
        var website = new Button { Text = "Visit Developer Website     quarks.kz  ↗", FlatStyle = FlatStyle.Flat, ForeColor = Color.FromArgb(220, 210, 242), BackColor = Color.FromArgb(48, 43, 58), Location = new Point(44, 300), Size = new Size(450, 58) };
        website.FlatAppearance.BorderColor = Color.FromArgb(112, 91, 143);
        website.Click += (_, _) => Process.Start(new ProcessStartInfo("https://quarks.kz") { UseShellExecute = true });
        var copyright = new Label { Text = "Copyright © Quarks.", ForeColor = Color.FromArgb(160, 160, 170), AutoSize = true, Location = new Point(44, 388) };
        Controls.AddRange([logo, name, tagline, developer, website, copyright]);
    }
}
