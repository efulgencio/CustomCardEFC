import SwiftUI

// MARK: - 1. MODELO DE DATOS
/// Representa la entidad principal. Implementa 'Identifiable' para que SwiftUI
/// pueda manejar listas (ForEach) de forma eficiente usando el ID único.
struct Person: Identifiable {
    let id = UUID()
    let name: String
    let surname: String
    let grades: [Double] // Array de notas para cálculos dinámicos
    
    // PROPIEDADES COMPUTADAS: Lógica de negocio encapsulada en el modelo.
    // Esto evita cálculos repetitivos en las vistas y facilita el testing.
    
    /// Calcula el promedio de notas. Se asegura de no dividir por cero.
    var average: Double {
        grades.reduce(0, +) / Double(max(1, grades.count))
    }
    
    /// Extrae la nota más alta. Usa nil-coalescing para dar un valor por defecto.
    var maxGrade: Double { grades.max() ?? 0 }
    
    /// Extrae la nota más baja.
    var minGrade: Double { grades.min() ?? 0 }
}

// MARK: - 2. LÓGICA DE DISTRIBUCIÓN (ENUMERACIÓN)
/// Centraliza todos los metadatos de las tarjetas.
/// 'CaseIterable' permite iterar sobre los casos para construir menús o listas automáticamente.
enum CardLayout: String, CaseIterable, Identifiable {
    case classic, horizontal, compact, artistic
    var id: String { self.rawValue }
    
    // Estas propiedades permiten que la UI sea "data-driven":
    // la vista simplemente pregunta al enum qué mostrar.
    
    var title: String {
        switch self {
        case .classic: return "Clásica"
        case .horizontal: return "Horizontal"
        case .compact: return "Compacta"
        case .artistic: return "Dashboard Pro"
        }
    }
    
    var description: String {
        switch self {
        case .classic: return "Vista vertical estándar."
        case .horizontal: return "Optimizado para lectura en fila."
        case .compact: return "Máxima densidad de datos."
        case .artistic: return "Análisis detallado con métricas."
        }
    }
    
    var icon: String {
        switch self {
        case .classic: return "rectangle.portrait.fill"
        case .horizontal: return "rectangle.grid.1x2.fill"
        case .compact: return "list.bullet"
        case .artistic: return "chart.bar.xaxis"
        }
    }
}

// MARK: - 3. COMPONENTE INTELIGENTE (WRAPPER)
/// Actúa como un "Traffic Controller". Su única responsabilidad es decidir
/// qué sub-vista renderizar según el layout seleccionado.
/// Esto desacopla la ContentView de los detalles de implementación de cada tarjeta.
struct PersonCardView: View {
    let person: Person
    let layout: CardLayout
    
    var body: some View {
        switch layout {
        case .classic:    ClassicCard(person: person)
        case .horizontal: HorizontalCard(person: person)
        case .compact:    CompactCard(person: person)
        case .artistic:   ArtisticCard(person: person)
        }
    }
}

// MARK: - 4. MODAL DE SELECCIÓN
/// Vista para elegir el diseño. Demuestra el uso de bindings para modificar
/// estados que residen en una vista superior (ContentView).
struct LayoutSelectorModal: View {
    // Acceso a la acción de cerrar el modal provista por el sistema
    @Environment(\.dismiss) var dismiss
    
    // @Binding: Referencia al estado persistente (@AppStorage) del padre
    @Binding var selectedLayout: CardLayout
    
