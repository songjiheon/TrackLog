import SwiftUI

// 플레이 리스트 수정 뷰
struct PlaylistEditView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var description: String
    @State private var isPublic: Bool
    
    let onSave: (String, String?, Bool) -> Void
    
    init(playlist: PlaylistDetail, onSave: @escaping (String, String?, Bool) -> Void) {
        self._name = State(initialValue: playlist.name)
        self._description = State(initialValue: playlist.description ?? "")
        self._isPublic = State(initialValue: playlist.isPublic)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                Form {
                    Section(header: Text("플레이리스트 정보")
                        .foregroundColor(AppTheme.textSecondary)) {
                        TextField("이름", text: $name)
                            .foregroundColor(AppTheme.textPrimary)
                        TextField("설명 (선택)", text: $description)
                            .foregroundColor(AppTheme.textPrimary)
                        Toggle("공개", isOn: $isPublic)
                            .foregroundColor(AppTheme.textPrimary)
                            .tint(AppTheme.primary)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("플레이리스트 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        onSave(
                            trimmed,
                            description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description,
                            isPublic
                        )
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primary)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
