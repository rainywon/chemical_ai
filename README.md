# 天工AI智能助手

## 项目概述

天工AI智能助手是一个基于Vue 3和Vite构建的化工安全智能问答平台。该平台整合了大型语言模型和专业知识库，为用户提供化工安全领域的智能问答服务，帮助用户快速获取和理解化工安全相关知识。

## 功能特点

- **智能问答**：支持两种生成模式（大模型生成和知识库生成）
- **历史对话**：保存并管理用户的历史对话记录
- **资料库**：提供化工安全相关的文档资料查阅
- **用户系统**：包含注册、登录功能
- **实时响应**：采用流式响应技术，实现打字机效果的回答生成
- **优雅的UI**：现代化设计的用户界面，提供良好的用户体验

## 技术栈

- **前端框架**：Vue 3 + Vite
- **UI组件库**：Element Plus
- **路由管理**：Vue Router
- **HTTP客户端**：Axios
- **样式处理**：Less
- **Markdown渲染**：markdown-it, prismjs
- **代码高亮**：highlight.js
- **富文本编辑**：Quill

## 安装与运行

### 环境要求

- Node.js 14.0+
- npm 6.0+

### 安装步骤

1. 克隆项目到本地:

```bash
git clone https://github.com/rainywon/chemical_ai
cd chemical_ai
```

2. 安装依赖:

```bash
npm install
```

3. 配置后端API地址:

编辑 `src/config.js` 文件，设置合适的 `API_BASE_URL`。

4. 启动开发服务器:

```bash
npm run dev
```

5. 构建生产版本:

```bash
npm run build
```

### 开发与部署

- 开发模式：`npm run dev` - 启动带有热重载的开发服务器
- 生产构建：`npm run build` - 构建生产环境版本
- 预览生产版本：`npm run preview` - 本地预览生产构建版本

## 项目结构

```
chemical_ai/
├── public/             # 静态资源
├── src/                # 源代码
│   ├── api/            # API 接口
│   ├── assets/         # 资源文件（图片等）
│   ├── components/     # 公共组件
│   ├── router/         # 路由配置
│   ├── views/          # 页面视图
│   │   ├── Chat.vue    # 聊天界面
│   │   ├── Login.vue   # 登录页面
│   │   ├── Register.vue# 注册页面
│   │   ├── Files.vue   # 资料库页面
│   │   └── Welcome.vue # 欢迎页面
│   ├── App.vue         # 根组件
│   ├── config.js       # 配置文件
│   ├── main.js         # 入口文件
│   └── style.css       # 全局样式
├── index.html          # HTML 模板
├── vite.config.js      # Vite 配置
└── package.json        # 项目依赖
```

## 使用指南

1. **首页**：访问应用首页可查看系统简介和功能入口
2. **登录/注册**：新用户需先注册账号，已有账号可直接登录
3. **聊天**：
   - 在聊天界面可以向AI助手提问化工安全相关问题
   - 可以选择"大模型生成"或"知识库生成"两种模式
   - 支持历史对话查看和管理
4. **资料库**：可浏览和下载化工安全相关的文档资料

## 后端服务

本项目需要配合相应的后端API服务使用，后端服务提供以下功能：
- 用户认证与授权
- AI模型调用
- 知识库检索
- 文件管理

请确保在 `src/config.js` 中正确配置后端API的地址。

## 贡献指南

欢迎对本项目进行贡献。请遵循以下步骤：

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建Pull Request

## 许可证

[MIT License](LICENSE)
