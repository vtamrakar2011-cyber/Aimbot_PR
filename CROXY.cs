using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Security.Principal;
using System.Text;
using System.Threading.Tasks;

namespace AYUSH
{
    /// <summary>
    /// CROXY - Memory Scanning Engine
    /// High-performance pattern scanning and memory manipulation library
    /// </summary>
    public class INTERNAL
    {
        #region WinAPI Imports
        [DllImport("kernel32.dll")]
        private static extern void GetSystemInfo(out SYSTEM_INFO lpSystemInfo);

        [DllImport("kernel32.dll")]
        public static extern IntPtr OpenProcess(uint dwDesiredAccess, bool bInheritHandle, int dwProcessId);

        [DllImport("kernel32.dll")]
        public static extern bool IsWow64Process(IntPtr hProcess, out bool lpSystemInfo);

        [DllImport("kernel32.dll")]
        private static extern bool ReadProcessMemory(IntPtr hProcess, UIntPtr lpBaseAddress, [Out] byte[] lpBuffer, UIntPtr nSize, IntPtr lpNumberOfBytesRead);

        [DllImport("kernel32.dll")]
        private static extern bool WriteProcessMemory(IntPtr hProcess, UIntPtr lpBaseAddress, byte[] lpBuffer, UIntPtr nSize, IntPtr lpNumberOfBytesWritten);

        [DllImport("kernel32.dll")]
        public static extern int CloseHandle(IntPtr hObject);

        [DllImport("kernel32.dll", EntryPoint = "VirtualQueryEx")]
        public static extern UIntPtr Native_VirtualQueryEx(IntPtr hProcess, UIntPtr lpAddress, out MEMORY_BASIC_INFORMATION64 lpBuffer, UIntPtr dwLength);

        [DllImport("kernel32.dll", EntryPoint = "VirtualQueryEx")]
        public static extern UIntPtr Native_VirtualQueryEx(IntPtr hProcess, UIntPtr lpAddress, out MEMORY_BASIC_INFORMATION32 lpBuffer, UIntPtr dwLength);

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
        private static extern uint GetPrivateProfileString(string lpAppName, string lpKeyName, string lpDefault, StringBuilder lpReturnedString, uint nSize, string lpFileName);
        #endregion

        #region Fields
        public Process theProc = null;
        public IntPtr pHandle;
        private bool _is64Bit;
        public bool Is64Bit { get => _is64Bit; private set => _is64Bit = value; }

        private const uint PROCESS_ALL_ACCESS = 0x1F0FFF;
        private const uint MEM_COMMIT = 0x1000;
        private const uint MEM_PRIVATE = 0x20000;
        private const uint PAGE_NOACCESS = 0x01;
        #endregion

        #region Structs
        [StructLayout(LayoutKind.Sequential)]
        public struct MEMORY_BASIC_INFORMATION32
        {
            public UIntPtr BaseAddress;
            public UIntPtr AllocationBase;
            public uint AllocationProtect;
            public uint RegionSize;
            public uint State;
            public uint Protect;
            public uint Type;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct MEMORY_BASIC_INFORMATION64
        {
            public UIntPtr BaseAddress;
            public UIntPtr AllocationBase;
            public uint AllocationProtect;
            public uint __alignment1;
            public ulong RegionSize;
            public uint State;
            public uint Protect;
            public uint Type;
            public uint __alignment2;
        }

        public struct MEMORY_BASIC_INFORMATION
        {
            public UIntPtr BaseAddress;
            public UIntPtr AllocationBase;
            public uint AllocationProtect;
            public long RegionSize;
            public uint State;
            public uint Protect;
            public uint Type;
        }

        public struct SYSTEM_INFO
        {
            public ushort processorArchitecture;
            private ushort reserved;
            public uint pageSize;
            public UIntPtr minimumApplicationAddress;
            public UIntPtr maximumApplicationAddress;
            public IntPtr activeProcessorMask;
            public uint numberOfProcessors;
            public uint processorType;
            public uint allocationGranularity;
            public ushort processorLevel;
            public ushort processorRevision;
        }
        #endregion

