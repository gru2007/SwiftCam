import SwiftUI
import MijickCamera
import AVFoundation

/// Основной экран с ручными настройками камеры
struct ManualCameraView: View {
    var body: some View {
        MCamera()
            .setCameraOutputType(.photo)
            .setFlashMode(.auto)
            .setLightMode(.off)
            .setGridVisibility(true)
            .setFrameRate(30)
            .setCameraScreen(ManualCameraScreen.init)
            .lockCameraInPortraitOrientation(AppDelegate.self)
            .startSession()
    }
}

/// Экран камеры с ручным управлением настройками
struct ManualCameraScreen: MCameraScreen {
    @ObservedObject var cameraManager: CameraManager
    let namespace: Namespace.ID
    let closeMCameraAction: () -> ()

    // Параметры управления
    @State private var iso: Float = 100
    @State private var exposure: Double = 0.01
    @State private var zoom: CGFloat = 1
    @State private var frameRate: Double = 30
    @State private var flashEnabled: Bool = false
    @State private var lightEnabled: Bool = false
    @State private var gridEnabled: Bool = true

    // Диапазоны значений (примерные)
    private let isoRange: ClosedRange<Float> = 50...800
    private let exposureRange: ClosedRange<Double> = 0.001...1
    private let zoomRange: ClosedRange<CGFloat> = 1...5
    private let frameRange: ClosedRange<Double> = 24...60

    var body: some View {
        ZStack {
            // Просмотр камеры
            createCameraOutputView()
                .ignoresSafeArea()

            VStack {
                createTopBar()
                Spacer()
                createControls()
            }
        }
        .onAppear {
            iso = cameraManager.attributes.iso
            exposure = cameraManager.attributes.exposureDuration.seconds
            zoom = cameraManager.attributes.zoomFactor
            frameRate = Double(cameraManager.attributes.frameRate)
            flashEnabled = cameraManager.attributes.flashMode != .off
            lightEnabled = cameraManager.attributes.lightMode != .off
            gridEnabled = cameraManager.attributes.isGridVisible
        }
    }
}

private extension ManualCameraScreen {
    /// Верхняя панель с переключением камеры и настройками вспышки
    func createTopBar() -> some View {
        HStack {
            Button(action: switchCamera) {
                Image(systemName: "arrow.triangle.2.circlepath.camera")
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }
            Spacer()
            Button(action: toggleFlash) {
                Image(systemName: flashEnabled ? "bolt.fill" : "bolt.slash")
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }
            Button(action: toggleLight) {
                Image(systemName: lightEnabled ? "flashlight.on.fill" : "flashlight.off.fill")
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }
        }
        .padding()
    }

    /// Нижняя панель с элементами управления
    func createControls() -> some View {
        VStack(spacing: 12) {
            Slider(value: Binding(get: { iso }, set: { iso = $0; try? setISO($0) }), in: isoRange)
                .tint(.white)
            Text("ISO: \(Int(iso))").foregroundColor(.white)

            Slider(value: Binding(get: { exposure }, set: { exposure = $0; try? setExposureDuration(CMTime(seconds: $0, preferredTimescale: 1000)) }), in: exposureRange)
                .tint(.white)
            Text(String(format: "Выдержка: %.0f мс", exposure * 1000)).foregroundColor(.white)

            Slider(value: Binding(get: { zoom }, set: { zoom = $0; try? setZoomFactor($0) }), in: zoomRange)
                .tint(.white)
            Text(String(format: "Зум: %.1fx", zoom)).foregroundColor(.white)

            Slider(value: Binding(get: { frameRate }, set: { frameRate = $0; try? setFrameRate(Int32($0)) }), in: frameRange, step: 1)
                .tint(.white)
            Text("FPS: \(Int(frameRate))").foregroundColor(.white)

            Toggle("Сетка", isOn: Binding(get: { gridEnabled }, set: { gridEnabled = $0; setGridVisibility($0) }))
                .tint(.white)

            Button(action: captureOutput) {
                Circle().stroke(Color.white, lineWidth: 4).frame(width: 70, height: 70)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(16)
        .padding()
    }

    /// Переключение фронтальной и тыловой камер
    func switchCamera() {
        let newPosition: CameraPosition = cameraPosition == .back ? .front : .back
        Task { try? await setCameraPosition(newPosition) }
    }

    /// Переключение режима вспышки
    func toggleFlash() {
        flashEnabled.toggle()
        setFlashMode(flashEnabled ? .on : .off)
    }

    /// Включение и выключение фонарика
    func toggleLight() {
        lightEnabled.toggle()
        setLightMode(lightEnabled ? .on : .off)
    }
}

#Preview {
    ManualCameraView()
}
