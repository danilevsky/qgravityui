import QtQuick
import QGravityUI.Core
import QGravityUI.Tokens

// Port of @gravity-ui/uikit DropdownMenu: a switcher button that opens a
// GMenu under itself. Upstream's default switcher is a flat button carrying
// the Ellipsis icon, and that is the default here too.
//
// Not ported: nested submenus. They need a second popup that opens sideways
// and stays open while the pointer crosses the gap between the two, which is
// a hover-intent problem rather than a styling one.
Item {
    id: dropdown

    property var options: []
    property int size: GSize.M
    // Upstream passes the switcher its own Button props, so the button and
    // the menu do not have to be the same size -- ActionsPanel puts an m
    // button over an s menu. -1 keeps them in step.
    property int switcherSize: -1
    readonly property int _switcherSize: switcherSize >= 0 ? switcherSize : size
    property int switcherView: GView.Flat
    property string switcherText: ""
    property string switcherIcon: "ellipsis"
    property real menuMinimumWidth: 0

    signal triggered(int index, var option)

    implicitWidth: switcher.implicitWidth
    implicitHeight: switcher.implicitHeight

    readonly property bool opened: menu.opened

    GButton {
        id: switcher

        anchors.fill: parent
        view: dropdown.switcherView
        size: dropdown._switcherSize
        text: dropdown.switcherText
        icon.name: dropdown.switcherIcon

        onClicked: menu.opened ? menu.close() : menu.open()
    }

    GMenu {
        id: menu

        anchorItem: dropdown
        size: dropdown.size
        options: dropdown.options
        minimumWidth: dropdown.menuMinimumWidth

        onTriggered: function (index, option) {
            dropdown.triggered(index, option);
        }
    }
}