        #region VirtualQuery Wrapper
        public UIntPtr VirtualQueryEx(IntPtr hProcess, UIntPtr lpAddress, out MEMORY_BASIC_INFORMATION lpBuffer)
        {
            if (this.Is64Bit || IntPtr.Size == 8)
            {
                MEMORY_BASIC_INFORMATION64 info64;
                UIntPtr result = Native_VirtualQueryEx(hProcess, lpAddress, out info64, new UIntPtr((uint)Marshal.SizeOf(typeof(MEMORY_BASIC_INFORMATION64))));
                lpBuffer = new MEMORY_BASIC_INFORMATION
                {
                    BaseAddress = info64.BaseAddress,
                    AllocationBase = info64.AllocationBase,
                    AllocationProtect = info64.AllocationProtect,
                    RegionSize = (long)info64.RegionSize,
                    State = info64.State,
                    Protect = info64.Protect,
                    Type = info64.Type
                };
                return result;
            }
            else
            {
                MEMORY_BASIC_INFORMATION32 info32;
                UIntPtr result = Native_VirtualQueryEx(hProcess, lpAddress, out info32, new UIntPtr((uint)Marshal.SizeOf(typeof(MEMORY_BASIC_INFORMATION32))));
                lpBuffer = new MEMORY_BASIC_INFORMATION
                {
                    BaseAddress = info32.BaseAddress,
                    AllocationBase = info32.AllocationBase,
                    AllocationProtect = info32.AllocationProtect,
                    RegionSize = info32.RegionSize,
                    State = info32.State,
                    Protect = info32.Protect,
                    Type = info32.Type
                };
                return result;
            }
        }
        #endregion

        #region Process Management
        public bool IsAdmin()
        {
            using (WindowsIdentity identity = WindowsIdentity.GetCurrent())
            {
                return new WindowsPrincipal(identity).IsInRole(WindowsBuiltInRole.Administrator);
            }
        }

        public bool OpenProcess(int pid)
        {
            if (pid <= 0) return false;
            try
            {
                if (this.theProc != null && this.theProc.Id == pid && this.pHandle != IntPtr.Zero) return true;

                this.theProc = Process.GetProcessById(pid);
                if (this.theProc == null || !this.theProc.Responding) return false;

                this.pHandle = OpenProcess(PROCESS_ALL_ACCESS, false, pid);
                if (this.pHandle == IntPtr.Zero) return false;

                bool isWow64;
                IsWow64Process(this.pHandle, out isWow64);
                this.Is64Bit = (Environment.Is64BitOperatingSystem && !isWow64);

                return true;
            }
            catch { return false; }
        }
        #endregion

        #region High Performance Scan
        private struct PatternData
        {
            public byte[] Bytes;
            public byte[] Mask;
            public int Length;
            public bool Valid;
        }

        private PatternData ParsePattern(string patternString, string file = "")
        {
            string text = patternString;
            if (!string.IsNullOrEmpty(file))
            {
                StringBuilder sb = new StringBuilder(1024);
                GetPrivateProfileString("codes", patternString, "", sb, (uint)sb.Capacity, file);
                if (sb.Length > 0) text = sb.ToString();
            }

            if (string.IsNullOrWhiteSpace(text)) return new PatternData { Valid = false };

            var parts = text.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            var p = new PatternData
            {
                Bytes = new byte[parts.Length],
                Mask = new byte[parts.Length],
                Length = parts.Length,
                Valid = true
            };

            for (int i = 0; i < parts.Length; i++)
            {
                if (parts[i] == "??" || parts[i] == "?")
                {
                    p.Mask[i] = 0x00;
                    p.Bytes[i] = 0x00;
                }
                else
                {
                    p.Mask[i] = 0xFF;
                    p.Bytes[i] = Convert.ToByte(parts[i], 16);
                }
            }
            return p;
        }

