# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'MasonryDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  # 基础 UI 布局库
  pod 'SnapKit', '~> 5.7' # Swift 中最流行的自动布局库，替代 NSLayoutConstraint

  # 文本处理库
  pod 'YYText' # 功能强大的富文本处理库，支持图文混排、点击高亮等

  # 网络请求库
  pod 'Alamofire' # Swift 中最流行的网络请求库，支持链式调用和各种网络操作

  # 缓存库
  pod 'YYCache' # 高性能缓存库，支持内存和磁盘缓存
  pod 'Kingfisher' # 专注于图片加载和缓存的库，支持网络图片、缓存管理等
  pod 'Cache' # 轻量级缓存库，提供简单的键值对存储

  ## UI 第三方库
  pod 'ZLPhotoBrowser', '4.5.6' # 类微信系统相册查看器，支持图片选择、预览和编辑
  pod 'YQPhotoBrowser'           # 图片浏览器，类似九宫格的全屏加载效果
  pod 'IQKeyboardManagerSwift'   # 自动处理键盘遮挡问题，无需手动管理
  pod 'lottie-ios'               # 播放复杂动画，支持从 After Effects 导出的 JSON 动画
  pod 'MBProgressHUD'            # 加载中/成功/失败提示，提供简洁的 HUD 显示
  pod 'JXSegmentedView'          # 分段控件，支持多种样式和动画效果
  pod 'JXPagingView/Paging'      # 分页视图，支持列表分页和多种切换效果
  pod 'DZNEmptyDataSet'          # 空状态、无网络、错误页面显示库，支持 UITableView 和 UICollectionView
#  pod 'FDFullscreenPopGesture'  # 全屏侧滑返回, 已经用 MDFullscreenPopGesture实现


  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        end
      end
    end
  end

end
