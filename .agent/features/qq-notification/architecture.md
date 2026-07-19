# QQ 通知插件 — 架构与通信图

## 1. 系统架构

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          你的 Windows 电脑                                │
│                                                                         │
│  ┌──────────────────────────┐          ┌──────────────────────────────┐ │
│  │        Actrace            │          │         NapCatQQ             │ │
│  │                           │          │                              │ │
│  │  ┌─────────────────────┐ │ 反向 WS  │  ┌────────────────────────┐  │ │
│  │  │ QQNotificationPlugin │ │◄────────│  │  OneBot 11 Client      │  │ │
│  │  │                     │ │  :23459  │  │  ws://127.0.0.1:23459  │  │ │
│  │  │  tokio-tungstenite  │ │─────────►│  │  /onebot/v11/ws        │  │ │
│  │  │  WS Server          │ │ 事件上报  │  └───────────┬────────────┘  │ │
│  │  │                     │ │          │              │               │ │
│  │  │  ┌───────────────┐  │ │          │  ┌───────────▼────────────┐  │ │
│  │  │  │ mpsc bridge   │  │ │          │  │  NTQQ 协议层           │  │ │
│  │  │  │ (send_action) │  │ │          │  │  (QQ 消息收发)         │  │ │
│  │  │  └───────┬───────┘  │ │          │  └───────────┬────────────┘  │ │
│  │  └──────────┼──────────┘ │          └──────────────┼──────────────┘ │
│  │             │            │                          │                │
│  │  ┌──────────▼──────────┐ │                          │                │
│  │  │  Tauri Commands      │ │                          │                │
│  │  │  send_qq_message    │ │                          │                │
│  │  │  get_qq_messages    │ │                          │                │
│  │  │  get_qq_conn_status │ │                          │                │
│  │  └──────────┬──────────┘ │                          │                │
│  │             │            │                          │                │
│  │  ┌──────────▼──────────┐ │                          │                │
│  │  │  Vue 3 Frontend      │ │                          │                │
│  │  │  QQNotification      │ │                          │                │
│  │  │  Settings.vue        │ │                          │                │
│  │  └─────────────────────┘ │                          │                │
│  │                           │                          │                │
│  │  ┌─────────────────────┐ │                          │                │
│  │  │  reminder_toast     │ │                          │                │
│  │  │  (桌面通知窗口)      │ │                          │                │
│  │  └─────────────────────┘ │                          │                │
│  └──────────────────────────┘                          │                │
└─────────────────────────────────────────────────────────────────────────┘
                                     │
                                     │ 互联网 (QQ 协议)
                                     ▼
                          ┌─────────────────────┐
                          │   腾讯 QQ 服务器      │
                          └──────────┬──────────┘
                                     │
                          ┌──────────▼──────────┐
                          │  目标 QQ 用户        │
                          │  (私聊 或 群聊)      │
                          └─────────────────────┘
```

## 2. 通信协议栈

```
┌──────────────────────────────────────────────┐
│                应用层                          │
│  Actrace Plugin  ◄── OneBot 11 JSON ──► NapCat │
├──────────────────────────────────────────────┤
│                传输层                          │
│  Actrace        ◄── WebSocket ──────► NapCat   │
│  (tokio-tungstenite server)    (client)        │
├──────────────────────────────────────────────┤
│                网络层                          │
│  127.0.0.1:23459  ◄── TCP ───►  127.0.0.1:ephemeral │
└──────────────────────────────────────────────┘
```

## 3. 发送 QQ 消息 — 完整通信流程

```
  用户 (前端 UI)                Actrace (Rust)                   NapCat                 QQ 服务器           目标用户

      │                            │                               │                      │                 │
      │ ① 填写目标QQ、内容          │                               │                      │                 │
      │ 点击"发送测试消息"           │                               │                      │                 │
      │──────────────────────────►│                               │                      │                 │
      │   invoke("send_qq_message",│                               │                      │                 │
      │   {targetType, targetId,   │                               │                      │                 │
      │    message})                │                               │                      │                 │
      │                            │                               │                      │                 │
      │                            │ ② 构建 OneBot 11 action        │                      │                 │
      │                            │ {                              │                      │                 │
      │                            │   "action":"send_private_msg", │                      │                 │
      │                            │   "params":{"user_id":10001,   │                      │                 │
      │                            │     "message":[{"type":"text", │                      │                 │
      │                            │       "data":{"text":"hi"}}]}, │                      │                 │
      │                            │   "echo":"actrace-xxx"         │                      │                 │
      │                            │ }                              │                      │                 │
      │                            │                               │                      │                 │
      │                            │ ③ try_send_action(json)        │                      │                 │
      │                            │   → mpsc::sender.send(json)   │                      │                 │
      │                            │                               │                      │                 │
      │                            │ ④ tokio::select! 收到 mpsc     │                      │                 │
      │                            │   → write.send(Text(json))     │                      │                 │
      │                            │──────────────────────────────►│                      │                 │
      │                            │      WebSocket Text frame      │                      │                 │
      │                            │                               │                      │                 │
      │                            │                               │ ⑤ 解析 action        │                 │
      │                            │                               │   发送 QQ 消息 ──────►│                 │
      │                            │                               │                      │                 │
      │                            │                               │                      │ ⑥ 路由消息 ────►│
      │                            │                               │                      │                 │
      │                            │                               │◄── 发送成功 ─────────│                 │
      │                            │                               │                      │                 │
      │                            │                               │ ⑦ 回复 action result │                 │
      │                            │◄──────────────────────────────│                      │                 │
      │                            │    {"status":"ok",             │                      │                 │
      │                            │     "retcode":0,               │                      │                 │
      │                            │     "data":{"message_id":123}, │                      │                 │
      │                            │     "echo":"actrace-xxx"}      │                      │                 │
      │                            │                               │                      │                 │
      │ ⑧ 返回 {success:true}       │                               │                      │                 │
      │◄───────────────────────────│                               │                      │                 │
      │                            │                               │                      │                 │
      │ ⑨ 显示 "消息已发送" ✓       │                               │                      │                 │
