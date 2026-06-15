import A11yContractCore
import A11yContractSwiftUI
import SwiftUI

struct SwiftUIDemoView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("SwiftUI com contrato explícito")
                    .font(.headline)

                Button(action: {}) {
                    Label("Excluir item", systemImage: "trash")
                }
                .a11yContract(
                    A11ySpec(
                        id: "delete_button",
                        label: "Excluir item",
                        hint: "Remove este item da lista",
                        role: .button,
                        wcag: [.nameRoleValue, .targetSize]
                    )
                )

                Button(action: {}) {
                    Image(systemName: "heart")
                        .font(.title2)
                }
                .a11yContract(
                    A11ySpec(
                        id: "favorite_button",
                        label: "Favoritar",
                        role: .button
                    )
                )

                Text("Sem introspecção profunda: use .a11yContract e valide via registry em testes.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
            .navigationTitle("SwiftUI")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