    var body: some View {
        NavigationStack {
            List(CardLayout.allCases) { layout in
                Button {
                    // Actualiza el estado global y cierra el modal
                    selectedLayout = layout
                    dismiss()
                } label: {
                    HStack(spacing: 15) {
                        Image(systemName: layout.icon)
                            .font(.title2)
                            .foregroundColor(.blue)
                            .frame(width: 35)
                        
                        VStack(alignment: .leading) {
                            Text(layout.title).font(.headline).foregroundColor(.primary)
                            Text(layout.description).font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        // Feedback visual de la opción actualmente seleccionada
                        if selectedLayout == layout {
                            Image(systemName: "checkmark.seal.fill").foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Cambiar Diseño")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - 5. PRESENTACIONES INDIVIDUALES

// ESTILO 1: CLÁSICO
/// Diseño centrado que destaca el nombre y usa una inicial como avatar.
struct ClassicCard: View {
    let person: Person
    var body: some View {
        VStack(spacing: 8) {
            Circle().fill(.blue.opacity(0.1)).frame(width: 40, height: 40)
                .overlay(Text(person.name.prefix(1)).bold().foregroundColor(.blue))
            
            Text("\(person.name) \(person.surname)").font(.headline)
            Text("Promedio: \(person.average, specifier: "%.1f")").font(.subheadline).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity).padding().background(Color(.secondarySystemBackground)).cornerRadius(15)
    }
}

// ESTILO 2: HORIZONTAL
/// Ideal para listas con muchos elementos, aprovechando el ancho de la pantalla.
struct HorizontalCard: View {
    let person: Person
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(person.name).font(.headline)
                Text(person.surname).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            // Formateo de Double a 1 decimal
            Text("\(person.average, specifier: "%.1f")")
                .bold().padding(8).background(Color.blue.opacity(0.1)).cornerRadius(8)
        }
        .padding().background(Color(.secondarySystemBackground)).cornerRadius(12)
    }
}

// ESTILO 3: COMPACTO
/// Mínimo espacio, máximo orden. Usa tipografías pequeñas y formas limpias.
struct CompactCard: View {
    let person: Person
    var body: some View {
        HStack {
            Image(systemName: "person.fill").font(.caption).foregroundColor(.blue)
            Text("\(person.name) \(person.surname)").font(.footnote)
            Spacer()
            Text("\(person.average, specifier: "%.1f")").font(.footnote).bold()
        }
        .padding(10).background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
    }
}

// ESTILO 4: ARTÍSTICO / DASHBOARD PRO
/// El diseño más complejo. Demuestra jerarquía visual, uso de gradientes y métricas avanzadas.
struct ArtisticCard: View {
    let person: Person
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cabecera con Badge dinámico
            HStack {
                VStack(alignment: .leading) {
                    Text("\(person.name) \(person.surname)").font(.headline)
                    Text("RENDIMIENTO ACADÉMICO").font(.system(size: 8, weight: .black)).opacity(0.7)
                }
                Spacer()
                // Lógica visual basada en datos: Cambia el texto según el promedio
                Text(person.average >= 9 ? "TOP" : "PRO")
                    .font(.system(size: 10, weight: .bold)).padding(4).background(.white.opacity(0.2)).cornerRadius(4)
            }
            
            // Visualización de progreso
            VStack(alignment: .leading, spacing: 4) {
                ProgressView(value: person.average, total: 10)
                    .tint(.white)
                    .background(.white.opacity(0.2))
                Text("Promedio: \(person.average, specifier: "%.1f") / 10").font(.caption2).bold()
            }
            
            // Fila de métricas secundarias (Datos calculados en el modelo)
            HStack(spacing: 15) {
                metricRow(label: "MAX", value: person.maxGrade, icon: "arrow.up")
                metricRow(label: "MIN", value: person.minGrade, icon: "arrow.down")
                metricRow(label: "NOTAS", value: Double(person.grades.count), icon: "number")
            }
        }
        .padding().foregroundColor(.white)
        // Fondo impactante con gradiente lineal
        .background(LinearGradient(colors: [Color(red: 0.1, green: 0.2, blue: 0.4), .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(18).shadow(color: .blue.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    /// Función de utilidad para generar filas de métricas consistentes
    func metricRow(label: String, value: Double, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 7, weight: .black)).opacity(0.8)
            HStack(spacing: 2) {
                Image(systemName: icon).font(.system(size: 8))
                Text(String(format: "%.1f", value)).font(.system(size: 12, weight: .bold))
            }
        }
    }
}
