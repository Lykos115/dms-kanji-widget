import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services

// Non-visual helper shared by the bar widget and the desktop widget.
// Loads data/kanji.json, filters by JLPT level, rotates on a timer and
// speaks the readings on request.
Item {
    id: deck
    visible: false
    width: 0
    height: 0

    // plugin settings object (PluginComponent.pluginData / DesktopPluginComponent.pluginData)
    property var settings: ({})

    readonly property string levelsKey: settings.levels ?? "5"
    readonly property int intervalSeconds: Math.max(3, settings.interval ?? 30)
    readonly property bool shuffleOrder: settings.shuffle ?? true
    // keep every bar pill / desktop widget (all monitors) on the same kanji
    readonly property bool syncInstances: settings.syncInstances ?? true
    readonly property bool autoPlay: settings.autoPlay ?? false
    // "tts" = local text-to-speech of the readings, "online" = JapanesePod101 clip of the first reading
    readonly property string audioSource: settings.audioSource ?? "tts"
    readonly property string playerCommand: (settings.playerCommand ?? "") !== "" ? settings.playerCommand : "mpv --no-video --really-quiet {file}"
    readonly property string ttsCommand: (settings.ttsCommand ?? "") !== "" ? settings.ttsCommand : "espeak-ng -v ja -s 130 {text}"
    readonly property string pluginId: "kanjiWidget"
    property double lastStamp: 0

    // current item
    property string main: "…"
    property string on: ""        // on'yomi, "・"-joined
    property string kun: ""       // kun'yomi, "・"-joined
    property string meaning: ""
    property string tag: ""
    property int strokes: 0
    property bool ready: false
    readonly property string reading: [on, kun].filter(x => x !== "").join("  ")
    readonly property bool hasAudio: on !== "" || kun !== ""

    // raw data
    property var kanji: []
    property var items: []
    property int pos: -1

    readonly property string dataDir: Qt.resolvedUrl("data").toString().replace(/^file:\/\//, "")

    FileView {
        path: deck.dataDir + "/kanji.json"
        onLoaded: { deck.kanji = JSON.parse(text()); deck.rebuild(); }
        onLoadFailed: err => console.warn("kanjiWidget: cannot read", path, err)
    }

    onLevelsKeyChanged: rebuild()
    onShuffleOrderChanged: rebuild()

    Connections {
        target: PluginService
        function onGlobalVarChanged(pid, name) {
            if (pid === deck.pluginId && name === "current")
                deck.applyGlobal();
        }
    }

    function setCurrent(it) {
        main = it.main; on = it.on; kun = it.kun; meaning = it.meaning; tag = it.tag; strokes = it.strokes;
    }

    // adopt the shared item if another instance published a newer one
    function applyGlobal() {
        if (!syncInstances) return false;
        const g = PluginService.getGlobalVar(pluginId, "current", null);
        if (!g || !g.stamp || g.stamp === lastStamp) return false;
        lastStamp = g.stamp;
        setCurrent(g);
        ready = true;
        ticker.restart();
        return true;
    }

    Timer {
        id: ticker
        interval: deck.intervalSeconds * 1000
        running: deck.ready
        repeat: true
        onTriggered: deck.next(false)
    }

    function levels() {
        return levelsKey.split(",").map(s => parseInt(s.trim())).filter(n => !isNaN(n));
    }

    function shuffle(a) {
        for (let i = a.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            const t = a[i]; a[i] = a[j]; a[j] = t;
        }
        return a;
    }

    function rebuild() {
        const lv = levels();
        const all = [];
        for (const k of kanji) {
            if (lv.indexOf(k.level) < 0) continue;
            all.push({ main: k.kanji, on: k.on.join("・"), kun: k.kun.join("・"),
                       meaning: k.meaning, tag: "N" + k.level, strokes: k.strokes ?? 0 });
        }
        // data is sorted N5 → N1 by stroke count, which is the sequential order
        items = shuffleOrder ? shuffle(all) : all;
        pos = -1;
        ready = all.length > 0;
        if (ready) next(false);
        else { main = "—"; on = ""; kun = ""; meaning = "no level selected"; tag = ""; strokes = 0; }
    }

    function pick() {
        pos = (pos + 1) % items.length;
        if (pos === 0 && shuffleOrder) shuffle(items);
        return items[pos];
    }

    // force=true: user clicked, always advance. force=false: timer tick; if another
    // instance already advanced within this interval, adopt its kanji instead.
    function next(force) {
        if (!ready) return;
        if (syncInstances && !force) {
            const g = PluginService.getGlobalVar(pluginId, "current", null);
            if (g && g.stamp && Date.now() - g.stamp < intervalSeconds * 1000 - 1500) {
                if (g.stamp !== lastStamp) applyGlobal();
                else ticker.restart();
                return;
            }
        }
        const it = pick();
        setCurrent(it);
        ticker.restart();
        if (syncInstances) {
            lastStamp = Date.now();
            PluginService.setGlobalVar(pluginId, "current", {
                main: it.main, on: it.on, kun: it.kun, meaning: it.meaning,
                tag: it.tag, strokes: it.strokes, stamp: lastStamp
            });
        }
        // only the instance that picked the item plays it, so synced instances do not all talk at once
        if (autoPlay) play();
    }

    // --- audio -------------------------------------------------------------
    // Commands are split on whitespace, no shell involved; "{file}" / "{text}"
    // must be a whole argument and are replaced with the real value.
    function argv(cmd, key, value) {
        return cmd.split(/\s+/).filter(t => t.length > 0).map(t => t === key ? value : t);
    }

    function play() {
        if (!hasAudio) return;
        if (audioSource === "online") {
            const first = (on !== "" ? on : kun).split("・")[0];
            const url = "https://assets.languagepod101.com/dictionary/japanese/audiomp3.php?kanji="
                + encodeURIComponent(main) + "&kana=" + encodeURIComponent(first);
            Quickshell.execDetached(argv(playerCommand, "{file}", url));
            return;
        }
        // read every on and kun reading, with a pause between them
        const text = [on, kun].filter(x => x !== "").join("、").split("・").join("、");
        Quickshell.execDetached(argv(ttsCommand, "{text}", text));
    }
}
