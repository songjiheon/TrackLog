import SwiftUI

struct PlaylistTrackRow: View {
    let track: Track
    let onRemove: () -> Void   // 삭제 콜백
    
    var body: some View {
        HStack(spacing: 15) {
            // 앨범 이미지
            if let imageUrl = track.albumImageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(AppTheme.cardBackground)
                }
                .frame(width: 50, height: 50)
                .cornerRadius(6)
            } else {
                Rectangle()
                    .fill(AppTheme.cardBackground)
                    .frame(width: 50, height: 50)
                    .cornerRadius(6)
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(AppTheme.textTertiary)
                    )
            }
            
            // 곡 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(track.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                
                Text(track.artist)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(1)
                
                Text(track.album)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textTertiary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 삭제 버튼
            Button(action: onRemove) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(10)
    }
}
