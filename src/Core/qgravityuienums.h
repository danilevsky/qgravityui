#pragma once

#include <QObject>
#include <QtQmlIntegration>

// Shared vocabularies for QGravityUI, as real enums.
//
// Gravity's own props are strings ("view: 'action'"), and copying that into
// QML read well but typed badly: `view: "acton"` is a valid string, so
// neither qmllint nor the QML compiler ever saw the typo -- the button just
// silently fell back to the default view. These enums are the fix.
//
// One vocabulary per concept, shared by every component that speaks it, so a
// size means the same step everywhere. A component accepts the subset that
// makes sense for it; the values it ignores fall back to its default, exactly
// as the strings used to.
//
// Enum holders only -- never instantiated, hence QML_UNCREATABLE.

#define GRAVITY_ENUM_HOLDER(Name)                                              \
    Q_OBJECT                                                                   \
    QML_ELEMENT                                                                \
    QML_UNCREATABLE(#Name " is an enum holder, not a type you instantiate")

// Control size steps. Not every component has all seven: Avatar spans the
// whole range (16/20/24/28/32/42/50), buttons and inputs use Xs..Xl, Card
// only M and L. Upstream spells the two smallest "3xs" and "2xs" on Avatar
// and "xxs" on Label; identifiers cannot start with a digit, so the ladder is
// named from the top down and Label's xxs is Xxs.
class GSize : public QObject
{
    GRAVITY_ENUM_HOLDER(GSize)
public:
    enum Value {
        Xxxs,
        Xxs,
        Xs,
        S,
        M,
        L,
        Xl,
    };
    Q_ENUM(Value)
};

// Button.css carries the long tail here; Card, Alert, Avatar and the input
// family reuse the first handful (Outlined / Filled / Clear / Raised).
class GView : public QObject
{
    GRAVITY_ENUM_HOLDER(GView)
public:
    enum Value {
        Normal,
        Action,
        Raised,
        Outlined,
        Flat,
        Filled,
        Clear,

        OutlinedInfo,
        OutlinedSuccess,
        OutlinedWarning,
        OutlinedDanger,
        OutlinedUtility,
        OutlinedAction,

        FlatSecondary,
        FlatInfo,
        FlatSuccess,
        FlatWarning,
        FlatDanger,
        FlatUtility,
        FlatAction,

        NormalContrast,
        OutlinedContrast,
        FlatContrast,
    };
    Q_ENUM(Value)
};

// The semantic colour theme of a component (Label, Alert, Toast, Avatar,
// Progress, Menu.Item). Distinct from the light/dark palette -- that is
// GThemeMode.
class GTheme : public QObject
{
    GRAVITY_ENUM_HOLDER(GTheme)
public:
    enum Value {
        Normal,
        Info,
        Success,
        Warning,
        Danger,
        Utility,
        Unknown,
        Clear,
        Brand,
        Misc,
    };
    Q_ENUM(Value)
};

// The four palettes shipped in styles.css.
class GThemeMode : public QObject
{
    GRAVITY_ENUM_HOLDER(GThemeMode)
public:
    enum Value {
        Light,
        Dark,
        LightHc,
        DarkHc,
    };
    Q_ENUM(Value)
};

// The 18 steps of the type scale.
class GVariant : public QObject
{
    GRAVITY_ENUM_HOLDER(GVariant)
public:
    enum Value {
        Body1,
        Body2,
        Body3,
        BodyShort,
        Caption1,
        Caption2,
        Header1,
        Header2,
        Subheader1,
        Subheader2,
        Subheader3,
        Display1,
        Display2,
        Display3,
        Display4,
        Code1,
        Code2,
        Code3,
    };
    Q_ENUM(Value)
};

// Semantic text colours (Text's `color` prop upstream).
class GTextColor : public QObject
{
    GRAVITY_ENUM_HOLDER(GTextColor)
public:
    enum Value {
        Primary,
        Secondary,
        Hint,
        Brand,
        Danger,
        Positive,
        Warning,
        Info,
        Link,
    };
    Q_ENUM(Value)
};

// Validation state of the input family.
class GInputState : public QObject
{
    GRAVITY_ENUM_HOLDER(GInputState)
public:
    enum Value {
        Normal,
        Error,
    };
    Q_ENUM(Value)
};

// Which side of its anchor an overlay opens on.
class GPlacement : public QObject
{
    GRAVITY_ENUM_HOLDER(GPlacement)
public:
    enum Value {
        Bottom,
        Top,
        Left,
        Right,
    };
    Q_ENUM(Value)
};

// Layout axis. Flex says row/column upstream and Divider says
// horizontal/vertical; they are the same choice, so they share one enum.
class GDirection : public QObject
{
    GRAVITY_ENUM_HOLDER(GDirection)
public:
    enum Value {
        Horizontal,
        Vertical,
    };
    Q_ENUM(Value)
};

// Alignment along the main axis (Divider's label, Table cells, Disclosure's
// arrow side).
class GAlign : public QObject
{
    GRAVITY_ENUM_HOLDER(GAlign)
public:
    enum Value {
        Start,
        Center,
        End,
    };
    Q_ENUM(Value)
};

// Avatar and Skeleton outlines.
class GShape : public QObject
{
    GRAVITY_ENUM_HOLDER(GShape)
public:
    enum Value {
        Circle,
        Square,
        Rectangle,
    };
    Q_ENUM(Value)
};

// Link's own three-way view: it colours text, it does not fill a box, so it
// does not share GView with Button and Card.
class GLinkView : public QObject
{
    GRAVITY_ENUM_HOLDER(GLinkView)
public:
    enum Value {
        Normal,
        Primary,
        Secondary,
    };
    Q_ENUM(Value)
};

// PlaceholderContainer's own size ladder: it has no xs/xl, and `promo` is a
// step that exists nowhere else, so it does not share GSize.
class GPlaceholderSize : public QObject
{
    GRAVITY_ENUM_HOLDER(GPlaceholderSize)
public:
    enum Value {
        S,
        M,
        L,
        Promo,
    };
    Q_ENUM(Value)
};

// FilePreview's file kinds. Upstream derives one from the MIME type; here it
// is passed in, because QML has no File object to sniff.
class GFileType : public QObject
{
    GRAVITY_ENUM_HOLDER(GFileType)
public:
    enum Value {
        Default,
        Image,
        Video,
        Code,
        Archive,
        Music,
        Audio,
        Text,
        Pdf,
        Table,
    };
    Q_ENUM(Value)
};

// Skeleton's placeholder animation.
class GAnimation : public QObject
{
    GRAVITY_ENUM_HOLDER(GAnimation)
public:
    enum Value {
        Gradient,
        Pulse,
        None,
    };
    Q_ENUM(Value)
};

#undef GRAVITY_ENUM_HOLDER
