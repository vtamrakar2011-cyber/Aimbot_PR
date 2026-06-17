# Quick Start Guide - Aimbot Memory Scanner

## 📍 Your Repository Location

```
C:\Users\Vishnuuu\Desktop\VISHNU X CHEATS
```

## 🚀 One-Click Build & Launch

### **Step 1: Open Command Prompt in Repository**

1. Open **File Explorer**
2. Navigate to: `C:\Users\Vishnuuu\Desktop\VISHNU X CHEATS`
3. Press **Ctrl+L** (or click the address bar)
4. It will show the full path
5. Type `cmd` and press **Enter**

### **Step 2: Run the Build Script**

In the command prompt that opens, type:

```batch
Build-and-Run.bat
```

Then press **Enter**.

---

## 🎯 Alternative: Right-Click Method

1. Open **File Explorer**
2. Navigate to: `C:\Users\Vishnuuu\Desktop\VISHNU X CHEATS`
3. Find `Build-and-Run.bat`
4. **Right-click** on it
5. Select **"Run as Administrator"**
6. Wait for Visual Studio to build and launch

---

## ⚙️ Prerequisites

✅ Visual Studio 2019 or 2022 installed
✅ .NET Framework 4.7.2+ installed
✅ Windows 7 or later
✅ Administrator privileges

---

## 🔧 Troubleshooting

### "Visual Studio not found"
- Install Visual Studio Community (free): https://visualstudio.microsoft.com/downloads/
- Make sure to select "Desktop development with C++" or ".NET desktop development"

### "Build failed"
- Ensure you're running as Administrator
- Close any instances of the application already running
- Try building manually in Visual Studio

### "HD-Player process not found"
- Start the HD-Player application before clicking "START AIMBOT SCAN"
- Check that the process name is exactly "HD-Player"

---

## 📋 What the Script Does

1. ✅ Checks for Visual Studio installation
2. ✅ Locates MSBuild compiler
3. ✅ Builds the solution (AimbotScanner.sln)
4. ✅ Compiles all source files
5. ✅ Creates WindowsFormsApp1.exe
6. ✅ Launches the application automatically

---

## 📂 Repository Structure

```
C:\Users\Vishnuuu\Desktop\VISHNU X CHEATS
├── AimbotScanner.sln              ← Solution file
├── Build-and-Run.bat              ← Windows batch script
├── Build-and-Run.ps1              ← PowerShell script
├── CROXY.cs                       ← Memory scanning engine
├── README.md                      ← Documentation
├── LICENSE                        ← MIT License
└── WindowsFormsApp1/              ← Windows Forms project
    ├── Form1.cs                   ← Main UI
    ├── Form1.Designer.cs
    ├── Program.cs
    └── WindowsFormsApp1.csproj
```

---

## ✨ Features

🎯 **Ultra-fast pattern scanning** with parallel processing
🔄 **Wildcard support** for flexible pattern matching (`??` = any byte)
📍 **Memory manipulation** - read/write operations
⚡ **Unsafe pointers** for maximum performance
🎮 **HD-Player targeting** with offset-based addressing

---

## 🛡️ Disclaimer

⚠️ This tool is for **educational purposes only**.

Using it on online games or protected software may violate their Terms of Service and applicable laws.

**Only use on:**
- Personal single-player games
- Your own applications
- Educational/research projects

---

## 📞 Support

For issues or questions:
- Check the README.md for detailed documentation
- Review the troubleshooting section above
- Open an issue on GitHub: https://github.com/vtamrakar2011-cyber/Aimbot_PR/issues

---

**Happy scanning!** 🚀
