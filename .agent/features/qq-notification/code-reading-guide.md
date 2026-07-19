# QQ 通知插件 — 代码阅读指南

## 推荐阅读顺序（由外到内，逐层深入）

```
第 1 层：入口 & 配置（了解"有什么"）
  1. src-tauri/src/plugin/mod.rs       — 第 0 步：Plugin trait 接口定义，看别的插件怎么写的
  2. src-tauri/src/lib.rs              — 第 0 步：Tauri 命令注册、状态注入、setup 流程
  3. src/components/QQNotificationSettings.vue — 第 0 步：前端长什么样

第 2 层：核心数据结构（理解"存什么"）
  4. src-tauri/src/plugin/qq_notification.rs  — 第 1 部分：struct 定义区
     · QQSharedState
     · QQPluginHandle  
     · QQNotificationPlugin
     · QQNotificationConfig
     · QqMessageRecord
     · OneBotMessageEvent / OneBotEnvelope

第 3 层：WebSocket 连接处理（理解"怎么通信"）
  5. src-tauri/src/plugin/qq_notification.rs  — 第 2 部分：handle_connection()
  6. src-tauri/src/plugin/qq_notification.rs  — 第 3 部分：handle_received_message()

第 4 层：mpsc 桥接 & 命令（理解"怎么控制"）
  7. src-tauri/src/plugin/qq_notification.rs  — 第 4 部分：QQPluginHandle 方法
     · try_send_action()
     · start_server() / stop_server()
     · get_messages() / has_connection()
  8. src-tauri/src/lib.rs              — send_qq_message / get_qq_messages 命令实现

第 5 层：前后端交互（理解"怎么展示"）
  9. src/views/ReminderToast.vue       — Toast 桌面通知系统
  10. src/components/ToastCard.vue      — Toast 卡片组件
  11. src-tauri/src/reminder_toast.rs   — Toast Rust 端

第 6 层：设计文档
  12. .agent/features/qq-notification/architecture.md — 系统架构图
```

---

## 代码执行流程图

### 流程图 1：应用启动 → QQ 插件初始化

```
main.rs
  │
  └─► lib.rs::run()
        │
        ├─► PluginManager::new()
        │     │
        │     └─► init(db)
        │           │
        │           ├─► ReminderPlugin::on_init()    ← 久坐提醒占位
        │           ├─► TimerPlugin::on_init()       ← 定时提醒占位
        │           ├─► AgentNotificationPlugin::on_init()
        │           ├─► EyePlugin::on_init()
        │           │
        │           └─► QQNotificationPlugin::new()    ★ 从这里开始
        │                 │
        │                 ├─ QQSharedState::new()
        │                 │   ├─ senders: Arc<Mutex<Vec>>   → 空列表
        │                 │   ├─ messages: Arc<Mutex<VecDeque>>
        │                 │   ├─ app_handle: None
        │                 │   └─ reminder_store: None
        │                 │
        │                 ├─ QQNotificationConfig::default()
        │                 │   ├─ ws_port: 23459
        │                 │   ├─ access_token: ""
        │                 │   └─ napcat_webui_url: "http://127.0.0.1:6099"
        │                 │
        │                 └─ QQPluginHandle::new(shared, config, shutdown)
        │                     → 返回 (plugin, handle) 元组
        │
        │   ┌─ PluginManager.qq_handle = Some(handle)  ← 存起来
        │   └─ QQNotificationPlugin.on_init(db)
        │         │
        │         ├─ db.get_plugin_config("qq-notification")
        │         │   → 恢复用户之前保存的配置（端口、token）
        │         │
        │         └─ if db.get_plugin_enabled("qq-notification")
        │               → handle.start_server()    ← 用户上次开了插件
        │
        ├─► inject_tauri_resources(app_handle, reminder_store)
        │     └─► QQPluginHandle.inject_tauri_resources()
        │            ├─ self.shared.app_handle = Some(app_handle)
        │            └─ self.shared.reminder_store = Some(store)
        │               ↑ 现在可以发 Toast 了
        │
        └─► app.manage(handle)  ← 注册为 Tauri 状态
              → 此后所有 #[tauri::command] 都能通过
                State<'_, Arc<QQPluginHandle>> 注入获取
```

### 流程图 2：用户打开开关 → WebSocket 服务启动