```

## 4. 接收 QQ 消息 — 完整通信流程

```
   QQ 用户                   腾讯服务器                  NapCat                 Actrace (Rust)             桌面 / 前端

      │                         │                         │                         │                        │
      │ ① 发送 "你好"            │                         │                         │                        │
      │────────────────────────►│                         │                         │                        │
      │                         │ ② 推送消息               │                         │                        │
      │                         │────────────────────────►│                         │                        │
      │                         │                         │                         │                        │
      │                         │                         │ ③ OneBot 11 消息事件     │                        │
      │                         │                         │ WebSocket Text frame     │                        │
      │                         │                         │────────────────────────►│                        │
      │                         │                         │ {                        │                        │
      │                         │                         │   "post_type":"message", │                        │
      │                         │                         │   "message_type":"private"│                       │
      │                         │                         │   "user_id":10086,       │                        │
      │                         │                         │   "sender":{             │                        │
      │                         │                         │     "nickname":"小明"    │                        │
      │                         │                         │   },                     │                        │
      │                         │                         │   "raw_message":"你好"   │                        │
      │                         │                         │ }                        │                        │
      │                         │                         │                         │                        │
      │                         │                         │                         │ ④ tokio::select!       │
      │                         │                         │                         │   read.next()           │
      │                         │                         │                         │   → OneBotMessageEvent  │
      │                         │                         │                         │                        │
      │                         │                         │                         │ ⑤ handle_received_msg() │
      │                         │                         │                         │                        │
      │                         │                         │                         │   ├─ 写入环形缓冲区      │
      │                         │                         │                         │   │  (messages.push)      │
      │                         │                         │                         │   │                      │
      │                         │                         │                         │   └─ create_toast_window │
      │                         │                         │                         │      title:"QQ 私聊-小明"│
      │                         │                         │                         │      body:"你好"        │
      │                         │                         │                         │      kind:"qq-message"  │
      │                         │                         │                         │                        │
      │                         │                         │                         │───────────────────────►│
      │                         │                         │                         │   window.eval()         │ ⑥ 桌面 Toast 弹出
      │                         │                         │                         │                        │  ┌─────────────────┐
      │                         │                         │                         │                        │  │ QQ 私聊 - 小明    │
      │                         │                         │                         │                        │  │ 你好              │
      │                         │                         │                         │                        │  │ ████████░░ 8s     │
      │                         │                         │                         │                        │  └─────────────────┘
      │                         │                         │                         │                        │
      │                         │                         │                         │ ⑦ 前端 3s 轮询 ───────►│
      │                         │                         │                         │◄── get_qq_messages() ──│
      │                         │                         │                         │   → 消息列表更新        │ ⑧ "收到的消息"面板
      │                         │                         │                         │                        │  显示新消息
