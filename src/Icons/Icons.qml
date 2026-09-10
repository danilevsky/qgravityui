pragma Singleton
import QtQuick

// The @gravity-ui/icons set, bundled as QML module resources.
//
//     GIcon { name: "circle-check-fill"; size: 20 }
//     Image { source: Icons.url("xmark") }
//
// Names are the upstream kebab-case file names ("circle-info-fill"), not the
// React component names ("CircleInfoFill"): the SVGs are what we ship, so the
// SVG names are what the API speaks.
QtObject {
    id: icons

    readonly property IconCatalog _catalog: IconCatalog {}

    // Every bundled name, sorted.
    readonly property var names: _catalog.names

    // Resolved against this file's own URL, so it keeps working wherever the
    // module ends up in the resource tree.
    function url(name: string): url {
        return Qt.resolvedUrl("svgs/" + name + ".svg");
    }

    function has(name: string): bool {
        return names.indexOf(name) !== -1;
    }
}
