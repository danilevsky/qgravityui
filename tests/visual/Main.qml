import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens
import QGravityUI.Controls
import QGravityUIVisualTest

// Visual regression runner.
//
//   qgravityui_visualtest --baseline tests/visual/baseline --out <dir>
//   qgravityui_visualtest --baseline tests/visual/baseline --update
//   ... --only skeleton      only the cases whose id contains "skeleton"
//
// Every case from Cases.qml is rendered on its own, in each of the four
// themes, grabbed and compared with its baseline. A failure leaves an
// <case>.actual.png and an <case>.diff.png behind.
//
// The window is deliberately small: one created larger than the screen never
// renders a frame, and then grabToImage never calls back.
Window {
    id: window

    width: 420
    height: 220
    visible: true
    // Transparent for input, so the real mouse pointer cannot land on a
    // control and paint it hovered. Without this the run depends on where
    // the cursor happens to be sitting: a segmented group under it came out
    // 2060px different from its baseline.
    flags: Qt.Window | Qt.WindowTransparentForInput
    title: "QGravityUI visual tests"
    color: Theme.colors.baseBackground

    readonly property var themes: [
        {name: "light", mode: GThemeMode.Light},
        {name: "dark", mode: GThemeMode.Dark},
        {name: "light-hc", mode: GThemeMode.LightHc},
        {name: "dark-hc", mode: GThemeMode.DarkHc}
    ]

    property var queue: []
    property int index: -1
    property int failures: 0
    property int updated: 0
    property int checked: 0
    property int noisy: 0
    // Two knobs, and they answer different questions.
    //
    // `channelTolerance` is how far one pixel may move before it counts at
    // all. Glyph edges land on a different subpixel from one run to the
    // next, and what that produces is a faint shift on an antialiased
    // fringe -- a few units per channel, never a solid colour. A real
    // regression is the opposite: a border that moved, a fill that changed
    // token, a control that grew, all of which put full-contrast pixels
    // where there were none.
    //
    // `maxDiff` then allows a handful of pixels to exceed even that, for the
    // occasional edge that lands a whole shade off. It used to carry the
    // whole job at 32px and kept having to grow -- 45px on a tree row, 56 on
    // a promo title -- because the count of noisy pixels scales with how
    // much text a case draws. Filtering by magnitude instead does not.
    property int channelTolerance: 24
    property int maxDiff: 8

    property url baselineDir
    property url outDir
    property bool update: false
    property var current: null

    function argument(name: string, fallback: string): string {
        const args = Qt.application.arguments;
        const i = args.indexOf(name);
        return (i !== -1 && i + 1 < args.length) ? args[i + 1] : fallback;
    }

    function directoryUrl(path: string): url {
        const normalised = path.replace(/\\/g, "/").replace(/\/+$/, "");
        return Qt.resolvedUrl(normalised + "/");
    }

    // Cartesian product of a definition's axes, in declaration order.
    function expand(definition) {
        let rows = [{}];
        for (const axis in definition.axes) {
            const next = [];
            for (const row of rows) {
                for (const value of definition.axes[axis]) {
                    const copy = Object.assign({}, row);
                    copy[axis] = value;
                    next.push(copy);
                }
            }
            rows = next;
        }

        const out = [];
        for (const row of rows) {
            let body = definition.body;
            let name = definition.id;
            for (const axis in row) {
                body = body.replace("%" + axis + "%", row[axis]);
                name += "-" + row[axis].toLowerCase();
            }
            out.push({name: name, body: body});
        }
        return out;
    }

    // --only <substring>: run just the cases whose id contains it. A full
    // pass is 632 cases and about three minutes, which is the wrong loop for
    // "look at this one component again".
    property string only: ""

    function build() {
        const cases = [];
        for (const definition of Cases.definitions) {
            if (window.only !== "" && definition.id.indexOf(window.only) === -1)
                continue;
            for (const one of expand(definition)) {
                for (const theme of window.themes) {
                    cases.push({name: one.name + "__" + theme.name,
                                body: one.body,
                                mode: theme.mode});
                }
            }
        }
        return cases;
    }

    function load(one): bool {
        const source = "import QtQuick\n"
                + "import QGravityUI.Core\n"
                + "import QGravityUI.Tokens\n"
                + "import QGravityUI.Controls\n"
                + one.body;
        try {
            window.current = Qt.createQmlObject(source, host, one.name);
        } catch (error) {
            console.warn("visual: " + one.name + " failed to build\n" + error);
            window.current = null;
            return false;
        }
        return true;
    }

    function judge(one, actual: url) {
        if (window.update) {
            window.updated += 1;
            return;
        }

        const baseline = window.baselineDir + one.name + ".png";
        const diff = window.outDir + one.name + ".diff.png";
        const differing = GVisualDiff.compare(baseline, actual, diff, window.channelTolerance);
        window.checked += 1;

        if (differing === 0) {
            // Nothing to look at, so leave nothing behind.
            GVisualDiff.remove(actual);
            return;
        }

        if (differing > 0 && differing <= window.maxDiff) {
            window.noisy += 1;
            GVisualDiff.remove(actual);
            GVisualDiff.remove(diff);
            return;
        }

        window.failures += 1;
        if (differing === -1)
            console.warn("visual: " + one.name + " has no baseline");
        else if (differing === -2)
            console.warn("visual: " + one.name + " changed size");
        else
            console.warn("visual: " + one.name + " differs by " + differing + " px");
    }

    function finish() {
        if (window.update)
            console.log("visual: wrote " + window.updated + " baselines");
        else
            console.log("visual: " + window.checked + " checked, "
                        + window.failures + " failed, "
                        + window.noisy + " within the "
                        + window.maxDiff + "px antialiasing budget (channel "
                        + "tolerance " + window.channelTolerance + ")");
        Qt.exit(window.failures > 0 ? 1 : 0);
    }

    Component.onCompleted: {
        baselineDir = directoryUrl(argument("--baseline", "tests/visual/baseline"));
        outDir = directoryUrl(argument("--out", argument("--baseline", "tests/visual/baseline")));
        update = Qt.application.arguments.indexOf("--update") !== -1;
        only = argument("--only", "");
        maxDiff = parseInt(argument("--max-diff", String(maxDiff)), 10);
        channelTolerance = parseInt(argument("--channel-tolerance",
                                             String(channelTolerance)), 10);

        GVisualDiff.makePath(baselineDir);
        GVisualDiff.makePath(outDir);

        queue = build();
        console.log("visual: " + queue.length + " cases");
        step.start();
    }

    // The case under test, alone on a plain background.
    //
    // Fixed size and integer position on purpose. Hugging the content and
    // centring it put the case on fractional coordinates that shifted by a
    // subpixel between runs, and text antialiasing then differed by a
    // handful of pixels -- enough to fail a comparison that should have
    // passed.
    Rectangle {
        id: stage

        readonly property int padding: 8

        x: 0
        y: 0
        width: 400
        height: 180
        color: Theme.colors.baseBackground

        Item {
            id: host
            x: stage.padding
            y: stage.padding
        }
    }

    // One case per tick: create it, let it lay out, grab, compare, move on.
    Timer {
        id: step

        interval: 40
        onTriggered: {
            if (window.current !== null) {
                window.current.destroy();
                window.current = null;
            }
            window.index += 1;
            if (window.index >= window.queue.length) {
                window.finish();
                return;
            }
            const one = window.queue[window.index];
            Theme.mode = one.mode;
            if (!window.load(one)) {
                window.failures += 1;
                step.start();
                return;
            }
            settle.start();
        }
    }

    // A second beat, so the new item has been laid out, has finished any
    // Behavior it started, and has been drawn before the grab. It has to
    // outlast the longest transition in the library (150ms on GButton and
    // GSwitch) or the switch knob is caught mid-slide and the comparison
    // moves by twenty-odd pixels for no reason.
    Timer {
        id: settle

        interval: 200
        onTriggered: {
            const one = window.queue[window.index];
            const actual = window.update
                    ? window.baselineDir + one.name + ".png"
                    : window.outDir + one.name + ".actual.png";
            // An explicit target size, so the grab does not follow the
            // screen's device pixel ratio: without it most images came out
            // at 500x225 on a 125% display and a few at 400x180, and a
            // baseline recorded on one machine could not be checked on
            // another.
            const grabbed = stage.grabToImage(function (result) {
                result.saveToFile(actual);
                window.judge(one, actual);
                step.start();
            }, Qt.size(stage.width, stage.height));
            if (!grabbed) {
                console.warn("visual: " + one.name + " could not be grabbed");
                window.failures += 1;
                step.start();
            }
        }
    }
}
