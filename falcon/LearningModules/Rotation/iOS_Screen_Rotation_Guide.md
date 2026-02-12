## 七、进阶：setNeedsUpdateOfSupportedInterfaceOrientations 到底有没有用？

这是一个非常敏锐的问题。

`setNeedsUpdateOfSupportedInterfaceOrientations()` 的作用是**通知系统：“我的旋转偏好变了，请重新问我一次”**。

### 1. 在“强制旋转”流程中 (Forced Rotation)
**结论：确实可以省略。**
*   当你调用 `requestGeometryUpdate` (或 KVC `orientation`) 时，这是一个非常强烈的信号。系统在处理这个请求时，自然会去检查新的方向是否被允许。
*   所以，只要你先改了 AppDelegate 的锁，再调用强制旋转，系统就能顺畅地完成旋转，不需要额外调用 `setNeedsUpdate...`。

### 2. 在“被动旋转”流程中 (Passive Rotation)
**结论：非常有用，甚至必须。**
*   **场景**：你不想强制用户横屏，但想**解锁**横屏权限。
    *   比如：进入某个页面，你修改了 AppDelegate `orientationLock = .all`。
    *   此时手机已经是横着的，但屏幕可能还保持竖屏（因为系统不知道你偷偷改了锁）。
*   **作用**：此时调用 `setNeedsUpdateOfSupportedInterfaceOrientations`，系统会立即重新查询方向支持，发现“哦，现在允许横屏了”，于是如果手机是横着的，屏幕就会立刻转过去。
*   如果不调用，可能需要用户稍微晃动一下手机，系统才会触发新的检查。

### 3. 能突破系统竖屏锁定吗？
**结论：不能。**
*   这是它最致命的弱点。
*   如果用户在控制中心打开了“竖屏锁定”，即使你调用了 `setNeedsUpdate...` 并且你的代码返回了支持横屏，**系统依然会无视你**，保持竖屏。
*   **对比**：只有 `requestGeometryUpdate` (强制旋转 API) 才能拥有“特权”，无视系统锁直接转过去。