```
前端 Plugins.vue
  │
  │  用户点击 QQ 通知的 toggle 开关
  │
  ├─► plugin.enabled = !plugin.enabled    ← 前端本地状态翻转
  │
  └─► (用户点"应用设置"按钮)
        │
        invoke("toggle_plugin", {pluginId:"qq-notification", enabled:true})
          │
          ▼
        lib.rs::toggle_plugin()
          │
          ├─► db.set_plugin_enabled("qq-notification", true)  ← 写入 SQLite
          │
          └─► plugin.on_enable(db)
                │
                └─► QQNotificationPlugin.on_enable()
                      │
                      ├─ self.enabled.store(true)
                      │
                      └─► self.handle.start_server()
                            │
                            ├─► stop_server()  ← 先停旧的（如果存在）
                            │     └─ shutdown_tx.send(())
                            │         → listener 循环收到 shutdown_rx
                            │         → break → listener 线程退出
                            │
                            ├─► 创建 oneshot shutdown channel
                            │     shutdown_tx 存到 plugin_shutdown
                            │
                            ├─► tokio::spawn(async move {
                            │       │
                            │       ├─ TcpListener::bind("127.0.0.1:23459")
                            │       │   → 端口绑定成功
                            │       │   → log: "WebSocket server listening on ws://..."
                            │       │
                            │       └─ loop {
                            │             tokio::select! {
                            │               │
                            │               │ ① 等待新连接
                            │               result = listener.accept() → {
                            │                 tokio::spawn(handle_connection(stream))
                            │                 → 见流程图 3
                            │               }
                            │               │
                            │               │ ② 等待关闭信号
                            │               _ = shutdown_rx → break
                            │             }
                            │           }
                            │     })
                            │
                            └─ 返回（listener 在后台运行）
```

### 流程图 3：NapCat 连接 → 消息循环

```
handle_connection(stream, peer, senders, messages, app_handle, reminder_store)
│
├─► accept_async(stream)  ← WebSocket 握手升级
│     → ws_stream: WebSocketStream<TcpStream>
│
├─► ws_stream.split()
│     → (write, read): (SplitSink, SplitStream)
│
├─► mpsc::unbounded_channel::<String>()
│     → (tx, rx): (UnboundedSender, UnboundedReceiver)
│
├─► senders.lock().push(tx)
│     → 注册到全局发送列表，Tauri 命令通过它发消息
│
├─► log: "NapCat connected from 127.0.0.1:xxxxx"
│
└─► loop {
       tokio::select! {
         │
         │  ═══ 分支 A：收到 NapCat 消息 ═══
         │
         msg_result = read.next() → {
           │
           ├─ Message::Text(text) → {
           │    │
           │    │  解析 JSON → OneBotEnvelope
           │    │
           │    ├─ post_type == "meta_event"
           │    │   └─ meta_event_type == "lifecycle"
           │    │       → 回复 ack: {"action":".handle_lifecycle",...}
           │    │
           │    ├─ post_type == "message"    ★ 核心分支
           │    │   └─► handle_received_message()
           │    │        → 见流程图 4
           │    │
           │    ├─ post_type == "notice"
           │    │   → log_info!("notice from ...")   ← 暂不处理
           │    │
           │    └─ post_type == "request"
           │        → log_info!("request from ...")  ← 暂不处理
           │   }
           │
           ├─ Message::Ping(data)
           │   → write.send(Pong(data))   ← 保活
           │
           ├─ Message::Close(_)
           │   → log: "disconnected"
           │   → break   ← 退出循环
           │
           └─ Message::Pong(_)
               → 忽略
         }
         │
         │  ═══ 分支 B：来自前端的发送命令 ═══
         │
         send_json = rx.recv() → {
           │
           ├─ Some(json) → {
           │    │ 例: {"action":"send_private_msg","params":...}
           │    │
           │    └─ write.send(Message::Text(json))
           │        → NapCat 收到 → 发送 QQ 消息
           │  }
           │
           └─ None
               → break   ← mpsc 通道关闭（插件被禁用）
         }
       }
     }
     │
     │  ← loop 退出（连接断开或通道关闭）
     │
     ├─► senders.lock().retain(|s| !s.is_closed())
     │     → 清理已断开的 sender
     │
     └─► log: "connection handler exiting"
```

