import QtQuick

// One step of the Gravity type scale: --g-text-<step>-font-size /
// -line-height / -font-weight.
QtObject {
    property int size
    property int lineHeight
    property int weight: Font.Normal
}
