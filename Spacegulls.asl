state("emuhawk") {}

startup {
    vars.stopwatch = new Stopwatch();
}

init {
    print("memory Process Name: " + memory.ProcessName);

    vars.gamename = timer.Run.GameName;
    vars.livesplitGameName = vars.gamename;
    print(vars.gamename);

    IntPtr startOffset = modules.First().BaseAddress;
    int moduleSize = modules.First().ModuleMemorySize;
    IntPtr endOffset = IntPtr.Add(startOffset, moduleSize);
    IntPtr gameRamAdress = new IntPtr();

    print("EmuHawk adress: " + startOffset);

    long memoryOffset = 0;

    print("Initialisation");

    if (game.ProcessName == "EmuHawk") {
        print("EmuHawk Found!");

        if (moduleSize == 4571136) {
            gameRamAdress = (IntPtr)((long)startOffset + 0x0 /* TODO find game RAM memory address */);
            memoryOffset = (long)memory.ReadValue<IntPtr>(gameRamAdress);

            print("game ram Offset: " + memoryOffset);
        }
    }

    if (memoryOffset == 0) {
        throw new Exception("Memory not yet initialized.");
    }

    print("Memory OffSet: " + memoryOffset);

    vars.watchers = new MemoryWatcherList
    {
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x244) { Name = "gameStart" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x5E) { Name = "coordinateX" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x5F) { Name = "coordinateY" },
        new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x7B) { Name = "playerState" }
    };

    vars.reInitialise = (Action)(() => {
        vars.gamename = timer.Run.GameName;
        vars.livesplitGameName = vars.gamename;
        print(vars.gamename);
    });

    vars.reInitialise();

    vars.save = 0;
    vars.savesNb = 8;
    vars.saves = new List<Dictionary<string, int>> {
        new Dictionary<string, int>{{"x", 10},{"y", 11}},
        new Dictionary<string, int>{{"x", 6},{"y", 11}},
        new Dictionary<string, int>{{"x", 6},{"y", 9}},
        new Dictionary<string, int>{{"x", 10},{"y", 8}},
        new Dictionary<string, int>{{"x", 10},{"y", 7}},
        new Dictionary<string, int>{{"x", 15},{"y", 9}},
        new Dictionary<string, int>{{"x", 10},{"y", 6}},
        new Dictionary<string, int>{{"x", 10},{"y", 0}}
    };

    vars.end = new Dictionary<string, int> {
        {"x", 13}, {"y", 2}
    };
    vars.endState = 11;
}

update {
    vars.watchers.UpdateAll(game);
	if (vars.livesplitGameName != timer.Run.GameName) {
		vars.gamename = timer.Run.GameName;
        vars.reInitialise();
	}
}

start {
    vars.stopwatch.Restart();
    return vars.watchers["gameStart"].Old == 0 && vars.watchers["gameStart"].Current == 1;
}

reset {
    return vars.watchers["gameStart"].Old == 1 && vars.watchers["gameStart"].Current == 0;
}

split {
    bool doSplit = (
        vars.save < vars.savesNb &&
        vars.watchers["coordinateX"].Current == vars.saves[vars.save]["x"] &&
        vars.watchers["coordinateY"].Current == vars.saves[vars.save]["y"]
    ) || (
        vars.watchers["coordinateX"].Current == vars.end["x"] &&
        vars.watchers["coordinateY"].Current == vars.end["y"] &&
        vars.watchers["playerState"].Current == vars.endState
    );

    if (doSplit) {
        vars.save++;
    }

    return doSplit;
}