        /// <summary>
        /// Ultra-fast AoB Scan using Unsafe Pointers and Parallel Processing.
        /// </summary>
        public Task<IEnumerable<long>> AoBScan(string search, bool writable = true, bool executable = false, string file = "")
        {
            return Task.Run(() =>
            {
                var foundAddresses = new ConcurrentBag<long>();
                var pattern = ParsePattern(search, file);
                if (!pattern.Valid) return (IEnumerable<long>)foundAddresses;

                List<MEMORY_BASIC_INFORMATION> memoryRegions = new List<MEMORY_BASIC_INFORMATION>();
                GetSystemInfo(out SYSTEM_INFO sysInfo);

                ulong minStart = sysInfo.minimumApplicationAddress.ToUInt64();
                ulong maxEnd = sysInfo.maximumApplicationAddress.ToUInt64();
                UIntPtr currentAddr = new UIntPtr(minStart);

                while (currentAddr.ToUInt64() < maxEnd)
                {
                    if (VirtualQueryEx(pHandle, currentAddr, out MEMORY_BASIC_INFORMATION mem) == UIntPtr.Zero) break;

                    bool isCommit = mem.State == MEM_COMMIT;
                    bool isAccessible = (mem.Protect & PAGE_NOACCESS) == 0 && (mem.Protect & 0x100) == 0;

                    if (isCommit && isAccessible)
                    {
                        bool isWritable = (mem.Protect & 0x04) > 0 || (mem.Protect & 0x40) > 0;
                        bool isExecutable = (mem.Protect & 0x10) > 0 || (mem.Protect & 0x20) > 0 || (mem.Protect & 0x40) > 0;

                        if ((writable && isWritable) || (executable && isExecutable))
                        {
                            memoryRegions.Add(mem);
                        }
                    }

                    currentAddr = new UIntPtr(currentAddr.ToUInt64() + (ulong)mem.RegionSize);
                }

                Parallel.ForEach(memoryRegions, new ParallelOptions { MaxDegreeOfParallelism = Environment.ProcessorCount }, (region) =>
                {
                    if (region.RegionSize <= 0 || region.RegionSize > int.MaxValue) return;

                    byte[] buffer = new byte[region.RegionSize];
                    if (ReadProcessMemory(pHandle, region.BaseAddress, buffer, (UIntPtr)region.RegionSize, IntPtr.Zero))
                    {
                        unsafe
                        {
                            fixed (byte* pBuffer = buffer)
                            fixed (byte* pPattern = pattern.Bytes)
                            fixed (byte* pMask = pattern.Mask)
                            {
                                int limit = (int)region.RegionSize - pattern.Length;

                                for (int i = 0; i <= limit; i++)
                                {
                                    if (pMask[0] == 0xFF && pBuffer[i] != pPattern[0]) continue;

                                    bool match = true;
                                    for (int j = 1; j < pattern.Length; j++)
                                    {
                                        if (pMask[j] == 0xFF && pBuffer[i + j] != pPattern[j])
                                        {
                                            match = false;
                                            break;
                                        }
                                    }

                                    if (match)
                                    {
                                        foundAddresses.Add((long)region.BaseAddress + i);
                                    }
                                }
                            }
                        }
                    }
                });

                return (IEnumerable<long>)foundAddresses;
            });
        }
        #endregion

        #region Helpers
        public bool WriteMemory(string address, string type, string value, string offset = "")
        {
            try
            {
                if (pHandle == IntPtr.Zero) return false;

                long addrVal = Convert.ToInt64(address, 16);
                if (!string.IsNullOrEmpty(offset)) addrVal += Convert.ToInt64(offset, 16);

                UIntPtr target = new UIntPtr((ulong)addrVal);
                byte[] data = null;

                switch (type.ToLower())
                {
                    case "int": data = BitConverter.GetBytes(int.Parse(value)); break;
                    case "float": data = BitConverter.GetBytes(float.Parse(value)); break;
                    case "double": data = BitConverter.GetBytes(double.Parse(value)); break;
                    case "long": data = BitConverter.GetBytes(long.Parse(value)); break;
                    case "string": data = Encoding.UTF8.GetBytes(value); break;
                    case "byte": data = new byte[] { byte.Parse(value) }; break;
                    case "hex":
                        string[] hex = value.Split(' ');
                        data = new byte[hex.Length];
                        for (int i = 0; i < hex.Length; i++) data[i] = Convert.ToByte(hex[i], 16);
                        break;
                }

                if (data != null)
                {
                    return WriteProcessMemory(pHandle, target, data, (UIntPtr)data.Length, IntPtr.Zero);
                }
            }
            catch { }
            return false;
        }

        public int ReadInt(long address)
        {
            try
            {
                byte[] buffer = new byte[4];
                ReadProcessMemory(pHandle, new UIntPtr((ulong)address), buffer, (UIntPtr)4, IntPtr.Zero);
                return BitConverter.ToInt32(buffer, 0);
            }
            catch
            {
                return 0;
            }
        }

        public Task<IEnumerable<long>> AoBScan2(string search, bool writable = false, bool executable = false, string file = "")
        {
            return AoBScan(search, writable, executable, file);
        }
        #endregion
    }
}
