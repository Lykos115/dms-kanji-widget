# JLPT Kanji — Dank Material Shell plugin

Rotates through the JLPT kanji (N5 → N1, 2211 characters) with on'yomi,
kun'yomi and meaning, rendered by Dank Material Shell itself. One plugin,
two surfaces (DMS ≥ 1.5.0 composite plugin):

* **Bar pill** — the current kanji (plus readings or meaning) in the DankBar.
  Left click opens a popout card with the kanji, 音 on / 訓 kun readings,
  meaning, stroke count and *Play* / *Next* / *Jisho* buttons. Right click
  skips to the next kanji. With *open popouts on hover* enabled in the bar
  settings the card opens on hover.
* **Desktop widget** — text on the wallpaper layer, fixed where you put it.
  Right-click drag moves it, the corner handle resizes it, left click skips
  to the next kanji, middle click speaks the readings.

Both surfaces share the settings. By default every instance (all monitors,
bar and desktop) shows the same kanji; turn off *Same kanji everywhere* for
independent rotations.

Sibling plugins: [Hiragana](https://nemiru.tail2e41a3.ts.net/lykos/dms-hiragana-widget),
[Katakana](https://nemiru.tail2e41a3.ts.net/lykos/dms-katakana-widget) and [JLPT vocab + Jlab listening](https://nemiru.tail2e41a3.ts.net/lykos/jlpt-kanji-widget)
(the `dms-plugin` branch).

## Install

```sh
git clone https://nemiru.tail2e41a3.ts.net/lykos/dms-kanji-widget.git ~/dms-kanji-widget
~/dms-kanji-widget/install.sh          # symlink into ~/.config/DankMaterialShell/plugins
~/dms-kanji-widget/install.sh copy     # ...or copy, if you want to delete the clone
```

Then in DMS: **Settings → Plugins → Scan for Plugins**, toggle *JLPT Kanji*
on. Add `kanjiWidget` to a bar section under **Settings → DankBar → layout**,
and/or add the desktop widget under **Settings → Desktop Widgets**. Settings
(levels, timing, sizes, audio) are in the plugin's accordion in the Plugins tab.

Japanese text needs a CJK font: `sudo pacman -S noto-fonts-cjk`.

Reload after editing the QML: `dms ipc call plugins reload kanjiWidget`.

## Settings

| section | keys |
|---|---|
| Content | JLPT levels (N5 … all), **seconds per kanji** (5–600), random / stroke order, same kanji everywhere, Japanese font |
| Audio | speak automatically, audio source, text-to-speech command, player command |
| Bar pill & popout | pill text (kanji / +readings / +meaning), max pill length, popout width, popout kanji size |
| Desktop widget | kanji size, show readings / meaning / level+strokes, text outline, background opacity |

## Audio

*Play* in the popout (or middle click on the desktop widget) reads the kanji
aloud. Two sources:

* **Local text-to-speech** (default): runs the *Text-to-speech command* with
  `{text}` replaced by all on and kun readings, separated by pauses. Default
  is `espeak-ng -v ja -s 130 {text}` — `sudo pacman -S espeak-ng`. Its
  Japanese voice is robotic but clear.

  For a natural voice use [Piper](https://github.com/OHF-Voice/piper1-gpl)
  (the maintained successor of rhasspy/piper) with its Japanese voice:

  ```sh
  pipx install "piper-tts[http,ja]"       # ja = Japanese phonemizer (OpenJTalk), http = server
  install -Dm755 ~/dms-kanji-widget/say-ja ~/.local/bin/say-ja
  say-ja setup                            # downloads the ja_JA-hi_fi_captain-medium voice
  say-ja テスト                            # try it
  ```

  Already installed without the `ja` extra (error `No module named
  'pyopenjtalk'`)? Add it: `pipx inject piper-tts pyopenjtalk-plus`.

  and set the *Text-to-speech command* to `say-ja {text}`. `say-ja` plays
  through `ffplay` (`sudo pacman -S ffmpeg`). The CLI reloads the model on
  every call, about a second of delay; for instant playback run `say-ja server`
  once, e.g. from niri's `spawn-at-startup`, and `say-ja` uses it automatically.
  `say-ja setup` / `say-ja server` run Piper's modules with the Python that owns
  the `piper` command, so `python3 -m piper ...` is never needed (with pipx it
  fails: the system Python cannot see the package). `PIPER_VOICE`,
  `PIPER_DATA_DIR` and `PIPER_PORT` override the defaults.
* **JapanesePod101 online clip**: streams the pronunciation of the kanji's
  first reading from assets.languagepod101.com with the *Player command*
  (`mpv --no-video --really-quiet {file}` by default, `sudo pacman -S mpv`).
  Not every single-kanji reading exists there; missing ones play a short
  "not available" notice.

The commands are split on whitespace and run without a shell, so `{text}` /
`{file}` must be a whole argument.

*Speak automatically* reads every new kanji as it appears. Only the instance
that picked the kanji speaks, so with *Same kanji everywhere* on you hear it
once even with several pills and widgets.

## Files

| file | role |
|---|---|
| `say-ja` | Piper text-to-speech wrapper, see Audio |
| `KanjiWidget/plugin.json` | composite manifest, `widget` + `desktop` surfaces |
| `KanjiWidget/KanjiDeck.qml` | loads `data/kanji.json`, filters by level, rotates on a timer, plays audio |
| `KanjiWidget/KanjiBarWidget.qml` | `PluginComponent`: pill + popout |
| `KanjiWidget/KanjiDesktopWidget.qml` | `DesktopPluginComponent` |
| `KanjiWidget/KanjiSettings.qml` | settings UI (`PluginSettings`) |
| `KanjiWidget/data/kanji.json` | kanji list, from [davidluzgouveia/kanji-data](https://github.com/davidluzgouveia/kanji-data) via the main repo's `tools/build_data.py` |

Status: written against the DMS `master` plugin API and syntax-checked with
`qmllint`, not yet run in a live DMS session. If DMS logs an error on load,
`dms ipc call plugins reload kanjiWidget` prints it.
