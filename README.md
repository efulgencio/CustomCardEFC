# CustomCardEFC
Card con diferentes presentaciones. El usuario decide que utilizar cuando usa la app.

    /// @AppStorage guarda automáticamente la elección del usuario en UserDefaults.
    /// Esto garantiza que la preferencia de diseño persista incluso si se cierra la app.
    @AppStorage("globalLayout") private var selectedLayout: CardLayout = .classic

![](cardcustom.mov)
