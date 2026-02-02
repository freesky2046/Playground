//
//  CacheBasicViewController.swift
//  MasonryDemo
//
//  Created by 周明 on 2026/2/2.
//

import UIKit
import YYCache


class CacheBasicViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        // MARK: - ⚠️ 常用的存储目录
        // Caches: URL对象: 存储最常用的目录
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        // document: URL对象:
        let docsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // tmp 目录:
        let tempURL = FileManager.default.temporaryDirectory
        // library 目录
        let libraryURL = FileManager.default.urls(
            for: .libraryDirectory,
            in: .userDomainMask
        ).first!
        // 见asset
         

        /// ⚠️ Library 和Document是根目录下的文件夹, Caches在Library 目录下,  Caches 和 Documents不平级
        ///
        
        // MARK: - ⚠️ 创建目录
        // 步骤1: 新创建一个完整的路径URL
        let pathURL1 = cachesURL.appendingPathComponent("1") // cache目录下的直接路径名
        let pathURL2 = cachesURL.appendingPathComponent("2.2") // cache目录下的直接路径名,用.分割只是提高可读性,还是一个目录
        let pathURL3 = cachesURL.appendingPathComponent("3/3") //  cache目录下 imgs/name 两级目录, 创建目录的时候withIntermediateDirectories一定要传true

        // 步骤2: 利用FileManager创建, 先判断是否存在,若不存在才创建
        // ⚠️⚠️⚠️ 特别注意 这里URL.path,而不是URL.absoluteString,前者不包括scheme的string
        if !FileManager.default.fileExists(atPath: pathURL1.path) {
            do {
                try FileManager.default.createDirectory(at: pathURL1, withIntermediateDirectories: false)
            } catch {
                print("error:\(error)")
            }
        }
        if !FileManager.default.fileExists(atPath: pathURL2.path) {
            try? FileManager.default.createDirectory(at: pathURL2, withIntermediateDirectories: false)
        }
        if !FileManager.default.fileExists(atPath: pathURL3.path) {
            do {
                try FileManager.default.createDirectory(at: pathURL3, withIntermediateDirectories: true)
            } catch {
                print("error:\(error)")
            }
        }
        
        // 通过什么方式检查
        // 终端 po FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.path 打印目录
        // 使用finder 前往文件夹 找到文件
        
        
        // MARK: - ⚠️ 创建文件
        // 1.创建文件要检查父目录是否存在,存在才能创建 不存在,要先创建目录
        // 2.创建文件前要创建完整的文件的URL
        // 3.最终创建文件给的是path而不是absoluteString或URL
        var isDir: ObjCBool = true
        if FileManager.default.fileExists(atPath: pathURL2.path, isDirectory: &isDir) {
            let img = UIImage(named: "img")?.pngData()!
            // ⚠️,添加后缀方便系统可以识别出什么文件,很有用.表示后缀前后
            let imgPath = pathURL2.appendingPathComponent("img.png")
            // ⚠️ 这里给的是不带scheme的字符串, 不是URL.absoluteString
            FileManager.default.createFile(atPath: imgPath.path, contents: img)
        }
        
        // MARK: - ⚠️ 判断文件或者目录是否存在
        let isExist = FileManager.default.fileExists(atPath: pathURL1.path)
        print("不管它是目录还是文件:\(isExist)")
        
        var isDir2: ObjCBool = true
        let isExist2 = FileManager.default.fileExists(atPath: pathURL1.path, isDirectory: &isDir2)
        print("目录是否存在:\(isExist2)")
        
        let imgPath = pathURL2.appendingPathComponent("img.png")
        var isDir3: ObjCBool = false
        let isExist3 = FileManager.default.fileExists(atPath: imgPath.path, isDirectory: &isDir3)
        print("文件是否存在:\(isExist3)")
        
        // MARK: - ⚠️ 删除文件或者文件夹
        // 1.对于文件:删除文件
        // 2.对于目录:递归删除所有的子文件夹和文件
        try? FileManager.default.removeItem(at: pathURL1)
        try? FileManager.default.removeItem(atPath: pathURL2.path)
        do {
            try FileManager.default.removeItem(atPath: cachesURL.appendingPathComponent("3").path)
        } catch {
            print("E:\(error)")
        }
        
        
        // MARK: - ⚠️ 剪切或者重命名
        // sourceURL:是已有文件的完整路径,不是父目录
        // destURL: 是不存在的文件的完整路径, 不是目的父目录
        // sourceURL和destURL的最后路径可以不同,这样的话还可以改名字
        // sourceURL和destURL若只有最后路径不同就是重命名
        let cachesURL1 = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let sourceURL = cachesURL1.appendingPathComponent("/source") // 要移动的文件或者目录 (不是源文件的父目录), 一定是本身存在的
        var isDir32: ObjCBool = true
        if !FileManager.default.fileExists(atPath: sourceURL.path, isDirectory: &isDir32) {
            try? FileManager.default.createDirectory(at: sourceURL, withIntermediateDirectories: false)
        }
        let docsPath2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destURL = docsPath2.appendingPathComponent("/dest") // 目的文件或者目录(不是目标的父目录), 一定是本身不存在的,可以和原来的目录相同 也可以不同
        do {
            try FileManager.default.moveItem(at: sourceURL, to: destURL)
        } catch {
            print("剪切:\(error)")
        }
        
        // MARK: - ⚠️ 有用的URL方法
        // 获取父目录
        // 对于文件或者文件夹都可以得到父目录
        let cachesURL11 = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let file = cachesURL11.appendingPathComponent("1.jpg")
        let fileParentDir = file.deletingLastPathComponent()
        if fileParentDir == cachesURL11 {
            print("同一个目录")
        }
        
        // 修改和添加后缀
        let file2 = cachesURL11.appendingPathComponent("12")
        let fileeee = file2.appendingPathExtension("jpg")
        print("添加后缀后:file2:\(fileeee)")
        let file3 = cachesURL11.appendingPathComponent("125.jpg")
        let fileggg = file3.deletingPathExtension()
        print("删除后缀后:file2:\(fileggg)")
        
        // MARK: - ⚠️ 时间统计
        // 时间统计
        let time1 = CACurrentMediaTime()
        var result: CGFloat = 0.0
        for i in 1...100000 {
            result += sqrt(Double(i))
        }
        let time2 = CACurrentMediaTime()
        print(time2 - time1)
        
        
        PerformanceMeasurer.measureAndPrint("循环") {
            for i in 1...100000 {
                result += sqrt(Double(i))
            }
        }
    }
}


