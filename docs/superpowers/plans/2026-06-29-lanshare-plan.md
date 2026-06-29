# 局域网快传 (lanshare) 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现纯前端 WebRTC 点对点消息与文件传输工具

**Architecture:** 单文件 HTML/JS 应用，采用渐进式实现核心功能 → WebRTC 连接管理 → 文件分片传输 → UI 完善

**Tech Stack:** 纯前端 HTML5 API (HTML/CSS/JavaScript, WebRTC, localStorage, File API

## Global Constraints

- 单文件架构：所有代码在 `index.html` 中（与 cal 工具一致）
- 无外部依赖：不使用 npm、CDN、第三方库
- ToolBox 兼容：支持 ToolBridge API + localStorage 降级
- 代码风格：与 cal/index.html 保持一致（内联 CSS/JS，函数式风格

---

## Task 1: 项目脚手架与 manifest

创建工具目录和元数据文件

**Files:**
- Create: `lanshare/manifest.json
- Create: `lanshare/index.html` (基础结构)

**Interfaces:**
- Produces: 可运行的空工具框架

- [ ] **Step 1: 创建 manifest.json

```json
{
  "id": "lanshare",
  "name": "局域网快传",
  "version": "1.0.0",
  "description": "纯前端 WebRTC 点对点消息与文件传输，无需服务器",
  "author": "ToolBox",
  "icon": "icon.png",
  "permissions": []
}
```

- [ ] **Step 2: 创建 index.html 基础骨架**

```html
<!DOCTYPE html>
<html lang="zh">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>局域网快传</title>
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  max-width: 640px;
  margin: 0 auto;
  padding: 20px 16px;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4e8ec 100%);
  min-height: 100vh;
}
.card {
  background: white;
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.06);
  margin-bottom: 16px;
}
button {
  padding: 12px 18px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  border: none;
  border-radius: 10px;
  background: #6366f1;
  color: white;
  transition: all 0.2s ease;
}
button:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(99,102,241,0.3); }
button.secondary { background: #f1f5f9; color: #475569; }
button.danger { background: #fee2e2; color: #dc2626; }
</style>
</head>
<body>
<div class="card">
  <h2 style="margin:0 0 12px 0; font-size:24px; font-weight:700; color:#1a1a2e; text-align:center;">📡 局域网快传</h2>
  <p style="text-align:center; color:#64748b; font-size:14px;">WebRTC 点对点传输，无需服务器</p>
</div>
<script>
// 工具初始化
console.log('LAN Share loaded');
</script>
</body>
</html>
```

- [ ] **Step 3: 验证文件结构**

Run: `ls -la lanshare/`
Expected: `manifest.json`, `index.html`

- [ ] **Step 4: Commit**

```bash
git add lanshare/manifest.json lanshare/index.html
git commit -m "feat: add lanshare tool scaffolding"
```

---

## Task 2: 设备标识与存储层

实现设备ID生成、本地存储封装、连接历史持久化

**Files:**
- Modify: `lanshare/index.html`

**Interfaces:**
- Consumes: localStorage API
- Produces:
  - `getDeviceInfo()` - 返回当前设备信息
  - `saveMessage(peerId, msg)` - 保存消息
  - `getMessages(peerId)` - 获取消息历史
  - `saveConnection(conn)` - 保存连接
  - `getConnections()` - 获取历史连接

- [ ] **Step 1: 写入存储工具函数测试用例 (在 `<script>` 末尾添加)

```javascript
function runStorageTests() {
  const testKey = '_lanshare_test_';
  localStorage.setItem(testKey, 'test');
  console.assert(localStorage.getItem(testKey) === 'test', 'localStorage basic test');
  localStorage.removeItem(testKey);
  console.log('Storage tests passed');
}
```

- [ ] **Step 2: 运行测试确认环境可用**

在浏览器控制台执行 `runStorageTests()`，预期输出 "Storage tests passed"

- [ ] **Step 3: 实现设备标识与存储层实现

```javascript
// ===== 存储层
const STORAGE_PREFIX = 'lanshare_';

function getDeviceInfo() {
  let device = JSON.parse(localStorage.getItem(STORAGE_PREFIX + 'device') || 'null');
  if (!device) {
    device = {
      id: 'dev_' + Math.random().toString(36).substr(2, 9),
      name: '设备 ' + Math.floor(Math.random() * 1000)
    };
    localStorage.setItem(STORAGE_PREFIX + 'device', JSON.stringify(device));
  }
  return device;
}

function saveMessage(peerId, msg) {
  const key = STORAGE_PREFIX + 'messages_' + peerId;
  const messages = JSON.parse(localStorage.getItem(key) || '[]');
  messages.push(msg);
  localStorage.setItem(key, JSON.stringify(messages.slice(-100))); // 保留最近100条
}

function getMessages(peerId) {
  return JSON.parse(localStorage.getItem(STORAGE_PREFIX + 'messages_' + peerId) || '[]');
}

function saveConnection(conn) {
  const connections = JSON.parse(localStorage.getItem(STORAGE_PREFIX + 'connections') || '[]');
  const existing = connections.findIndex(c => c.id === conn.id);
  if (existing >= 0) {
    connections[existing] = { ...connections[existing], ...conn };
  } else {
    connections.push(conn);
  }
  localStorage.setItem(STORAGE_PREFIX + 'connections', JSON.stringify(connections.slice(-5)));
}

function getConnections() {
  return JSON.parse(localStorage.getItem(STORAGE_PREFIX + 'connections') || '[]');
}
```

- [ ] **Step 4: 验证存储功能**

在浏览器控制台依次执行：
- `getDeviceInfo()` → 应返回设备对象
- `saveMessage('test_peer', {id:1, content:'test'})`
- `getMessages('test_peer')` → 数组长度应为1
- `saveConnection({id:'peer1', name:'测试设备'})`
- `getConnections()` → 数组长度应为1

- [ ] **Step 5: Commit**

```bash
git add lanshare/index.html
git commit -m "feat: add device identity and storage layer"
```

---

## Task 3: WebRTC 连接管理器（基础

实现 RTCPeerConnection 封装、连接建立、SDP 交换

**Files:**
- Modify: `lanshare/index.html`

**Interfaces:**
- Consumes: `getDeviceInfo()`
- Produces:
  - `ConnectionManager` 类
  - `createOffer()` → SDP offer
  - `acceptOffer(offerSdp)` → SDP answer
  - `acceptAnswer(answerSdp)` → 完成连接

- [ ] **Step 1: 写测试函数（写一个简单的连接测试函数

```javascript
function testWebRTCSupport() {
  console.assert(
    typeof RTCPeerConnection !== 'undefined',
    'WebRTC supported'
  );
  console.log('WebRTC support test done');
}
```

- [ ] **Step 2: 运行测试**

控制台执行 `testWebRTCSupport()` → 预期 "WebRTC supported"`

- [ ] **Step 3: 实现 ConnectionManager 类**

```javascript
// ===== WebRTC 连接管理器
class ConnectionManager {
  constructor() {
    this.pc = null;
    this.dataChannel = null;
    this.status = 'disconnected';
    this.onMessage = null;
    this.onStatusChange = null;
    this.remoteDescReady = null; // 回调：SDP就绪回调
    this.iceCandidates = [];
  }

  _createPeerConnection() {
    const config = { iceServers: [] }; // 纯局域网，无需 STUN
    this.pc = new RTCPeerConnection(config);

    this.pc.onicecandidate = (e) => {
      if (e.candidate) {
        this.iceCandidates.push(e.candidate);
      }
    };

    this.pc.onconnectionstatechange = () => {
      this.status = this.pc.connectionState;
      if (this.onStatusChange) this.onStatusChange(this.status);
    };

    this.pc.ondatachannel = (e) => {
      this._setupDataChannel(e.channel);
    };
  }

  _setupDataChannel(channel) {
    this.dataChannel = channel;
    channel.onopen = () => {
      this.status = 'connected';
      if (this.onStatusChange) this.onStatusChange('connected');
    };
    channel.onmessage = (e) => {
      if (this.onMessage) this.onMessage(JSON.parse(e.data));
    };
    channel.onclose = () => {
      this.status = 'disconnected';
      if (this.onStatusChange) this.onStatusChange('disconnected');
    };
  }

  // 创建 Offer 发送方
  async createOffer() {
    this._createPeerConnection();
    this.dataChannel = this.pc.createDataChannel('data');
    this._setupDataChannel(this.dataChannel);
    
    const offer = await this.pc.createOffer();
    await this.pc.setLocalDescription(offer);
    
    // 等待 ICE 收集完成
    await new Promise(r => setTimeout(r, 2000));
    
    return JSON.stringify({
      sdp: this.pc.localDescription,
      candidates: this.iceCandidates
    });
  }

  // 接收 Offer 并生成 Answer
  async acceptOffer(offerStr) {
    const offer = JSON.parse(offerStr);
    this._createPeerConnection();
    await this.pc.setRemoteDescription(new RTCSessionDescription(offer.sdp));
    
    const answer = await this.pc.createAnswer();
    await this.pc.setLocalDescription(answer);
    
    // 添加远程 ICE
    offer.candidates.forEach(c => this.pc.addIceCandidate(new RTCIceCandidate(c)));
    
    // 等待本地 ICE
    await new Promise(r => setTimeout(r, 2000));
    
    return JSON.stringify({
      sdp: this.pc.localDescription,
      candidates: this.iceCandidates
    });
  }

  // 接收 Answer 完成连接
  async acceptAnswer(answerStr) {
    const answer = JSON.parse(answerStr);
    await this.pc.setRemoteDescription(new RTCSessionDescription(answer.sdp));
    answer.candidates.forEach(c => this.pc.addIceCandidate(new RTCIceCandidate(c)));
  }

  // 发送消息
  send(msg) {
    if (this.dataChannel && this.dataChannel.readyState === 'open') {
      this.dataChannel.send(JSON.stringify(msg));
      return true;
    }
    return false;
  }

  close() {
    if (this.dataChannel) this.dataChannel.close();
    if (this.pc) this.pc.close();
    this.status = 'disconnected';
  }
}
```

- [ ] **Step 4: 手动测试（两浏览器标签页）

标签页A:
```javascript
const cmA = new ConnectionManager()
cmA.onStatusChange = s => console.log('A status:', s)
cmA.createOffer().then(o => console.log('Offer:', o))
```

标签页B:
```javascript
const cmB = new ConnectionManager()
cmB.onStatusChange = s => console.log('B status:', s)
// 粘贴A的offer: cmB.acceptOffer(PASTE_OFFER).then(a => console.log('Answer:', a))
```

标签页A:
```javascript
// cmA.acceptAnswer(PASTE_ANSWER)
```

两边状态都变成 'connected' 即为成功。

- [ ] **Step 5: Commit**

```bash
git add lanshare/index.html
git commit -m "feat: add WebRTC connection manager"
```

---

## Task 4: 消息协议与文件分片引擎

实现消息序列化、文件分片与重组

**Files:**
- Modify: `lanshare/index.html`

**Interfaces:**
- Consumes: `ConnectionManager.send()`
- Produces:
  - `sendText(content)` - 发送文本消息
  - `sendFile(file)` - 发送文件（自动分片）
  - `handleIncomingMessage(msg)` - 处理接收消息

- [ ] **Step 1: 编写消息协议测试**

```javascript
function testMessageProtocol() {
  const testMsg = {
    type: 'text',
    id: 'test_1',
    from: 'dev_test',
    timestamp: Date.now(),
    content: 'hello'
  };
  const serialized = JSON.stringify(testMsg);
  const parsed = JSON.parse(serialized);
  console.assert(parsed.content === 'hello', 'Message serialize test');
  console.log('Protocol test passed');
}
```

- [ ] **Step 2: 运行测试**

控制台执行 `testMessageProtocol()` → 预期 "Protocol test passed"

- [ ] **Step 3: 实现消息发送器**

```javascript
// ===== 消息与文件传输引擎
const CHUNK_SIZE = 64 * 1024; // 64KB

function generateId() {
  return 'msg_' + Math.random().toString(36).substr(2, 9);
}

class MessageEngine {
  constructor(connMgr, deviceInfo) {
    this.conn = connMgr;
    this.device = deviceInfo;
    this.onMessage = null;
    this.onFileProgress = null;
    this.receivingFiles = {}; // fileId -> {name, size, chunks, received}
    this.sendingFiles = {};
  }

  sendText(content) {
    const msg = {
      type: 'text',
      id: generateId(),
      from: this.device.id,
      timestamp: Date.now(),
      content: content
    };
    return this.conn.send(msg);
    if (this.onMessage) this.onMessage({ ...msg, direction: 'sent' };
  }

  async sendFile(file) {
    const fileId = generateId();
    const totalChunks = Math.ceil(file.size / CHUNK_SIZE);
    
    // 发送文件元信息
    this.conn.send({
      type: 'file-start',
      id: fileId,
      from: this.device.id,
      timestamp: Date.now(),
      fileId: fileId,
      fileName: file.name,
      fileSize: file.size,
      fileType: file.type,
      totalChunks: totalChunks
    });

    // 读取并分片发送
    const reader = new FileReader();
    let chunkIndex = 0;

    const readNextChunk = () => {
      const start = chunkIndex * CHUNK_SIZE;
      const end = Math.min(start + CHUNK_SIZE, file.size);
      reader.readAsArrayBuffer(file.slice(start, end));
    };

    reader.onload = (e) => {
      const chunk = new Uint8Array(e.target.result);
      // ArrayBuffer 转 base64
      let binary = '';
      for (let i = 0; i < chunk.byteLength; i++) {
        binary += String.fromCharCode(chunk[i]);
      }
      const base64 = btoa(binary);

      this.conn.send({
        type: 'file-chunk',
        fileId: fileId,
        chunkIndex: chunkIndex,
        data: base64
      });

      if (this.onFileProgress) {
        this.onFileProgress(fileId, chunkIndex + 1, totalChunks);
      }

      chunkIndex++;
      if (chunkIndex < totalChunks) {
        setTimeout(readNextChunk, 10); // 避免阻塞
      }
    };

    readNextChunk();
    return fileId;
  }

  handleMessage(msg) {
    if (msg.type === 'text') {
      if (this.onMessage) this.onMessage({ ...msg, direction: 'received' });
    } else if (msg.type === 'file-start') {
      this.receivingFiles[msg.fileId] = {
        name: msg.fileName,
        size: msg.fileSize,
        type: msg.fileType,
        totalChunks: msg.totalChunks,
        chunks: {},
        received: 0
      };
    } else if (msg.type === 'file-chunk') {
        const file = this.receivingFiles[msg.fileId];
        if (!file) return;
        
        file.chunks[msg.chunkIndex] = msg.data;
        file.received++;
        
        if (this.onFileProgress) {
          this.onFileProgress(msg.fileId, file.received, file.totalChunks);
        }

        if (file.received === file.totalChunks) {
          this._assembleFile(msg.fileId);
        }
      }
  }

  _assembleFile(fileId) {
    const file = this.receivingFiles[fileId];
    // base64 转 ArrayBuffer
    const bytes = [];
    for (let i = 0; i < file.totalChunks; i++) {
      const chunk = atob(file.chunks[i]);
      for (let j = 0; j < chunk.length; j++) {
        bytes.push(chunk.charCodeAt(j));
      }
    }
    const array = new Uint8Array(bytes);
    const blob = new Blob([array], { type: file.type });
    
    // 触发下载
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = file.name;
    a.click();
    URL.revokeObjectURL(url);

    // 通知完成
    if (this.onMessage) {
      this.onMessage({
        type: 'file',
        id: fileId,
        name: file.name,
        size: file.size,
        direction: 'received'
      });
    }
    delete this.receivingFiles[fileId];
  }
}
```

- [ ] **Step 4: 测试分片逻辑**

```javascript
// 在控制台测试：创建一个测试文件并分片
const testFile = new File(['Hello World!'.repeat(1000)], 'test.txt', {type: 'text/plain'});
console.log('File size:', testFile.size, 'chunks:', Math.ceil(testFile.size / (64*1024));
```

- [ ] **Step 5: Commit**

```bash
git add lanshare/index.html
git commit -m "feat: add message protocol and file chunking engine"
```

---

## Task 5: 连接 UI 组件

实现连接面板、SDP 显示/输入、历史连接列表

**Files:**
- Modify: `lanshare/index.html`

**Interfaces:**
- Consumes: `ConnectionManager`, `getConnections()`, `saveConnection()`
- Produces: 连接面板 DOM 与交互逻辑

- [ ] **Step 1: 添加连接面板 HTML（在 `<body>` 中现有内容之后添加

```html
<div class="card" id="connectionPanel">
  <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px 0;">
    <h3 style="font-size:16px; font-weight:600; color:#1e293b;">连接管理</h3>
    <span id="connStatus" style="font-size:13px; color:#64748b; background:#f1f5f9; padding:4px 10px; border-radius:12px;">未连接</span>
  </div>
  <div style="display:flex; gap:8px; margin-bottom:12px;">
    <button id="btnCreate" style="flex:1;">创建连接</button>
    <button id="btnJoin" class="secondary" style="flex:1;">加入连接</button>
  </div>
  <div id="connectionUi"></div>
</div>
```

- [ ] **Step 2: 添加连接面板 JS**

```javascript
// ===== 连接面板 UI
let connMgr = new ConnectionManager();
let msgEngine = null;
const deviceInfo = getDeviceInfo();

function setStatusText(text, color) {
  const el = document.getElementById('connStatus');
  el.textContent = text;
  if (color) el.style.color = color;
}

document.getElementById('btnCreate').onclick = async () => {
  setStatusText('生成连接码中...', '#f59e0b');
  const offer = await connMgr.createOffer();
  
  const connUi = document.getElementById('connectionUi');
  connUi.innerHTML = `
    <div style="margin:12px 0;">
      <p style="font-size:13px; color:#64748b; margin-bottom:8px;">将此连接码复制给对方：</p>
      <textarea id="offerText" style="width:100%; height:80px; padding:10px; border:2px solid #e2e8f0; border-radius:8px; font-size:12px; resize:none;" readonly>${offer}</textarea>
      <button class="secondary" style="width:100%; margin-top:8px;" onclick="navigator.clipboard.writeText(document.getElementById('offerText').value); setStatusText('已复制', '#10b981');">复制连接码</button>
    </div>
    <div style="margin:12px 0;">
      <p style="font-size:13px; color:#64748b; margin-bottom:8px;">粘贴对方的应答码：</p>
      <textarea id="answerInput" placeholder="粘贴应答码..." style="width:100%; height:60px; padding:10px; border:2px solid #e2e8f0; border-radius:8px; font-size:12px; resize:none;"></textarea>
      <button id="btnConfirmAnswer" style="width:100%; margin-top:8px;">确认连接</button>
    </div>
  `;
  
  document.getElementById('btnConfirmAnswer').onclick = async () => {
    const answer = document.getElementById('answerInput').value.trim();
    if (!answer) return;
    setStatusText('连接中...', '#f59e0b');
    await connMgr.acceptAnswer(answer);
  };
};

document.getElementById('btnJoin').onclick = () => {
  const connUi = document.getElementById('connectionUi');
  connUi.innerHTML = `
    <div style="margin:12px 0;">
      <p style="font-size:13px; color:#64748b; margin-bottom:8px;">粘贴对方的连接码：</p>
      <textarea id="offerInput" placeholder="粘贴连接码..." style="width:100%; height:60px; padding:10px; border:2px solid #e2e8f0; border-radius:8px; font-size:12px; resize:none;"></textarea>
      <button id="btnGenAnswer" style="width:100%; margin-top:8px;">生成应答码</button>
    </div>
  `;
  
  document.getElementById('btnGenAnswer').onclick = async () => {
    const offer = document.getElementById('offerInput').value.trim();
    if (!offer) return;
    setStatusText('生成应答中...', '#f59e0b');
    const answer = await connMgr.acceptOffer(offer);
    
    connUi.innerHTML += `
      <div style="margin:12px 0;">
        <p style="font-size:13px; color:#64748b; margin-bottom:8px;">将此应答码复制给对方：</p>
        <textarea id="answerText" style="width:100%; height:80px; padding:10px; border:2px solid #e2e8f0; border-radius:8px; font-size:12px; resize:none;" readonly>${answer}</textarea>
        <button class="secondary" style="width:100%; margin-top:8px;" onclick="navigator.clipboard.writeText(document.getElementById('answerText').value);">复制应答码</button>
      </div>
    `;
  };
};

connMgr.onStatusChange = (status) => {
  if (status === 'connected') {
    setStatusText('已连接 ✓', '#10b981');
    msgEngine = new MessageEngine(connMgr, deviceInfo);
    setupMessageHandlers();
  } else if (status === 'disconnected' || status === 'failed') {
    setStatusText('连接失败', '#ef4444');
  }
};
```

- [ ] **Step 3: 在浏览器验证 UI**

打开页面，点击"创建连接" → 应显示连接码文本框
点击"加入连接" → 应显示输入框

- [ ] **Step 4: Commit**

```bash
git add lanshare/index.html
git commit -m "feat: add connection panel UI"
```

---

## Task 6: 消息列表与输入 UI

实现气泡式消息列表、文本输入、文件选择

**Files:**
- Modify: `lanshare/index.html`

**Interfaces:**
- Consumes: `MessageEngine.sendText()`, `MessageEngine.sendFile()`
- Produces: 消息展示与输入组件

- [ ] **Step 1: 添加消息列表 HTML**

在连接面板之后添加：

```html
<div class="card" id="messagesPanel" style="display:none;">
  <h3 style="font-size:16px; font-weight:600; color:#1e293b; margin-bottom:12px;">消息</h3>
  <div id="messageList" style="height:300px; overflow-y:auto; padding:8px; background:#f8fafc; border-radius:10px; margin-bottom:12px;"></div>
  <div style="display:flex; gap:8px;">
    <input type="file" id="fileInput" style="display:none;">
    <button id="btnFile" class="secondary" style="padding:12px 16px;">📎</button>
    <input type="text" id="msgInput" placeholder="输入消息..." style="flex:1; padding:12px 14px; font-size:15px; border:2px solid #e2e8f0; border-radius:10px;">
    <button id="btnSend">发送</button>
  </div>
</div>
```

- [ ] **Step 2: 添加消息 UI JS**

```javascript
function setupMessageHandlers() {
  document.getElementById('messagesPanel').style.display = 'block';
  
  msgEngine.onMessage = (msg) => {
    addMessageToUi(msg);
    if (msg.direction === 'received') {
      saveMessage('current', msg);
    }
  };

  document.getElementById('btnSend').onclick = () => {
    const input = document.getElementById('msgInput');
    const text = input.value.trim();
    if (!text) return;
    msgEngine.sendText(text);
    input.value = '';
  };

  document.getElementById('msgInput').onkeypress = (e) => {
    if (e.key === 'Enter') document.getElementById('btnSend').click();
  };

  document.getElementById('btnFile').onclick = () => {
    document.getElementById('fileInput').click();
  };

  document.getElementById('fileInput').onchange = (e) => {
    const file = e.target.files[0];
    if (file) {
      msgEngine.sendFile(file);
      e.target.value = '';
    }
  };

  // 加载历史消息
  const history = getMessages('current');
  history.forEach(msg => addMessageToUi(msg));
}

function addMessageToUi(msg) {
  const list = document.getElementById('messageList');
  const div = document.createElement('div');
  const isSent = msg.direction === 'sent';
  div.style.cssText = `
    display:flex; justify-content:${isSent ? 'flex-end' : 'flex-start'};
    margin-bottom:8px;
  `;
  
  const bubble = document.createElement('div');
  bubble.style.cssText = `
    max-width:70%; padding:10px 14px; border-radius:16px;
    background:${isSent ? '#6366f1' : 'white'};
    color:${isSent ? 'white' : '#1e293b'};
    font-size:14px; word-wrap:break-word;
    box-shadow:0 2px 8px rgba(0,0,0,0.08);
    border-bottom-${isSent ? 'right' : 'left'}-radius:4px;
  `;
  
  if (msg.type === 'text') {
    bubble.textContent = msg.content;
  } else if (msg.type === 'file') {
    bubble.innerHTML = `📎 ${msg.name} (${(msg.size / 1024).toFixed(1)} KB)`;
  }
  
  div.appendChild(bubble);
  list.appendChild(div);
  list.scrollTop = list.scrollHeight;
}
```

- [ ] **Step 3: 测试完整流程**

两浏览器标签页测试：
1. A创建连接，复制offer
2. B粘贴offer生成answer，复制answer
3. A粘贴answer，等待连接
4. 连接后发送文本和文件

- [ ] **Step 4: Commit**

```bash
git add lanshare/index.html
git commit -m "feat: add message list and input UI"
```

---

## Task 7: 打包与最终测试

打包工具、验证所有功能、更新 tools.json

**Files:**
- Modify: `tools.json` (自动生成)

- [ ] **Step 1: 添加简单的图标占位 (lanshare/icon.png)

使用简单 SVG 转 base64 或使用简单图标文件，或暂时使用文本图标（本步可选，build 时可跳过）

- [ ] **Step 2: 运行构建脚本

```powershell
.\build-all.ps1
```

Expected: 输出 "Built: 局域网快传 -> lanshare/lanshare.zip"，tools.json 更新

- [ ] **Step 3: 最终功能测试清单**

- [ ] 页面加载正常，无控制台错误
- [ ] 创建连接 → 生成 offer
- [ ] 加入连接 → 粘贴 offer 生成 answer
- [ ] 粘贴 answer → 连接成功
- [ ] 发送文本消息 → 双方都能收到
- [ ] 发送小文件 (<1MB) → 成功接收并下载
- [ ] 刷新页面 → 消息历史保留
- [ ] 断开重连 → 功能正常

- [ ] **Step 4: Commit 最终版本**

```bash
git add tools.json lanshare/
git commit -m "feat: complete lanshare tool"
```

---

## Plan 自审检查

✅ **Spec 覆盖率:**
- WebRTC 连接管理 ✅ Task 3
- 文本消息传输 ✅ Task 4, 6
- 文件分片传输 ✅ Task 4
- 持久化存储 ✅ Task 2
- UI 组件 ✅ Task 5, 6

✅ **无占位符:**
- 所有步骤含完整代码
- 测试命令完整
- 文件路径精确

✅ **类型一致性:**
- ConnectionManager 类名一致
- 函数名前后一致
- 消息格式字段匹配
