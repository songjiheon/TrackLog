import SwiftUI

// 플레이 리스트 생성 뷰
struct PlaylistCreateView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var isPublic: Bool = false
    
    let onCreate: (String, String?, Bool) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                Form {
                    Section(header: Text("플레이리스트 정보")
                        .foregroundColor(AppTheme.textSecondary)) {
                        
                        ZStack(alignment: .leading) {
                            if name.isEmpty {
                                Text("이름")
                                    .foregroundColor(AppTheme.textTertiary)
                            }
                            TextField("", text: $name)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        ZStack(alignment: .leading) {
                            if description.isEmpty {
                                Text("설명 (선택)")
                                    .foregroundColor(AppTheme.textTertiary)
                            }
                            TextField("", text: $description)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        
                        Toggle("공개", isOn: $isPublic)
                            .foregroundColor(AppTheme.textPrimary)
                            .tint(AppTheme.primary)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("플레이리스트 만들기")
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
                    Button("완료") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        onCreate(
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
