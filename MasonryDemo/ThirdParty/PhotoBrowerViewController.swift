//
//  PhotoBrowerViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/6.
//

import UIKit
import ZLPhotoBrowser
import Photos
import AVKit // 引入 AVKit 框架以使用 AVPlayerViewController

class PhotoBrowerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        let picker = ZLPhotoPreviewSheet()
        
        // isOriginal 用户是否已经选中了原图
        
        // ZLResultModel
        picker.selectImageBlock = { [weak self] results, isOriginal in
            for result in results {
                if result.asset.mediaType == .video {
                    print("🎥 这是一个视频")
                    print("视频时长: \(result.asset.duration)秒")
                    
                    // 导出视频到沙盒
                    let options = PHVideoRequestOptions()
                    options.version = .original // 获取原始版本
                    options.isNetworkAccessAllowed = true // 允许从 iCloud 下载
                    
                    PHImageManager.default().requestAVAsset(forVideo: result.asset, options: options) { (avAsset, audioMix, info) in
                        // 注意：回调可能不在主线程
                        
                        if let urlAsset = avAsset as? AVURLAsset {
                            // 1. 获取相册中视频的原始 URL（这个 URL 我们通常没有直接读取权限，或者它是临时的）
                            let sourceURL = urlAsset.url
                            print("原始引用路径: \(sourceURL)")
                            
                            print("--- AVAsset 深度信息 ---")
                            print("时长: \(urlAsset.duration.seconds)秒")
                            
                            // 获取视频轨道信息
                            if let videoTrack = urlAsset.tracks(withMediaType: .video).first {
                                print("分辨率: \(videoTrack.naturalSize)")
                                print("帧率: \(videoTrack.nominalFrameRate) FPS")
                                print("码率: \(videoTrack.estimatedDataRate / 1024 / 1024) Mbps")
                            }
                            
                            // 获取文件大小 (通过 URL 读取文件属性)
                            if let resources = try? sourceURL.resourceValues(forKeys: [.fileSizeKey]),
                               let fileSize = resources.fileSize {
                                print("文件大小: \(Double(fileSize) / 1024 / 1024) MB")
                            }
                            print("-----------------------")
                            
                            // 演示播放视频
                            DispatchQueue.main.async {
                                self?.playVideo(asset: urlAsset)
                            }
                            
                            // 2. 构造沙盒目标路径
                            let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                            let fileName = "exported_video_\(Date().timeIntervalSince1970).mov"
                            let destinationURL = URL(fileURLWithPath: docPath).appendingPathComponent(fileName)
                            
                            // 3. 拷贝文件到沙盒
                            do {
                                // 如果文件已存在，先删除
                                if FileManager.default.fileExists(atPath: destinationURL.path) {
                                    try FileManager.default.removeItem(at: destinationURL)
                                }
                                
                                try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                                
                                DispatchQueue.main.async {
                                    print("✅ 视频已成功保存到沙盒: \(destinationURL.path)")
                                    // 这里可以进行上传、播放等操作
                                }
                            } catch {
                                print("❌ 视频导出失败: \(error)")
                            }
                        }
                    }
                } else if result.asset.mediaType == .image {
                    print("📷 这是一个图片")
                    
                    // 检查子类型
                    if result.asset.mediaSubtypes.contains(.photoLive) {
                        print("✨ 这是一个 Live Photo")
                    }
                    if result.asset.mediaSubtypes.contains(.photoScreenshot) {
                        print("📸 这是一个屏幕截图")
                    }
                    if result.asset.mediaSubtypes.contains(.photoPanorama) {
                        print("🌆 这是一个全景照片")
                    }
                }
                
                print("--- 详细信息 ---")
                print("ID: \(result.asset.localIdentifier)")
                print("尺寸: \(result.asset.pixelWidth) x \(result.asset.pixelHeight)")
                print("创建日期: \(String(describing: result.asset.creationDate))")
                if let location = result.asset.location {
                    print("位置: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                }
                print("是否收藏: \(result.asset.isFavorite)")
                print("----------------")
                
                print("image:\(result.image)")
                print("asset:\(result.asset)")
            }
        }
        picker.showPhotoLibrary(sender: self)

    }
    
    // 简单的播放视频方法
    func playVideo(asset: AVAsset) {
        // 1. 创建播放项 (把带子准备好)
        let playerItem = AVPlayerItem(asset: asset)
        
        // 2. 创建播放器 (录像机)
        let player = AVPlayer(playerItem: playerItem)
        
        // 3. 创建播放控制器 (系统自带的 UI，带进度条和播放按钮)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        // 4. 展示并播放
        self.present(playerViewController, animated: true) {
            player.play()
        }
    }

}