```

## 5. 连接生命周期

```
  Actrace 启动            NapCat 启动              连接状态

      │                       │                      │
      │ ⑨ plugin.on_init()    │                      │
      │ → 检查 DB enabled      │                      │
      │ → 启动 WS Server       │                      │
      │ 监听 :23459            │                      ○  等待连接 (灰)
      │                       │                      │
      │                       │ ⑩ launcher.bat       │
      │                       │ → 登录 QQ             │
      │                       │ → 读取 onebot11.json  │
      │                       │ → WS 连接 Actrace     │
      │                       │─────────────────────►│
      │                       │  TCP 握手             │
      │◄──────────────────────│  WS 升级              │
      │                       │─────────────────────►│
      │ ⑪ accept_async(stream)│                      │
      │ → log "NapCat connected"                     │
      │ → mpsc sender 注册     │                      ●  已连接 (绿)
      │                       │                      │
      │                       │ ⑫ lifecycle 事件      │
      │◄──────────────────────│  {"post_type":        │
      │  reply ack ──────────►│   "meta_event",       │
      │                       │   "meta_event_type":   │
      │                       │   "lifecycle"}        │
      │                       │                      │
      │         ... 正常通信 ...                       │
      │                       │                      │
      │                       │ ⑬ NapCat 关闭/断网    │
      │                      ✕│                      │
      │ ⑭ WS Close frame      │                      │
      │ → log "disconnected"  │                      │
      │ → 清理 mpsc sender    │                      ○  等待连接 (灰)
      │                       │                      │
      │                       │ ⑮ NapCat 重连         │
      │                       │─────────────────────►│  ●  已连接 (绿)
      │                       │  (自动重连 30s 间隔)   │
```

## 6. 组件内部数据流

```
┌──────────────────────────────────────────────────────────────────────┐
│  QQNotificationPlugin (Rust plugin trait)                           │
│                                                                      │
│  ┌─────────────────────┐    ┌──────────────────────────────────┐    │
│  │ QQNotificationPlugin │    │ QQPluginHandle (Tauri State)      │    │
│  │                     │    │                                   │    │
│  │ enabled: AtomicBool │    │ shared: QQSharedState             │    │
│  │ config: Mutex<Cfg>  │    │  ├─ senders: Arc<Mutex<Vec<Tx>>> │    │
│  │ handle: Arc<Handle>─┼───►│  ├─ messages: Arc<Mutex<Deque>>  │    │
│  │                     │    │  ├─ app_handle: Option<AppHandle> │    │
│  │ Plugin trait 方法:    │    │  └─ reminder_store: Option<Store>│   │
│  │  on_init()          │    │                                   │    │
│  │  on_enable()        │    │ 方法:                              │    │
│  │  on_disable()       │    │  start_server()                   │    │
│  │  get_config()       │    │  stop_server()                    │    │
│  │  set_config()       │    │  try_send_action(json)            │    │
│  └─────────────────────┘    │  has_connection() → bool          │    │
│                              │  get_messages() → Vec<Record>    │    │
│                              └──────────┬───────────────────────┘    │
│                                         │                            │
│  ┌──────────────────────────────────────┼─────────────────────────── │
│  │  Tauri Commands (lib.rs)             │                            │
│  │                                      │                            │
│  │  send_qq_message ──────────────────► try_send_action()           │
│  │  get_qq_messages ◄────────────────── get_messages()               │
│  │  get_qq_connection_status ◄───────── has_connection()             │
│  └─────────────────────────────────────┼──────────────────────────── │
│                                        │                             │
│  ┌─────────────────────────────────────┼──────────────────────────── │
│  │  Vue Frontend                       │                             │
│  │                                     │                             │
│  │  invoke("send_qq_message",...) ────►│                             │
│  │  invoke("get_qq_messages") ────────►│                             │
│  │  invoke("get_qq_connection_status")►│                             │
│  └─────────────────────────────────────┘                             │
└──────────────────────────────────────────────────────────────────────┘
```

## 7. OneBot 11 消息格式参考

### Actrace → NapCat（发送 QQ 消息）

```json
{
  "action": "send_private_msg",
  "params": {
    "user_id": 10001,
    "message": [
      { "type": "text", "data": { "text": "Hello from Actrace" } }
    ]
  },
  "echo": "actrace-1720000000000"
}
```

### NapCat → Actrace（接收 QQ 消息）

```json
{
  "post_type": "message",
  "message_type": "private",
  "user_id": 10086,
  "sender": {
    "user_id": 10086,
    "nickname": "小明",
    "card": ""
  },
  "raw_message": "你好",
  "message_id": 456,
  "time": 1720000000,
  "self_id": 你的QQ号
}
```
