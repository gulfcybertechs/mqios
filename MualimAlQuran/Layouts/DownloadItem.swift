import SwiftUI
import SwiftSoup

struct DownloadItem: View {
    
    @EnvironmentObject var mvm: MainViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var item: DownloadModel
    @Binding var vm: DownloadLayout
    @State var percentageText = ""
    @AppStorage("language") var currentLanguage = getLanguage()
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()    
    
    var body: some View {
                        
        VStack(spacing: 0)
        {
            VStack(spacing: 0) {
                
                Text((getReciterAr(id: item.id) != "") ? getReciterAr(id: item.id) : item.Name)
                    .fontWeight(.bold)
                    .foregroundStyle(colorResource.lightButtonText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer().frame(height: 2)
                
                HStack(spacing: 0) {
                    
                    let reciterID = (item.id == "WordByWord") ? "w" :  item.id
                    let root = (item.id == "English" || item.id == "Swahili" || item.id == "French" || item.id == "Portuguese" || item.id == "Spanish" || item.id == "Russian" || item.id == "German" || item.id == "Hindi" || item.id == "Chinese" || item.id == "Urdu" || item.id == "Bahasa" || item.id == "Bangla" || item.id == "Hausa" || item.id == "Turkish") ? "translation" : "recitation"
                    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(root)/\(reciterID)")
                    
                    var files: [URL] {
                        
                        let fi = try? FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
                        if (fi != nil) {
                            return fi!.filter { $0.pathExtension == "mp3" }
                        }
                        
                        return []
                    }
                    
                    var download: Bool {
                        
                        if (mvm.downloadingItems.contains(where: { $0.id == item.id })) {
                            return false
                        }
                        
                        if (files.count >= 6235) {
                            return false
                        }
                        
                        return true
                    }
                    var cancel: Bool {
                        
                        if (mvm.downloadingItems.contains(where: { $0.id == item.id })) {
                            return true
                        }
                        
                        return false
                    }
                    var clear: Bool {
                        
                        if (mvm.downloadingItems.contains(where: { $0.id == item.id })) {
                            return false
                        }
                        
                        if (files.count > 0) {
                            return true
                        }
                        
                        return false
                    }
                    var percentage: String {
                        
                        if ((Double(files.count) * 100 / 6235) >= 100) {
                            
                            if (mvm.downloadingItems.contains(where: { $0.id == item.id })) {
                                
                                DispatchQueue.main.async {
                                    mvm.downloadingItems.removeAll(where: { $0.id == item.id })
                                }
                            }
                            return "100"
                        }
                                                
                        return String(format: "%.2f", (Double(files.count) * 100 / 6235))
                    }
                    
                    if (download) {
                        
                        Image(systemName: "arrowshape.down.fill")
                            .font(.system(size: 16))
                            .frame(width: 28, height: 28)
                            .foregroundStyle(colorResource.primary_700)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .onTapGesture {
                                mvm.downloadingItems.insert(item, at: 0)
                                
                                Task {
                                    
                                    do {
                                        try await vm.startDownload(reciter: DownloadModel(id: item.id, Name: item.Name))
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                    }
                    
                    if (cancel) {
                        
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .frame(width: 28, height: 28)
                            .foregroundStyle(colorResource.maroon)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .onTapGesture {
                                mvm.downloadingItems.removeAll(where: { $0.id == item.id })
                            }
                    }
                    
                    if (download || cancel) {
                        Spacer().frame(width: 5)
                    }
                    
                    ZStack {
                        
                        ProgressView(value: Float(percentage)!, total: 100)
                            .progressViewStyle(LinearProgressViewStyle())
                            .scaleEffect(x: 1, y: 6)
                        
                        Text("\(percentageText)%")
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                            .padding(4)
                            .onAppear() {
                                percentageText = percentage
                            }
                            .onReceive(timer) { input in
                                percentageText = percentage
                            }
                    }
                    .frame(maxWidth: .infinity)
                    
                    if (cancel) {
                        
                        Spacer().frame(width: 5)
                        ProgressView()
                            .frame(width: 28, height: 28)
                            .tint(colorResource.maroon)
                    }
                    
                    if (clear) {
                        
                        Spacer().frame(width: 5)
                        
                        Image(systemName: "trash.fill")
                            .font(.system(size: 20))
                            .frame(width: 28, height: 28)
                            .foregroundStyle(colorResource.maroon)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .onTapGesture {
                                mvm.deleteFiles(reciter: item.id)
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
        }
        .frame(maxWidth: .infinity)
        .background(Color(hex: "75E6E4BF"))
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .padding(.top, 5)
        .padding(.bottom, 8)
    }
}
