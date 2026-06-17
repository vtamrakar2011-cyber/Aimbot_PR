# Aimbot Memory Scanner

A high-performance C# memory scanning tool for pattern detection and memory manipulation in external processes.

## Features

✅ **Ultra-fast AoB (Array of Bytes) Pattern Scanning**
- Parallel processing for maximum speed
- Wildcard support (`??` for unknown bytes)
- Configurable memory region filtering

✅ **Memory Manipulation**
- Read/Write integer, float, double, long, string values
- Hex pattern support
- Offset-based addressing

✅ **Windows Integration**
- Direct kernel32.dll P/Invoke calls
- VirtualQueryEx for memory enumeration
- ReadProcessMemory/WriteProcessMemory operations

## Requirements

- **Windows 7+**
- **.NET Framework 4.7.2+**
- **Administrator Privileges** (required for process access)
- **Visual Studio 2019+** (for development)

## Installation

### Clone the Repository
```bash
git clone https://github.com/vtamrakar2011-cyber/Aimbot_PR.git
cd Aimbot_PR
```

### Open in Visual Studio

1. Open `AimbotScanner.sln` in Visual Studio
2. Build the solution (Ctrl+Shift+B)
3. Run with Administrator privileges

### One-Click Build & Run

**Windows (PowerShell - Admin):**
```powershell
.\Build-and-Run.ps1
```

**Windows (Batch - Admin):**
```batch
Build-and-Run.bat
```

## Usage

### Basic Example

```csharp
INTERNAL scanner = new INTERNAL();

// Open process
Process proc = Process.GetProcessesByName("HD-Player").FirstOrDefault();
if (scanner.OpenProcess(proc.Id))
{
    // Define pattern (bytes + wildcards)
    string pattern = "FF FF FF FF 00 00 00 00 ?? ?? ?? ?? 00 00 00 00";
    
    // Scan for pattern
    var results = await scanner.AoBScan(pattern, writable: true);
    
    // Write to found addresses
    foreach (long addr in results)
    {
        scanner.WriteMemory(addr.ToString("X"), "int", "12345");
    }
}
```

### Aimbot Pattern Example

```csharp
// See Form1.cs for complete working example
string AimbotScan = "FF FF FF FF 00 00 00 00 ... ?? ?? ?? ?? ...";
var results = await AYUSH.AoBScan(AimbotScan, writable: true, executable: false);
```

## Project Structure

```
Aimbot_PR/
├── AimbotScanner.sln                 # Visual Studio Solution
├── WindowsFormsApp1/
│   ├── Form1.cs                      # Main UI Form
│   ├── Form1.Designer.cs             # Auto-generated form designer
│   ├── Program.cs                    # Entry point
│   └── WindowsFormsApp1.csproj       # Project file
├── CROXY.cs                          # Memory scanning engine
├── Build-and-Run.ps1                 # PowerShell build script
├── Build-and-Run.bat                 # Batch build script
└── README.md                         # This file
```

## API Reference

### INTERNAL Class

#### `OpenProcess(int pid) : bool`
Opens a process handle for memory operations.

```csharp
if (scanner.OpenProcess(1234))
{
    // Process opened successfully
}
```

#### `AoBScan(string pattern, bool writable, bool executable, string file) : Task<IEnumerable<long>>`
Scans process memory for a byte pattern.

```csharp
var addresses = await scanner.AoBScan(
    search: "FF FF ?? 00",
    writable: true,
    executable: false
);
```

#### `ReadInt(long address) : int`
Reads a 4-byte integer from memory.

```csharp
int value = scanner.ReadInt(0x140000000);
```

#### `WriteMemory(string address, string type, string value, string offset) : bool`
Writes data to memory.

```csharp
scanner.WriteMemory(
    address: "140000000",
    type: "int",
    value: "999"
);
```

## Performance

- **Parallel Scanning**: Uses all available CPU cores
- **Unsafe Pointers**: Direct memory access for speed
- **Smart Filtering**: Only scans relevant memory regions
- **Typical Scan Time**: 5-30 seconds for full process memory

## Security & Disclaimer

⚠️ **Warning**: This tool is for educational purposes only. Using it on online games or protected software may violate their Terms of Service and applicable laws.

**Only use on:**
- Personal single-player games
- Your own applications
- Educational/research projects

## Troubleshooting

### "Process not found"
- Ensure HD-Player (or target process) is running
- Check process name spelling

### "Access Denied"
- Run Visual Studio/application as Administrator
- Disable UAC or grant necessary permissions

### "Pattern not found"
- Pattern may be outdated (game updates change memory layout)
- Try scanning with fewer specific bytes initially
- Increase wildcard (`??`) usage

### "Scan takes too long"
- Reduce search scope using memory region filters
- Check if process is responding
- Try filtering by writable/executable flags

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit changes (`git commit -am 'Add improvement'`)
4. Push to branch (`git push origin feature/improvement`)
5. Open a Pull Request

## License

MIT License - See LICENSE file for details

## Author

**vtamrakar2011-cyber**

## Support

For issues, questions, or suggestions:
- Open an [Issue](https://github.com/vtamrakar2011-cyber/Aimbot_PR/issues)
- Check existing discussions
- Review the troubleshooting section above
