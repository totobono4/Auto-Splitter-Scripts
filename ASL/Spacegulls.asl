/*
    ASL Spacegulls Auto-splitter
    file: Spacegulls
    authors: totobono4 Lyliya
    duck: Etimo
    git: https://github.com/totobono4/Auto-Splitter-Scripts
*/

state("emuhawk") {}

startup {
    for (int saves = 1; saves < 9; saves++) {
        settings.Add("save" + saves, true, "Save " + saves);
    }
    settings.Add("UD_10", false, "Ultime Decathlon 10 - run dark/light");
}

init {
    vars.tokenSource = new CancellationTokenSource();
    vars.token = vars.tokenSource.Token;

    vars.CurPtr = 0;

    vars.deadRamPtr = new List<IntPtr>{};
    vars.deadRamFrameBuffer = 200;
    
    vars.scanning = false;

    vars.maxFrameBuffer = 0;
    vars.frameBuffer = 0;

    vars.save = 0;
    vars.savesNb = 7;
    vars.save5_position = 0x84;
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
    if (!vars.scanning) {
        vars.threadScan = new Thread(() => {
            SigScanTarget scanTarget = null;
            if (memory.ProcessName.ToLower().Contains("emuhawk"))
                scanTarget = new SigScanTarget(0, "00 04 ?? ?? ?? ?? 00 ?? ?? 00 00 00 00 00 00 00 00 00 ?? 00 40 00 00 00 00 00 00 00 00 ?? ?? 00");
            
            IntPtr ptr = IntPtr.Zero;
            while(!vars.token.IsCancellationRequested) {
                print("[Autosplitter] Scanning memory");
                foreach (var page in game.MemoryPages()) {
                    var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);
                    if((ptr = scanner.Scan(scanTarget)) != IntPtr.Zero) {
                        if (vars.deadRamPtr.Contains(ptr)) continue;
                        vars.curPtr = ptr;
                        break;
                    }
                }
                if (ptr != IntPtr.Zero) {
                    vars.watchers = new MemoryWatcherList() {
                        (vars.coordX = new MemoryWatcher<byte>(ptr+0x5E)),
                        (vars.coordY = new MemoryWatcher<byte>(ptr+0x5F)),
                        (vars.start = new MemoryWatcher<byte>(ptr+0x244)),
                        (vars.playerState = new MemoryWatcher<byte>(ptr+0x7B)),
                        (vars.playerCoords = new MemoryWatcher<byte>(ptr+0x7)),
                        (vars.frames = new MemoryWatcher<byte>(ptr+0x12))
                    };
                    print("[Autosplitter] Done scanning");
                    break;
                }
                Thread.Sleep(2000);
                vars.deadRamPtr = new List<IntPtr>{};
            }
            print("[Autosplitter] Exit thread scan");
        });
        vars.threadScan.Start();
        vars.scanning = true;
    }

    if(vars.threadScan.IsAlive)
        return false;
    
    vars.watchers.UpdateAll(game);

    if (vars.frames.Old != vars.frames.Current) {
        vars.frameBuffer = 0;
    }
    else {
        vars.frameBuffer++;
        if (vars.maxFrameBuffer < vars.frameBuffer) {
            vars.maxFrameBuffer = vars.frameBuffer;
        }
    }

    if (vars.maxFrameBuffer > vars.deadRamFrameBuffer) {
        vars.maxFrameBuffer = 0;
        vars.deadRamPtr.Add(vars.curPtr);
        vars.scanning = false;
        return false;
    }
}

start {
    if (vars.start.Old == 0 && vars.start.Current == 1) {
        vars.save = 0;
        return true;
    }
    return false;
}

split {
    if (vars.save <= vars.savesNb && vars.coordX.Current == vars.saves[vars.save]["x"] && vars.coordY.Current == vars.saves[vars.save]["y"]) {
        if (settings["UD_10"]) {
            if (vars.save != 4 || (vars.save == 4 && vars.playerCoords.Current >= vars.save5_position && vars.playerCoords.Current < 0xF0)) {
                vars.save++;
                return settings["save" + vars.save];
            }
        } else {
            vars.save++;
            return settings["save" + vars.save];
        }
    }

    if (vars.coordX.Current == vars.end["x"] && vars.coordY.Current == vars.end["y"] && vars.playerState.Current == vars.endState) {
        return true;
    }

    return false;
}

reset {
    if (vars.start.Old == 1 && vars.start.Current == 0) {
        vars.save = 0;
        return true;
    }
    return false;
}

exit {
    vars.tokenSource.Cancel();
}

shutdown {
    vars.tokenSource.Cancel();
}
