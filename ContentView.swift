import SwiftUI

/// Vista principal que actúa como el orquestador de la aplicación.
/// Demuestra cómo un único estado global puede transformar toda la interfaz de usuario.
struct ContentView: View {
    
    // MARK: - PERSISTENCIA Y ESTADO
    
    /// @AppStorage guarda automáticamente la elección del usuario en UserDefaults.
    /// Esto garantiza que la preferencia de diseño persista incluso si se cierra la app.
    @AppStorage("globalLayout") private var selectedLayout: CardLayout = .classic
    
    /// @State controla la visibilidad del modal de selección.
    @State private var showSelector = false
    
    // MARK: - FUENTE DE DATOS
    
    /// Array de modelos 'Person'. En una app real, esto podría venir de una API o CoreData.
    let students = [
        Person(name: "Carlos", surname: "Méndez", grades: [8, 9, 10]),
        Person(name: "Lucía", surname: "Vidal", grades: [10, 9, 9.5]),
        Person(name: "Marcos", surname: "Torres", grades: [7, 6, 8])
    ]
    
    var body: some View {
        // NavigationStack: El contenedor moderno para la navegación y títulos en iOS
        NavigationStack {
            
            // LISTA REACTIVA: Se actualiza automáticamente cuando 'selectedLayout' cambia
            List(students) { student in
                
                // COMPONENTE DESACOPLADO: Le pasamos el layout actual.
                // La lógica de "cómo se dibuja" está encapsulada dentro de PersonCardView.
                PersonCardView(person: student, layout: selectedLayout)
                    
                    // ESTILIZACIÓN DE CELDA: Eliminamos los estilos por defecto de la lista
                    // para que los componentes luzcan como tarjetas independientes.
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            .listStyle(.plain) // Estilo limpio sin agrupaciones
            .navigationTitle("Directorio")
            
            // BARRA DE HERRAMIENTAS
            .toolbar {
                Button {
                    showSelector = true // Dispara la apertura del modal
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
            }
            
            // GESTIÓN DE MODALES (SHEETS)
            .sheet(isPresented: $showSelector) {
                
                // COMPATIBILIDAD: Manejo de APIs según la versión de iOS del dispositivo
                if #available(iOS 16.0, *) {
                    LayoutSelectorModal(selectedLayout: $selectedLayout)
                        
                        // Detents: Permite que el modal se abra a media pantalla (UX moderna)
                        .presentationDetents([.medium])
                } else {
                    // Fallback para versiones anteriores de iOS
                    LayoutSelectorModal(selectedLayout: $selectedLayout)
                }
            }
        }
    }
}
