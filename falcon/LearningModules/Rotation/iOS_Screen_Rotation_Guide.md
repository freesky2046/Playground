# iOS 屏幕旋转机制全解：从入门到精通

本文档整理自 iOS 屏幕旋转机制的深入讨论，旨在从底层原理到实战应用，全面解析 iOS 旋转控制逻辑。

---

## 一、核心概念：旋转控制的“三道关卡”

iOS 决定一个页面是否可以旋转，以及支持哪些方向，遵循一套严格的层级过滤机制。你可以把它想象成“过安检”，只有同时通过这三道关卡，旋转才会生效。

### 1. 第一道关卡：Info.plist (出厂设置)
*   **定义**：静态配置，定义了 App 理论上支持的所有方向。
*   **地位**：静态的，若第二道关卡（AppDelegate）没有实现，它就是全局允许方向。
*   **通常配置**：建议勾选所有可能用到的方向（如 Portrait, Landscape Left, Landscape Right）。

### 2. 第二道关卡：AppDelegate (运行时总控)
*   **方法**：`application(_:supportedInterfaceOrientationsFor:)`
*   **定义**：动态配置，可以在 App 运行过程中随时改变全局允许的方向。
*   **逻辑**：**交集运算**。
    > `最终全局允许方向` = `Info.plist` ∩ `AppDelegate返回值`
*   **最佳实践**：理论上说，第二道关卡可以修改（扩展）第一道关卡的值，但 iOS 最佳实践建议我们：**最好让第二道关卡成为第一道关卡的子集**。


### 3. 第三道关卡：ViewController (局部自治)
*   **方法**：`supportedInterfaceOrientations`
*   **定义**：当前页面自己支持的方向。
*   **逻辑**：**再次交集**。
    > `页面最终方向` = `全局允许方向(前两关结果)` **∩** `ViewController返回值`

---

## 二、容器传递机制：不要让中间商赚差价

如果你的 ViewController 被包裹在 `UINavigationController` 或 `UITabBarController` 中，系统只会询问最外层的容器，而不会直接问里面的 VC。

**问题**：默认的 NavigationController 不会理会子页面的旋转设置。
**解决**：必须继承并重写 `shouldAutorotate` 和 `supportedInterfaceOrientations`，将控制权**转发**给当前显示的子页面。

```swift
// BaseNavigationController.swift
override var shouldAutorotate: Bool {
    return topViewController?.shouldAutorotate ?? super.shouldAutorotate
}

override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return topViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
}
```

---

## 三、系统决策逻辑：屏幕到底听谁的？

当你的页面支持多种方向（例如 `.all`）时，系统如何决定显示哪种方向？这遵循一套严格的**“淘汰制”优先级**，从上往下依次判断：

1.  **优先级一（最高）：系统竖屏锁定 (Control Center)**
    *   **判断**：用户开锁了吗？
    *   **是** -> 除非 App 只支持横屏，否则强制竖屏，**结束判断**。
    *   **否** -> 进入下一级。
    
2.  **优先级二：模态首选 (Presentation Preference)**
    *   **判断**：是 `Present` 出来的吗？且实现了 `preferredInterfaceOrientation`？
    *   **是** -> 按你指定的首选方向显示，**结束判断**。
    *   **否** -> 进入下一级。

3.  **优先级三：连贯性 (Continuity)**
    *   **判断**：上一页的方向，当前页支持吗？
    *   **支持** -> 保持上一页方向，不瞎转，**结束判断**。
    *   **不支持** -> 必须转，进入下一级。

4.  **优先级四（保底）：物理重力 (Gravity)**
    *   **判断**：都没被上面拦截？好，那用户怎么拿手机，我就怎么显示。


---

## 四、强制旋转：如何突破限制

当用户锁定了系统竖屏，或者你需要从竖屏页强制跳转到横屏页时，需要使用“强制旋转”。

### 核心原理
1.  **打通关卡**：先修改 AppDelegate，让它临时支持目标方向。
2.  **申请旋转**：调用系统 API 请求旋转。

### 代码实现 (iOS 16+)
```swift
// 1. 临时放开 AppDelegate 限制
(UIApplication.shared.delegate as? AppDelegate)?.orientationLock = .allButUpsideDown

// 2. 告诉系统我要横屏
let mask = UIInterfaceOrientationMask.landscapeRight
let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: mask)
windowScene.requestGeometryUpdate(geometryPreferences) { error in
    // 处理失败情况
}
```

### 限制条件
*   **能突破**：系统控制中心的竖屏锁定（用户锁）。
*   **不能突破**：App 内部的配置（AppDelegate / Info.plist）。如果你不先修改 AppDelegate 的配置，强制旋转请求会被系统驳回。

---

## 五、shouldAutorotate 的深度解析

`shouldAutorotate` 是一个布尔值开关，但它不仅控制“自动旋转”。

### 双重职责
1.  **显性职责：重力感应开关**
    *   `true`: 允许随手机转动而旋转。
    *   `false`: 禁止随手机转动，锁定在当前方向。

2.  **隐性职责：转场适应许可**
    *   **场景**：页面 A (横) -> 跳转 -> 页面 B (竖)。
    *   **逻辑**：如果 B 的 `shouldAutorotate` 是 `false`，系统会认为“你不允许改变方向”，导致 B 被迫以横屏显示（发生错误）。
    *   **结论**：**只要页面流转中涉及方向改变，相关页面的 `shouldAutorotate` 必须为 `true`。**

### 何时设为 false？
只有当你希望用户进入该页面后，**彻底锁定视角**（例如视频全屏锁定、特定游戏关卡），不希望用户躺着玩手机时屏幕乱转，才设为 `false`。此时你依然可以用代码强制旋转它，但重力感应将失效。

---

## 六、总结：旋转配置最佳实践

1.  **Info.plist**: 勾选所有可能支持的方向。
2.  **AppDelegate**: 默认返回 `.portrait` (如果 App 主体是竖屏)，并暴露一个 `orientationLock` 属性供外部临时修改。
3.  **BaseNavigationController**: 必须实现方法转发。
4.  **普通 VC**: 
    *   `shouldAutorotate`: 默认 `true`。
    *   `supportedInterfaceOrientations`: 按需返回 `.portrait` 或 `.all`。
5.  **强横屏 VC (如视频)**:
    *   进入时：修改 AppDelegate lock -> 强制旋转至横屏。
    *   `shouldAutorotate`: 可设为 `false` 以防止用户误触旋转。
    *   退出时：强制旋转回竖屏 -> 恢复 AppDelegate lock。