### 流程图 4：收到 QQ 消息 → Toast + 缓冲区

```
handle_received_message(msg, messages, app_handle, reminder_store)
│
├─► 提取发送者名称
│     msg.sender.card → msg.sender.nickname → "unknown"
│
├─► 提取消息内容
│     msg.raw_message → "<非文本消息>"
│
├─► 构建 QqMessageRecord
│     {
│       message_id: msg.message_id,
│       timestamp: msg.time,
│       message_type: "private" | "group",
│       sender_uid: msg.user_id,
│       sender_name: "小明",
│       group_id: Some(群号) | None,
│       content: "你好"
│     }
│
├─► 写入环形缓冲区
│     messages.lock().await
│       → if len >= 100 { pop_front() }  ← 淘汰最旧
│       → push_back(record)
│
├─► 构建 Toast 标题
│     "private" → "QQ 私聊 - 小明"
│     "group"   → "QQ 群聊 - 123456789"
│
├─► 截断过长内容（>200 字符 → "..." ）
│
├─► 发送桌面 Toast
│     app_handle.lock() → 获取 AppHandle
│     reminder_store.lock() → 获取 ReminderWindowStore
│       → reminder_toast::create_toast_window(
│             &app_handle, 0,
│             &title, &body, "qq-message", &store
│           )
│           │
│           ├─► store.lock().insert("reminder-toast", data)
│           │     → 写入共享 HashMap，前端冷启动时读取
│           │
│           └─► tauri::async_runtime::spawn {
│                  │
│                  ├─ 如果 toast 窗口已存在
│                  │   → window.eval("window.addToastNotification({...})")
│                  │   → show_reminder_no_activate() ← 不抢焦点显示
│                  │
│                  └─ 如果 toast 窗口不存在（兜底）
│                      → 新建透明 WebviewWindow
│                      → position_toast_window()  ← 右下角
│                  }
│
└─► 写日志
      log_info!("qq", "[私聊] 小明 (uid=10086): 你好")
```

### 流程图 5：前端发送测试消息 → NapCat

```
QQNotificationSettings.vue
│
│  用户: 目标类型=私聊, QQ号=10001, 内容="test"
│  点击 "发送测试消息"
│
├─► sendTestMessage()
│     │
│     ├─ 校验: targetId 不为空、content 不为空
│     │
│     ├─ testSending = true  ← 按钮变灰 "发送中..."
│     │
│     └─► invoke("send_qq_message", {
│           targetType: "private",
│           targetId: 10001,
│           message: "test"
│         })
│           │
│           ▼
│     lib.rs::send_qq_message()
│       │
│       ├─ 构建 OneBot action JSON:
│       │   {
│       │     "action": "send_private_msg",
│       │     "params": {
│       │       "user_id": 10001,
│       │       "message": [{"type":"text","data":{"text":"test"}}]
│       │     },
│       │     "echo": "actrace-1720000000123"
│       │   }
│       │
│       ├─► qq_handle.try_send_action(&json_str)
│       │     │
│       │     ├─ 遍历 senders，跳过 is_closed() 的
│       │     │
│       │     ├─ 找到活跃 sender → tx.send(json_str)
│       │     │   │
│       │     │   │  ╔═══════════════════════════╗
│       │     │   │  ║  跨线程！json 出现在        ║
│       │     │   │  ║  handle_connection 的       ║
│       │     │   │  ║  tokio::select! 分支 B      ║
│       │     │   │  ╚═══════════════════════════╝
│       │     │   │
│       │     │   └─→ handle_connection loop
│       │     │         → rx.recv() = Some(json)
│       │     │         → write.send(Text(json))
│       │     │         → NapCat 收到 → 发 QQ 消息
│       │     │
│       │     └─ 没有活跃 sender → Err("没有活跃的 NapCat 连接")
│       │
│       └─► Ok({"success": true, "echo": "actrace-..."})
│             │
│             ▼
│     前端收到返回值
│       ├─ testSending = false
│       └─ testResult = { ok: true, msg: "消息已发送" }
│           → 绿色提示显示
```

### 流程图 6：前端轮询消息列表

