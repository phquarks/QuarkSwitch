using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;

namespace QuarkSwitch.Windows;

internal static class NativeMethods
{
    public const int WhKeyboardLl = 13, WmKeyDown = 0x0100, WmSysKeyDown = 0x0104;
    public const int WmInputLangChangeRequest = 0x0050, EmGetPasswordChar = 0x00D2;
    public const uint LlkhfInjected = 0x10, KeyeventfKeyup = 0x0002, KeyeventfUnicode = 0x0004;
    public const uint InputKeyboard = 1, ModAlt = 0x0001, ModControl = 0x0002, ModShift = 0x0004;

    public delegate nint HookProc(int code, nint wParam, nint lParam);

    [StructLayout(LayoutKind.Sequential)] public struct KbdLlHookStruct { public uint VkCode, ScanCode, Flags, Time; public nint ExtraInfo; }
    [StructLayout(LayoutKind.Sequential)] public struct KeyboardInput { public ushort Vk, Scan; public uint Flags, Time; public nint ExtraInfo; }
    [StructLayout(LayoutKind.Explicit)] public struct InputUnion { [FieldOffset(0)] public KeyboardInput Keyboard; }
    [StructLayout(LayoutKind.Sequential)] public struct Input { public uint Type; public InputUnion Union; }
    [StructLayout(LayoutKind.Sequential)] public struct GuiThreadInfo
    {
        public int Size; public uint Flags; public nint Active, Focus, Capture, MenuOwner, MoveSize, Caret;
        public Rect CaretRect;
    }
    [StructLayout(LayoutKind.Sequential)] public struct Rect { public int Left, Top, Right, Bottom; }

    [DllImport("user32.dll", SetLastError = true)] public static extern nint SetWindowsHookEx(int id, HookProc callback, nint module, uint threadId);
    [DllImport("user32.dll", SetLastError = true)] public static extern bool UnhookWindowsHookEx(nint hook);
    [DllImport("user32.dll")] public static extern nint CallNextHookEx(nint hook, int code, nint wParam, nint lParam);
    [DllImport("user32.dll")] public static extern short GetKeyState(int key);
    [DllImport("user32.dll")] public static extern bool GetKeyboardState(byte[] state);
    [DllImport("user32.dll")] public static extern int ToUnicodeEx(uint vk, uint scan, byte[] state, [Out] StringBuilder value, int length, uint flags, nint layout);
    [DllImport("user32.dll")] public static extern nint GetKeyboardLayout(uint threadId);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(nint window, out uint processId);
    [DllImport("user32.dll")] public static extern nint GetForegroundWindow();
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] public static extern nint LoadKeyboardLayout(string id, uint flags);
    [DllImport("user32.dll")] public static extern bool PostMessage(nint window, uint message, nint wParam, nint lParam);
    [DllImport("user32.dll")] public static extern uint SendInput(uint count, Input[] inputs, int size);
    [DllImport("user32.dll")] public static extern nint SendMessage(nint window, uint message, nint wParam, nint lParam);
    [DllImport("user32.dll")] public static extern bool GetGuiThreadInfo(uint threadId, ref GuiThreadInfo info);
    [DllImport("user32.dll")] public static extern bool RegisterHotKey(nint window, int id, uint modifiers, uint key);
    [DllImport("user32.dll")] public static extern bool UnregisterHotKey(nint window, int id);

    public static string ForegroundProcessName()
    {
        try
        {
            var window = GetForegroundWindow();
            GetWindowThreadProcessId(window, out var pid);
            return Process.GetProcessById((int)pid).ProcessName;
        }
        catch { return string.Empty; }
    }

    public static bool IsPasswordField()
    {
        var window = GetForegroundWindow();
        var thread = GetWindowThreadProcessId(window, out _);
        var info = new GuiThreadInfo { Size = Marshal.SizeOf<GuiThreadInfo>() };
        return GetGuiThreadInfo(thread, ref info) && info.Focus != nint.Zero && SendMessage(info.Focus, EmGetPasswordChar, nint.Zero, nint.Zero) != nint.Zero;
    }

    public static void SendBackspaces(int count)
    {
        var list = new List<Input>(count * 2);
        for (var i = 0; i < count; i++) { list.Add(Key(0x08)); list.Add(Key(0x08, KeyeventfKeyup)); }
        SendInput((uint)list.Count, list.ToArray(), Marshal.SizeOf<Input>());
    }

    public static void SendUnicode(string value)
    {
        var list = new List<Input>(value.Length * 2);
        foreach (var character in value)
        {
            list.Add(Key(0, KeyeventfUnicode, character));
            list.Add(Key(0, KeyeventfUnicode | KeyeventfKeyup, character));
        }
        SendInput((uint)list.Count, list.ToArray(), Marshal.SizeOf<Input>());
    }

    public static void SendShortcut(ushort key)
    {
        SendInput(4, [Key(0x11), Key(key), Key(key, KeyeventfKeyup), Key(0x11, KeyeventfKeyup)], Marshal.SizeOf<Input>());
    }

    private static Input Key(ushort vk, uint flags = 0, char unicode = '\0') => new()
    {
        Type = InputKeyboard,
        Union = new InputUnion { Keyboard = new KeyboardInput { Vk = vk, Scan = unicode, Flags = flags } }
    };
}
