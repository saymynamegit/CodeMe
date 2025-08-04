import SwiftUI
import PhotosUI
import StoreKit

// MARK: Save image Sheet

struct Cowgyqtqirrec: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    
    
    @Binding var showSaveSheet: Bool
    
    let originalUIImage: UIImage
    
    let removedBgImage: UIImage
    
    let nywdcsziuc = UIImpactFeedbackGenerator(style: .light)
    @Binding var saveButtonPressed: Bool
    @Binding var showAccessAlert: Bool
    @State private var showShareSheet = false
    @State private var imageToShare: URL?
    let strokeWidth: CGFloat
    let strokeColor: Color?
    let backgroundImage: Image?
    
    let pglr: UIImage
    
    
    let cqok: Color?
    let paths: [Nsqwalsj]
    let actualImageSize: CGSize
    let urrentPath: Nsqwalsj?
    
    @Binding var isJPEGSelected: Bool
    
    @State private var pngSizeString: String = "Calculating..."
    @State private var jpegSizeString: String = "Calculating..."
    @State private var calculationTask: Task<Void, Never>?
    
    
    @Binding var isSavingImage: Bool
    
    let renderImage: (_ size: CGSize, _ completion: @escaping (UIImage?) -> Void) -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                
                VStack() {
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            nywdcsziuc.impactOccurred()
                            showSaveSheet = false
                        }) {
                            Image(.close)
                                .renderingMode(.template)
                                .foregroundColor(Color.hksvy)
                                .frame(width: 24, height: 24)
                        }
                        .offset(x: -10, y: 20)
                    }
                    
                    Text( "Save")
                        .xmjsmo(.rmlcgfpiqbli(color: Color.zdi))
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    VStack(spacing: 12) {
                        formatOption(
                            title: "JPEG",
                            description: "Smaller file size. Transparent\nbackground is not supported.",
                            sizeString: jpegSizeString,
                            selected: isJPEGSelected
                        ) {
                            isJPEGSelected = true
                        }
                        
                        Divider()
                        
                        formatOption(
                            title: "PNG",
                            description: "Higher file size. Transparent\nbackground is supported.",
                            sizeString: pngSizeString,
                            selected: !isJPEGSelected
                        ) {
                            isJPEGSelected = false
                        }
                        
                        Divider()
                    }
                    .onAppear {
                        calculateBothSizes()
                    }
                    .onChange(of: isJPEGSelected) { _ in
                        // Only recalculate if we don't have the sizes yet
                        if (isJPEGSelected && jpegSizeString == "Calculating...") ||
                            (!isJPEGSelected && pngSizeString == "Calculating...") {
                            calculateBothSizes()
                        }
                    }
                    .onDisappear {
                        calculationTask?.cancel()
                    }
                    
                    
                    HStack {
                        Text("File size")
                            .xmjsmo(.tklpkdbmhruh(color: Color.gray))
                        
                        Spacer()
                        
                        Text("\(isJPEGSelected ? jpegSizeString : pngSizeString)")
                            .xmjsmo(.qimvxhrkcaz(color: Color.zdi))
                            .foregroundColor(Color.zdi)
                            .animation(.easeInOut, value: isJPEGSelected)
                    }
                    .padding(.horizontal)
                }
                .padding(10)
                .cornerRadius(20, wpmukbx: [.topLeft, .topRight])
                
                HStack(spacing: 12) {
                    Button(action: {
                        nywdcsziuc.impactOccurred()
                        prepareForSharing()
                    }) {
                        HStack {
                            Image(.ukaituimw)
                            Text("Share")
                        }
                        .xmjsmo(.iseyni(color: Color.trznvuo))
                        .padding()
                        .frame(width: 125)
                        .background(Color.itlbv)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        nywdcsziuc.impactOccurred()
                        requestPhotoLibraryAccess()
                        
                    }) {
                        HStack {
                            Image(.jqzyvwgbvc)
                            Text( "Save")
                        }
                        .xmjsmo(.iseyni(color: Color.trznvuo))
                        .padding()
                        .frame(width: 217)
                        .background(Color.gzayp)
                        .cornerRadius(10)
                        .gkdw(color: Color.bjfbafoi, radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.top, 8)
                
                Spacer()
            }
        }
        
        .onChange(of: imageToShare) { value in
            if value != nil {
                showShareSheet = true
            }
        }
        .onAppear {
            nywdcsziuc.prepare()
        }
        .sheet(isPresented: $showShareSheet) {
            if let ckpyqg = imageToShare {
                ShareSheet(items: [ckpyqg], isJPEG: isJPEGSelected) // Pass the format
            } else {
                Text("Image not found or generated.")
            }
        }
    }
    
    
    private func formatOption(
        title: String,
        description: String,
        sizeString: String,
        selected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        // Your formatOption implementation here
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .xmjsmo(.qimvxhrkcaz(color: Color.trznvuo))
                    Text(description)
                        .xmjsmo(.ioibd(color: Color.seyoqnymjbswa))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.zwtjfhoowdynuq)
                        .frame(width: 20, height: 20)
                    Circle()
                        .fill(selected ? Color.bjfbafoi : Color.itlbv)
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.gzayp, lineWidth: selected ? 1 : 0)
            )
        }
        .buttonStyle(.plain)
    }
    
    
    // MARK: Save image functions
    private func saveImage() {
        isSavingImage = true
        Task {
            // 1. Prepare all image components
            guard let originalData = pglr.pngData() else { return }
            
            // 2. Process in parallel
            async let originalProcessing = processImageData(originalData, type: .original)
            async let backgroundProcessing = processBackgroundImage()
            async let renderedProcessing = renderFinalImage()
            async let removedBgProcessing = processRemovedBackgroundImage()
            
            
            let imageForPrewiew = await compressedImage(from: renderedProcessing ?? pglr, maxSize: CGSize(width: 100, height: 100))
            
            
            // 3. Wait for all processing
            let (originalResult, backgroundResult, renderedResult, removedBgResult) = await (
                originalProcessing, backgroundProcessing, renderedProcessing, removedBgProcessing
            )
            
            // 4. Generate UUID for this save operation
            let newImageUUID = UUID()
            
            // 5. Save all image components
            if let renderedImage = renderedResult {
                _ = ImageFileManager.shared.saveImage(renderedImage, with: newImageUUID, type: .main, asJPEG: isJPEGSelected)
            }
            
            if let originalImage = originalResult {
                _ = ImageFileManager.shared.saveImage(originalImage, with: newImageUUID, type: .original)
            }
            
            if let backgroundImage = backgroundResult {
                _ = ImageFileManager.shared.saveImage(backgroundImage, with: newImageUUID, type: .background)
            }
            
            if let removedBgImage = removedBgResult {
                // Ensure we save as PNG by converting if needed
                let imageToSave: UIImage
                if let pngData = removedBgImage.pngData(),
                   let pngImage = UIImage(data: pngData) {
                    imageToSave = pngImage
                } else {
                    imageToSave = removedBgImage
                }
                _ = ImageFileManager.shared.saveImage(imageToSave, with: newImageUUID, type: .removedBg)
            }
            
            if let imageForPrewiew = imageForPrewiew {
                _ = ImageFileManager.shared.saveImage(imageForPrewiew, with: newImageUUID, type: .imageForPrewiew)
            }
            
            // 6. Save metadata to Core Data
            saveMetadata(uuid: newImageUUID)
            
            // 7. Update UI
            await MainActor.run {
                if let renderedImage = renderedResult {
                    // Convert to selected format before saving
                    let imageToSave: UIImage
                    if isJPEGSelected {
                        if let jpegData = renderedImage.jpegData(compressionQuality: 0.8),
                           let jpegImage = UIImage(data: jpegData) {
                            imageToSave = jpegImage
                        } else {
                            imageToSave = renderedImage // fallback
                        }
                    } else {
                        if let pngData = renderedImage.pngData(),
                           let pngImage = UIImage(data: pngData) {
                            imageToSave = pngImage
                        } else {
                            imageToSave = renderedImage // fallback
                        }
                    }
                    self.saveImageToPhotos(imageToSave)
                }
                
                
                self.requestStoreReview()
                
            }
            isSavingImage = false
            
            saveButtonPressed = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                saveButtonPressed = false
            }
        }
        
    }
    
    // Add this new processing function
    private func processRemovedBackgroundImage() async -> UIImage? {
        return await withCheckedContinuation { continuation in
            // Generate the removed background image
            let removedBgImage = self.renderUIImage(with: pglr.size, originalImageSize: self.actualImageSize) ?? self.removedBgImage
            
            // Convert to PNG format to maintain transparency
            if let pngData = removedBgImage.pngData(),
               let pngImage = UIImage(data: pngData) {
                continuation.resume(returning: pngImage)
            } else {
                // Fallback to original if PNG conversion fails
                continuation.resume(returning: removedBgImage)
            }
        }
    }
    
    // Helper to process any image data
    private func processImageData(_ data: Data, type: ImageFileManager.ImageType) async -> UIImage? {
        let targetSize = CGSize(width: 500, height: 500)
        return await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                let result = downsample(imageData: data, to: targetSize)
                continuation.resume(returning: result)
            }
        }
    }
    
    // Process the background view into an image
    private func processBackgroundImage() async -> UIImage? {
        let renderer = ImageRenderer(content: self.backgroundImage)
        guard let bgImage = renderer.uiImage,
              let bgData = bgImage.pngData() else { return nil }
        
        return await processImageData(bgData, type: .background)
    }
    
    // Render the final composite image
    private func renderFinalImage() async -> UIImage? {
        
        return await withCheckedContinuation { continuation in
            self.renderImage(pglr.size) { renderedImage in
                continuation.resume(returning: renderedImage)
            }
        }
    }
    
    // Save Core Data metadata
    @MainActor
    private func saveMetadata(uuid: UUID) {
        let newEditedImage = EditedImage(context: viewContext)
        newEditedImage.uuid = uuid
        newEditedImage.date = Date()
        
        newEditedImage.strokeWidthValue = self.strokeWidth
        newEditedImage.strokeColorHex = self.strokeColor?.tlsjvgeu()
        newEditedImage.backgroundColorHex = self.cqok?.tlsjvgeu()
        newEditedImage.isPNG = !self.isJPEGSelected
        
        if let paths = try? JSONEncoder().encode(self.strokeWidth) {
            newEditedImage.pathsData = paths
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to save Core Data context: \(error)")
        }
    }
    
    
    private func requestPhotoLibraryAccess() {
        
        
        showSaveSheet = false
        
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        saveImage()
                    }
                case .denied, .restricted:
                    withAnimation { showAccessAlert = true }
                case .notDetermined:
                    withAnimation { showAccessAlert = true }
                @unknown default:
                    break
                }
            }
        }
    }
    
    // MARK: Render Image
    
    private func renderUIImage(
        with exportSize: CGSize,
        originalImageSize: CGSize
    ) -> UIImage? {
        
        let fwdgvcagioz = self.actualImageSize
        
        let scaleX = exportSize.width / fwdgvcagioz.width
        let bibl = exportSize.height / fwdgvcagioz.height
        
        let qgcqjclywbjdu = CGAffineTransform(scaleX: scaleX, y: bibl)
        var szdfgofla = qgcqjclywbjdu
        
        let odnxylimqj = paths.map { path -> Nsqwalsj in
            var mrcwfl = path
            if let scaledCGPath = path.adjaiesjnj.copy(using: &szdfgofla) {
                mrcwfl.adjaiesjnj = scaledCGPath
            }
            return mrcwfl
        }
        
        var ckwfg: Nsqwalsj?
        if let xofbeg = urrentPath,
           let scaledCGPath = xofbeg.adjaiesjnj.copy(using: &szdfgofla) {
            var mrcwfl = xofbeg
            mrcwfl.adjaiesjnj = scaledCGPath
            ckwfg = mrcwfl
        }
        
        let goibev = ImageRenderer(content:
                                    ZStack {
            
            Image(uiImage: removedBgImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: exportSize.width, height: exportSize.height)
                .mask(
                    Canvas { context, _ in
                        context.fill(Path(CGRect(origin: .zero, size: exportSize)), with: .color(.white))
                        for path in odnxylimqj where path.mpcd {
                            context.blendMode = .clear
                            context.fill(Path(path.adjaiesjnj), with: .color(.black))
                        }
                        if let current = ckwfg, current.mpcd {
                            context.blendMode = .clear
                            context.fill(Path(current.adjaiesjnj), with: .color(.black))
                        }
                    }
                )
            
            Image(uiImage: pglr)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: exportSize.width, height: exportSize.height)
                .mask(
                    Canvas { context, _ in
                        for path in odnxylimqj {
                            if path.mpcd {
                                context.blendMode = .clear
                                context.fill(Path(path.adjaiesjnj), with: .color(.black))
                            } else {
                                context.blendMode = .normal
                                context.fill(Path(path.adjaiesjnj), with: .color(.white))
                            }
                        }
                        if let current = ckwfg {
                            if current.mpcd {
                                context.blendMode = .clear
                                context.fill(Path(current.adjaiesjnj), with: .color(.black))
                            } else {
                                context.blendMode = .normal
                                context.fill(Path(current.adjaiesjnj), with: .color(.white))
                            }
                        }
                    }
                )
        }
        )
        
        return goibev.uiImage
    }
    
    private func requestStoreReview() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if Azvgtfcpetran.shared.bfxfgq {
                if let scene = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first(where: { $0.activationState == .foregroundActive }) {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
    }
    
    private func prepareForSharing() {
        renderImage(originalUIImage.size) { renderedImage in
            DispatchQueue.main.async {
                guard let renderedImage = renderedImage else { return }
                
                // 📦 Convert to Data
                let originalData: Data?
                if isJPEGSelected {
                    originalData = renderedImage.jpegData(compressionQuality: 0.8)
                } else {
                    originalData = renderedImage.pngData()
                }
                
                // 🧊 Downsample
                let downsampledImage = originalData.flatMap {
                    downsample(imageData: $0, to: CGSize(width: 500, height: 500))
                }
                
                guard let downsampledUIImage = downsampledImage else { return }
                
                // 💾 Save
                let uuid = UUID()
                _ = ImageFileManager.shared.saveImage(downsampledUIImage, with: uuid, type: .main, asJPEG: isJPEGSelected)
                
                guard let imageURL = ImageFileManager.shared.getLinkToImage(with: uuid, type: .main, asJPEG: isJPEGSelected) else {
                    return
                }
                
                // ✅ Ready to share
                imageToShare = imageURL
            }
        }
    }
    
    
    
    private func calculateBothSizes() {
        // Cancel any existing calculation
        calculationTask?.cancel()
        
        calculationTask = Task {
            await withTaskGroup(of: Void.self) { group in
                // Calculate JPEG size if needed
                if jpegSizeString == "Calculating..." {
                    group.addTask {
                        let size = await calculateImageSize(isJPEG: true, compressionQuality: 1.0)
                        await MainActor.run {
                            if !Task.isCancelled {
                                jpegSizeString = "≈ \(size)"
                            }
                        }
                    }
                }
                
                // Calculate PNG size if needed
                if pngSizeString == "Calculating..." {
                    group.addTask {
                        let size = await calculateImageSize(isJPEG: false, compressionQuality: 1.0)
                        await MainActor.run {
                            if !Task.isCancelled {
                                pngSizeString = "≈ \(size)"
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Your existing calculateImageSize function - DO NOT CHANGE
    func calculateImageSize(isJPEG: Bool, compressionQuality: CGFloat = 1.0) async -> String {
        // 1. Get the rendered image
        guard let renderedImage = await withCheckedContinuation({ continuation in
            renderImage(originalUIImage.size) { image in
                continuation.resume(returning: image)
            }
        }) else {
            return "Render failed"
        }
        
        // 2. Downsample the rendered image
        let downsampledImage: UIImage? = {
            // Use PNG for intermediate downsampling to avoid early JPEG artifacts
            guard let pngData = renderedImage.pngData() else { return nil }
            return downsample(imageData: pngData, to: CGSize(width: 500, height: 500))
        }()
        
        guard let downsampledImage = downsampledImage else {
            return "Downsample failed"
        }
        
        // 3. Apply FINAL compression (JPEG/PNG) only once
        let finalData: Data?
        if isJPEG {
            // For JPEG, we need to generate the actual compressed data to get accurate size
            finalData = downsampledImage.jpegData(compressionQuality: compressionQuality)
        } else {
            // For PNG, we can use the PNG data directly
            finalData = downsampledImage.pngData()
        }
        
        guard let finalData = finalData else {
            return "Compression failed"
        }
        
        // 4. Calculate size in MB with more precise measurement
        let sizeInBytes = finalData.count
        let sizeInMB = Double(sizeInBytes) / 1_048_576.0
        
        // Additional debug information if needed
        let format = isJPEG ? "JPEG" : "PNG"
        let qualityInfo = isJPEG ? " (quality: \(compressionQuality))" : ""
        print("Final image size - Format: \(format)\(qualityInfo), Size: \(sizeInBytes) bytes")
        
        return String(format: "%.2f MB", sizeInMB)
    }
    
    private func saveImageToPhotos(_ image: UIImage) {
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error saving image: \(error.localizedDescription)")
                }
            }
        }
    }
    
}


struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    var isJPEG: Bool // Add this parameter
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Convert images to the correct format before sharing
        let formattedItems = items.compactMap { item -> Any in
            if let image = item as? UIImage {
                return isJPEG ?
                image.jpegData(compressionQuality: 0.8) as Any :
                image.pngData() as Any
            }
            return item
        }
        
        return UIActivityViewController(
            activityItems: formattedItems,
            applicationActivities: nil
        )
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