```
QQNotificationSettings.vue  onMounted()
│
├─► refreshMessages()   ← 立即执行一次
│     │
│     └─► invoke("get_qq_messages")
│           │
│           ▼
│     lib.rs::get_qq_messages()
│       │
│       ├─► qq_handle.get_messages()
│       │     │
│       │     ├─ messages.lock()
│       │     ├─ iter().rev()        ← 反转，最新在前
│       │     └─ cloned().collect()
│       │
│       └─► qq_handle.has_connection()
│             │
│             └─ senders 中有未关闭的 → true/false
│
├─► pollTimer = setInterval(refreshMessages, 3000)
│     │
│     └─ 每 3 秒 ──► refreshMessages()
│                     │
│                     ├─ messages.value = data.messages
│                     │   → Vue 响应式更新 → 消息列表重新渲染
│                     │
│                     └─ connectionStatus.value =
│                          data.connected ? "connected" : "disconnected"
│                          → 连接状态横幅变色
│
└─► onUnmounted()
      └─ clearInterval(pollTimer)  ← 离开页面停止轮询
```

---

## 关键数据结构关系图

```
Arc 引用计数共享（多任务/Mutex 保护）：

                    ┌─────────────────────────────────┐
                    │         QQSharedState            │
                    │                                  │
  QQPluginHandle ──►│ senders ──► Arc<Mutex<Vec<Tx>>> │◄── handle_connection
  (Tauri State)     │                                  │     (tokio task)
                    │ messages ─► Arc<Mutex<VecDeque>> │◄── handle_received_msg
  前端 invoke() ──► │                                  │
                    │ app_handle ─► Option<AppHandle>  │◄── inject_tauri_resources
  前端 polling ────►│                                  │      (lib.rs setup)
                    │ reminder_store ─► Option<Store>  │
                    └─────────────────────────────────┘

   同一个 Arc 被多个地方持有：
   - QQPluginHandle.start_server()  启动服务时用 senders
   - QQPluginHandle.try_send_action() 发送消息时用 senders
   - QQPluginHandle.get_messages()   轮询时用 messages
   - handle_connection()             接收/发送/注册/清理 sender
   - handle_received_message()       写入 messages
```

---

## 前后端通信协议

```
前端 (Vue/TS)                        后端 (Rust/Tauri)
─────────────────────────────────────────────────────────────

invoke("get_plugin_config",           get_plugin_config(plugin_id)
  { pluginId: "qq-notification" })      → PluginManager.get_plugin_config()
  → QQNotificationConfig                → 返回 serde_json::Value

invoke("set_plugin_config",           set_plugin_config(plugin_id, config)
  { pluginId, config })                 → PluginManager.set_plugin_config()
  → ()                                  → DB 写入 + 通知插件

invoke("send_qq_message",             send_qq_message(target_type, target_id, message)
  { targetType, targetId, message })    → QQPluginHandle.try_send_action()
  → { success, echo }                   → mpsc → WS → NapCat

invoke("get_qq_messages")             get_qq_messages()
  → { messages: [...], connected }      → QQPluginHandle.get_messages()
                                         → QQPluginHandle.has_connection()

invoke("get_qq_connection_status")    get_qq_connection_status()
  → { connected: bool }                 → QQPluginHandle.has_connection()
```

---

## 一句话总结每个文件的职责

| 文件 | 一句话 |
|---|---|
| `src-tauri/src/plugin/mod.rs` | Plugin trait 定义 + PluginManager 注册所有插件 |
| `src-tauri/src/plugin/qq_notification.rs` | 全部 QQ 逻辑：WS 服务、mpsc 桥、消息缓冲、Toast |
| `src-tauri/src/lib.rs` | 组装一切：注入 handle、注册命令、启动服务 |
| `src/components/QQNotificationSettings.vue` | 配置表单 + 测试按钮 + 消息列表 + NapCat 引导 |
| `src/views/Plugins.vue` | 插件列表页，按 id 挂载对应 Settings 组件 |
| `src/views/ReminderToast.vue` | Toast 栈容器，接收 `window.addToastNotification` |
| `src/components/ToastCard.vue` | 单条 Toast 卡片（标题/内容/进度条/操作按钮） |
| `src-tauri/src/reminder_toast.rs` | Toast 窗口创建/定位/JS 注入 |
| `src-tauri/src/window_manager/windows.rs` | Win32 `WS_EX_NOACTIVATE` 不抢焦点显示 |
