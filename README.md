# ToolBox 小工具集

## 已有工具

### 单价比价器 (cal)
- 支持 g/kg/ml/L/个 多单位自动换算
- 按重量/容量/数量分组自动比价
- 显示最低价和差价百分比
- 支持截图识别商品信息（火山引擎 API）
- 数据本地保存

## 使用方法

### 打包所有工具并生成 tools.json
```powershell
.\build-all.ps1
```

自动扫描所有带 `manifest.json` 的子目录，打包成 zip 并更新根目录 `tools.json`。

## 添加新工具

1. 新建子目录
2. 放 `manifest.json`：
```json
{
  "id": "工具id",
  "name": "工具名称",
  "version": "1.0.0",
  "description": "功能描述",
  "author": "ToolBox",
  "icon": "icon.png",
  "permissions": []
}
```
3. 放代码文件
4. 运行 `.\build-all.ps1` 自动打包并更新 tools.json
