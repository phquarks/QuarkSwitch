using System.Runtime.InteropServices;
using System.Text;

namespace QuarkSwitch.Windows;

internal sealed class KeyboardHook : IDisposable
{
    private readonly AutoSwitchEngine _engine;
    private readonly NativeMethods.HookProc _callback;
    private readonly StringBuilder _word = new();
    private nint _hook;

    public KeyboardHook(AutoSwitchEngine engine)
    {
        _engine = engine;
        _callback = HookCallback;
        _hook = NativeMethods.SetWindowsHookEx(NativeMethods.WhKeyboardLl, _callback, nint.Zero, 0);
        if (_hook == nint.Zero) throw new InvalidOperationException("Unable to install the keyboard hook.");
    }

    private nint HookCallback(int code, nint wParam, nint lParam)
    {
        if (code < 0 || (wParam != NativeMethods.WmKeyDown && wParam != NativeMethods.WmSysKeyDown)) return NativeMethods.CallNextHookEx(_hook, code, wParam, lParam);
        var data = Marshal.PtrToStructure<NativeMethods.KbdLlHookStruct>(lParam);
        if ((data.Flags & NativeMethods.LlkhfInjected) != 0) return NativeMethods.CallNextHookEx(_hook, code, wParam, lParam);
        var control = (NativeMethods.GetKeyState(0x11) & 0x8000) != 0;
        if (control && data.VkCode == 0x5A && _engine.TryUndo()) return 1;
        if (control || (NativeMethods.GetKeyState(0x12) & 0x8000) != 0) return NativeMethods.CallNextHookEx(_hook, code, wParam, lParam);

        if (data.VkCode == 0x08)
        {
            if (_word.Length > 0) _word.Length--;
        }
        else if (data.VkCode is 0x20 or 0x0D or 0x09)
        {
            if (_word.Length > 0)
            {
                var delimiter = data.VkCode == 0x20 ? " " : data.VkCode == 0x09 ? "\t" : "\r";
                var snapshot = new WordSnapshot(_word.ToString(), delimiter, DateTime.UtcNow, NativeMethods.GetForegroundWindow());
                _word.Clear();
                if (_engine.ProcessBoundary(snapshot)) return 1;
            }
        }
        else if (data.VkCode is 0x1B or 0x25 or 0x26 or 0x27 or 0x28 or 0x2E)
        {
            _word.Clear();
        }
        else
        {
            var character = Translate(data.VkCode, data.ScanCode);
            if (character != '\0' && (char.IsLetter(character) || "`[]{};:'\",.<>/\\-’".Contains(character))) _word.Append(character);
            else if (character != '\0') _word.Clear();
        }
        return NativeMethods.CallNextHookEx(_hook, code, wParam, lParam);
    }

    private static char Translate(uint vk, uint scan)
    {
        var state = new byte[256];
        NativeMethods.GetKeyboardState(state);
        var foreground = NativeMethods.GetForegroundWindow();
        var thread = NativeMethods.GetWindowThreadProcessId(foreground, out _);
        var buffer = new StringBuilder(8);
        return NativeMethods.ToUnicodeEx(vk, scan, state, buffer, buffer.Capacity, 0, NativeMethods.GetKeyboardLayout(thread)) > 0 ? buffer[0] : '\0';
    }

    public void Dispose()
    {
        if (_hook != nint.Zero) NativeMethods.UnhookWindowsHookEx(_hook);
        _hook = nint.Zero;
    }
}
