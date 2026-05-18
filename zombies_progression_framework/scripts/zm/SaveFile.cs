using System;
using System.IO;
using System.Text.Json;
using System.Threading;

class Program
{
    static string logPath = @"C:\Game\logs\console.log";
    static string saveFolder = @"C:\Game\xp_saves\";

    static long lastPosition = 0;

    static void Main()
    {
        Directory.CreateDirectory(saveFolder);
        Console.WriteLine("XP Bridge running...");

        while (true)
        {
            try
            {
                ReadNewLines();
            }
            catch (Exception ex)
            {
                Console.WriteLine("Loop error: " + ex.Message);
            }

            Thread.Sleep(20);
        }
    }

    static void ReadNewLines()
    {
        using FileStream fs = new FileStream(
            logPath,
            FileMode.Open,
            FileAccess.Read,
            FileShare.ReadWrite
        );

        fs.Seek(lastPosition, SeekOrigin.Begin);

        using StreamReader reader = new StreamReader(fs);

        string line;
        while ((line = reader.ReadLine()) != null)
        {
            ProcessLine(line);
        }

        lastPosition = fs.Position;
    }

    static void ProcessLine(string line)
    {
        string[] parts = line.Split('|', StringSplitOptions.TrimEntries);

        if (parts.Length == 0)
            return;

        switch (parts[0])
        {
            case "XP_SAVE":
                HandleSave(parts);
                break;

            case "XP_REQUEST":
                HandleRequest(parts);
                break;
        }
    }

    static void HandleSave(string[] parts)
    {
        if (parts.Length < 4) return;

        string guid = parts[1];

        int xp = int.TryParse(parts[2], out var x) ? x : 0;
        int level = int.TryParse(parts[3], out var l) ? l : 1;

        PlayerXP data = new PlayerXP
        {
            Guid = guid,
            XP = Math.Max(0, xp),
            Level = Math.Max(1, level)
        };

        string file = Path.Combine(saveFolder, guid + ".json");

        File.WriteAllText(file, JsonSerializer.Serialize(data, new JsonSerializerOptions
        {
            WriteIndented = true
        }));

        Console.WriteLine($"XP_SAVED|{guid}|{xp}|{level}");
    }

    static void HandleRequest(string[] parts)
    {
        if (parts.Length < 2) return;

        string guid = parts[1];
        string file = Path.Combine(saveFolder, guid + ".json");

        if (!File.Exists(file))
        {
            Console.WriteLine($"XP_LOAD|{guid}|0|1");
            return;
        }

        PlayerXP data = JsonSerializer.Deserialize<PlayerXP>(File.ReadAllText(file));

        if (data == null)
        {
            Console.WriteLine($"XP_LOAD|{guid}|0|1");
            return;
        }

        Console.WriteLine($"XP_LOAD|{guid}|{data.XP}|{data.Level}");
    }
}

class PlayerXP
{
    public string Guid { get; set; }
    public int XP { get; set; }
    public int Level { get; set; }
}

File.WriteAllBytes("test", 2)

Console.Print(File)