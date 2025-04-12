<template>
  <div class="message-container" :class="messageType">
    <template v-if="messageType === 'ai'">
      <div class="ai-message-content">
        <img src="@/assets/product_logo.png" alt="AI Image" class="ai-image" />
        <!-- 显示文档参考的小方框 -->
        <template v-if="references.length > 0">
          <div class="references-box">
            <References :references="references" />
          </div>
        </template>
        <div class="chat-message ai">
          <!-- 使用 v-html 渲染 Markdown 后的 HTML 内容 -->
          <div class="message-content" v-html="parsedMessage" @click="handleThinkBlockClick"></div>
        </div>
        <!-- 加载指示器 -->
        <div v-if="isLoading" class="loading-indicator"></div>
      </div>
    </template>

    <template v-else>
      <div class="chat-message user">
        <div class="message-content" v-html="parsedMessage"></div>
      </div>
    </template>
  </div>

  <div class="message-actions" :style="actionStyle">
    <!-- 用户消息操作 -->
    <template v-if="messageType === 'user'">
      <el-tooltip content="复制" effect="dark">
        <img src="@/assets/copy.png" class="action-icon" @click="copyMessage" />
      </el-tooltip>
    </template>

    <!-- AI 消息操作 -->
    <template v-if="messageType === 'ai' && !isLoading">
      <el-tooltip content="复制" effect="dark">
        <img src="@/assets/copy.png" class="action-icon" @click="copyMessage" />
      </el-tooltip>
      <el-tooltip content="反馈" effect="dark">
        <img src="@/assets/feedback.png" class="action-icon" @click="openFeedbackDialog" />
      </el-tooltip>
      <el-tooltip v-if="isLast" content="重新生成" effect="dark">
        <img src="@/assets/regenerate.png" class="action-icon" @click="emit('regenerate', messageId)" />
      </el-tooltip>
    </template>
  </div>

  <!-- Feedback Component -->
  <FeedbackForm :visible="dialogVisible" :message="message" @update:visible="dialogVisible = $event"
    @submitFeedback="handleFeedbackSubmit" :question="question" />
</template>

<script setup>
import { computed, onMounted, ref, nextTick, watch, onUpdated } from "vue";
import { ElMessage } from "element-plus";
import { marked } from "marked"; // 用于 Markdown 渲染
import DOMPurify from "dompurify";
import References from "./References.vue";
import FeedbackForm from "./FeedbackForm.vue";
import hljs from "highlight.js";
import Prism from "prismjs"; //导入代码高亮插件的core（里面提供了其他官方插件及代码高亮样式主题，你只需要引入即可）
import "prismjs/themes/prism-tomorrow.min.css";

const emit = defineEmits(["regenerate"]);

const props = defineProps({
  message: String,
  messageType: String,
  isLoading: Boolean,
  messageId: [Number, String],
  references: Array,
  question: String,
  isLast: Boolean,
});

// Log the original message
console.log('Original Message:', props.message);

// 存储 think 块的状态（展开/收起）
const thinkBlocksState = ref(new Map());

// 处理 think 块的点击事件
const handleThinkBlockClick = (event) => {
  // 检查点击的是否是 think 块的头部或展开/收起按钮
  const targetElement = event.target;
  if (targetElement.classList.contains('think-header') || 
      targetElement.classList.contains('think-toggle-btn')) {
    const thinkBlock = targetElement.closest('.think-container');
    if (thinkBlock) {
      const thinkId = thinkBlock.dataset.thinkId;
      toggleThinkBlock(thinkId);
    }
  }
};

// 切换 think 块的展开/收起状态
const toggleThinkBlock = (thinkId) => {
  const newState = new Map(thinkBlocksState.value);
  newState.set(thinkId, !newState.get(thinkId));
  thinkBlocksState.value = newState;
  
  nextTick(() => {
    const thinkContent = document.querySelector(`.think-content[data-think-id="${thinkId}"]`);
    const thinkContainer = document.querySelector(`.think-container[data-think-id="${thinkId}"]`);
    if (thinkContent && thinkContainer) {
      if (newState.get(thinkId)) {
        thinkContainer.classList.add('expanded');
        thinkContent.style.maxHeight = `${thinkContent.scrollHeight}px`;
      } else {
        thinkContainer.classList.remove('expanded');
        thinkContent.style.maxHeight = '0';
      }
    }
  });
};

marked.setOptions({
  highlight: function (code, lang) {
    if (Prism.languages[lang]) {
      return Prism.highlight(code, Prism.languages[lang], lang);
    }
    return code;
  },
});

// 修改计算属性，处理 think 标签并添加展开/收起功能
const parsedMessage = computed(() => {
  let rawHtml = marked(props.message || "");
  
  // 替换 <think> 标签，添加展开/收起功能
  let thinkBlockCounter = 0;
  rawHtml = rawHtml.replace(/<think>([\s\S]*?)<\/think>/g, (match, content) => {
    const thinkId = `think-${props.messageId}-${thinkBlockCounter++}`;
    
    // 初始化 think 块的状态（默认收起）
    if (!thinkBlocksState.value.has(thinkId)) {
      thinkBlocksState.value.set(thinkId, false);
    }
    
    return `
      <div class="think-container" data-think-id="${thinkId}">
        <div class="think-header" data-think-id="${thinkId}">
          <span class="think-icon">💭</span>
          <span class="think-title">思考过程</span>
          <span class="think-toggle-btn">${thinkBlocksState.value.get(thinkId) ? '收起' : '展开'}</span>
        </div>
        <div class="think-content" data-think-id="${thinkId}">
          ${content}
        </div>
      </div>
    `;
  });

  nextTick(() => {
    // 在渲染后，手动触发 Prism 高亮
    document.querySelectorAll("pre code").forEach((block) => {
      Prism.highlightElement(block);
    });
    document.querySelectorAll("code").forEach((block) => {
      Prism.highlightElement(block);
    });
    
    // 设置 think 块的初始展开/收起状态
    document.querySelectorAll(".think-content").forEach((content) => {
      const thinkId = content.dataset.thinkId;
      const isExpanded = thinkBlocksState.value.get(thinkId);
      
      if (isExpanded) {
        content.style.maxHeight = `${content.scrollHeight}px`;
        content.closest('.think-container').classList.add('expanded');
      } else {
        content.style.maxHeight = '0';
      }
    });
  });

  return DOMPurify.sanitize(rawHtml); // 防止 XSS 攻击
});

onMounted(() => {
  nextTick(() => {
    document.querySelectorAll("pre code").forEach((block) => {
      Prism.highlightElement(block);
    });
  });
});

onUpdated(() => {
  Prism.highlightAll();
});

const dialogVisible = ref(false);

const actionStyle = computed(() => ({
  display: "flex",
  justifyContent: props.messageType === "user" ? "flex-end" : "flex-start",
  gap: "12px",
}));

// 复制消息方法
const copyMessage = () => {
  let messageToCopy = props.message;
  if (props.messageType === "user") {
    messageToCopy = messageToCopy.trim();
  }
  navigator.clipboard
    .writeText(messageToCopy)
    .then(() => ElMessage.success("复制成功"))
    .catch(() => ElMessage.error("复制失败"));
};

// 打开反馈对话框
const openFeedbackDialog = () => {
  dialogVisible.value = true;
};

// 处理用户反馈
const handleFeedbackSubmit = (feedback) => {
  console.log("用户反馈:", feedback);
  ElMessage.success("感谢您的反馈！");
};
</script>

<style scoped>
/* 消息容器 */
.message-container {
  display: flex;
  align-items: flex-start;
  margin: 20px 0;
  flex-direction: column;
}

/* AI 消息样式 */
.message-container.ai {
  width: 100%;
  display: flex;
  align-items: flex-start;
  text-align: left;
}

.message-container .ai-image {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  margin-right: 10px;
  margin-bottom: 10px;
}

/* AI 对话框 */
.ai-message-content {
  position: relative;
  width: 100%;
}

.chat-message.ai {
  width: 100%;
  border-radius: 12px;
  margin-left: 5px;
  text-align: left;
  box-sizing: border-box;
}

/* 用户消息 */
.message-container.user {
  flex-direction: row-reverse;
}

.chat-message.user {
  background-color: #f1f0f0;
  max-width: 70%;
  min-width: 220px;
  border-radius: 12px;
  padding: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  margin-left: auto;
  text-align: left;
}

/* 操作按钮图标样式 */
.action-icon {
  width: 20px;
  height: 20px;
  cursor: pointer;
  transition: opacity 0.2s, background-color 0.2s;
  padding: 4px;
}

.action-icon:hover {
  opacity: 0.8;
  background-color: rgba(0, 0, 0, 0.1);
  border-radius: 35%;
}

/* 调整消息操作容器 */
.message-actions {
  margin-top: 8px;
  padding: 4px 0;
}

/* 加载指示器 */
.loading-indicator {
  position: absolute;
  bottom: -70px;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  border: 4px solid rgba(192, 192, 192, 0.5);
  border-top: 4px solid #2196f3;
  box-shadow: 0 0 10px rgba(33, 150, 243, 0.5);
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

/* 参考框样式 */
.references-box {
  margin-bottom: 20px;
}

/* Markdown 内容样式 */
.message-content :deep(*) {
  /* font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; */
  line-height: 1.6;
}

/* 标题样式 */
.message-content :deep(h1) {
  margin: 0.8em 0 0.5em;
  font-weight: 600;
  border-bottom: 1px solid #eaecef;
  padding-bottom: 0.3em;
}

.message-content :deep(h2) {
  margin: 0.7em 0 0.4em;
  font-weight: 550;
}

.message-content :deep(h3) {
  margin: 0.6em 0 0.3em;
  font-weight: 500;
}

/* 段落与文本 */
.message-content :deep(p) {
  margin: 0.5em 0 !important;
  word-wrap: break-word;
}

.message-content :deep(strong) {
  font-weight: 600;
  color: #2c3e50;
}

.message-content :deep(em) {
  color: #666;
  font-style: italic;
}

/* 列表系统 */
.message-content :deep(ul),
.message-content :deep(ol) {
  padding-left: 1.2em;
  margin: 0.4em 0;
}

.message-content :deep(li) {
  margin: 0.2em 0;
  padding-left: 0.3em;
}

.message-content :deep(ul) {
  list-style-type: "• ";
}

.message-content :deep(ol) {
  list-style-type: decimal;
}

/* 代码块系统 */
/* 调整原有代码块样式 */
.message-content :deep(pre) {
  position: relative;
  padding: 30px !important;
  border-radius: 15px;
}

.message-content :deep(code) {
  font-size: 0.9em;
}

.message-content :deep(pre code) {
  font-size: 0.9em;
}

/* 表格系统 */
.message-content :deep(table) {
  border-collapse: collapse;
  margin: 0.8em 0;
  width: 100%;
  box-shadow: 0 0 0 1px #dfe2e5;
}

.message-content :deep(th),
.message-content :deep(td) {
  border: 1px solid #dfe2e5;
  padding: 6px 12px;
  text-align: left;
}

.message-content :deep(th) {
  background: #f6f8fa;
  font-weight: 600;
}

/* 引用块 */
.message-content :deep(blockquote) {
  border-left: 4px solid #dfe2e5;
  margin: 0.8em 0;
  padding: 0.5em 1em;
  color: #6a737d;
  background: #f8f9fa;
}

/* 链接系统 */
.message-content :deep(a) {
  color: #0366d6;
  text-decoration: none;
  border-bottom: 1px solid rgba(3, 102, 214, 0.2);
}

.message-content :deep(a:hover) {
  color: #034c9e;
  border-bottom-color: currentColor;
}

/* 分割线 */
.message-content :deep(hr) {
  border: 0;
  height: 1px;
  background: #e1e4e8;
  margin: 1em 0;
}

.message-content :deep(.think) {
  font-family: "Arial", sans-serif; /* 选择易读的字体 */
  font-size: 14px; /* 设置适中的字体大小 */
  line-height: 1.5; /* 设置行高 */
  font-weight: 400; /* 设置正常字重 */
  letter-spacing: 0.5px; /* 调整字间距 */
  color: #626262; /* 浅灰色 */
  background-color: #f5f5f4;
  border-radius: 15px;
  padding: 10px;
  text-rendering: optimizeLegibility; /* 启用抗锯齿 */
}

/* 更新 think 相关样式 */
.message-content :deep(.think-container) {
  margin: 1.2rem 0;
  border-radius: 16px;
  border: 1px solid rgba(223, 225, 230, 0.6);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
  background-color: #fcfcfd;
  overflow: hidden;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  transform-origin: top;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}

.message-content :deep(.think-container.expanded) {
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.08);
  transform: translateY(0);
}

.message-content :deep(.think-header) {
  display: flex;
  align-items: center;
  padding: 14px 18px;
  background: linear-gradient(to right, #f9fafc, #f3f4f8);
  cursor: pointer;
  user-select: none;
  transition: all 0.25s ease;
  border-bottom: 1px solid transparent;
}

.message-content :deep(.think-container.expanded .think-header) {
  border-bottom: 1px solid rgba(223, 225, 230, 0.6);
}

.message-content :deep(.think-header:hover) {
  background: linear-gradient(to right, #f5f6fa, #eef0f6);
}

.message-content :deep(.think-header:active) {
  background: linear-gradient(to right, #f1f2f6, #eaecf2);
}

.message-content :deep(.think-icon) {
  margin-right: 10px;
  font-size: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #6d7aad;
  background-color: rgba(109, 122, 173, 0.1);
  width: 28px;
  height: 28px;
  border-radius: 50%;
}

.message-content :deep(.think-title) {
  flex-grow: 1;
  font-weight: 600;
  color: #4a5173;
  font-size: 15px;
  letter-spacing: 0.4px;
  text-transform: capitalize;
}

.message-content :deep(.think-toggle-btn) {
  color: #4a6ee0;
  font-size: 13px;
  font-weight: 500;
  background: rgba(74, 110, 224, 0.08);
  padding: 6px 12px;
  border-radius: 8px;
  transition: all 0.2s ease;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
  position: relative;
  overflow: hidden;
  letter-spacing: 0.3px;
}

.message-content :deep(.think-toggle-btn::after) {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.1);
  opacity: 0;
  transition: opacity 0.2s ease;
}

.message-content :deep(.think-toggle-btn:hover) {
  background: rgba(74, 110, 224, 0.12);
  transform: translateY(-1px);
}

.message-content :deep(.think-toggle-btn:hover::after) {
  opacity: 1;
}

.message-content :deep(.think-toggle-btn:active) {
  transform: translateY(0);
  box-shadow: 0 1px 1px rgba(0, 0, 0, 0.03);
}

.message-content :deep(.think-content) {
  padding: 0;
  max-height: 0;
  overflow: hidden;
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
  font-size: 14.5px;
  line-height: 1.65;
  color: #3e4158;
  background-color: #ffffff;
  border-top: 1px solid transparent;
  font-weight: 400;
  letter-spacing: 0.2px;
  word-spacing: 0.5px;
}

.message-content :deep(.think-container.expanded .think-content) {
  padding: 22px;
  overflow: auto;
}

/* 内容区块的内部元素样式 */
.message-content :deep(.think-content p) {
  margin-bottom: 14px !important;
  text-rendering: optimizeLegibility;
}

.message-content :deep(.think-content p:last-child) {
  margin-bottom: 0 !important;
}

.message-content :deep(.think-content h1, 
                       .think-content h2, 
                       .think-content h3, 
                       .think-content h4) {
  font-weight: 600;
  margin: 1.5em 0 0.8em;
  color: #343956;
  letter-spacing: 0px;
  line-height: 1.4;
}

.message-content :deep(.think-content h1) {
  font-size: 1.6em;
  border-bottom: 1px solid rgba(223, 225, 230, 0.8);
  padding-bottom: 0.3em;
}

.message-content :deep(.think-content h2) {
  font-size: 1.4em;
}

.message-content :deep(.think-content h3) {
  font-size: 1.2em;
  font-weight: 550;
}

.message-content :deep(.think-content h4) {
  font-size: 1.1em;
  font-weight: 500;
}

.message-content :deep(.think-content ul,
                       .think-content ol) {
  padding-left: 1.8em;
  margin: 0.8em 0;
}

.message-content :deep(.think-content li) {
  margin: 0.4em 0;
  padding-left: 0.2em;
}

.message-content :deep(.think-content strong) {
  font-weight: 600;
  color: #2d3452;
}

.message-content :deep(.think-content em) {
  font-style: italic;
  color: #4b5169;
}

.message-content :deep(.think-content pre) {
  margin: 16px 0;
  border-radius: 12px;
  background-color: #f8f9fc !important;
  border: 1px solid rgba(223, 225, 230, 0.6);
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.04);
}

.message-content :deep(.think-content code) {
  background-color: rgba(74, 110, 224, 0.08);
  padding: 2px 5px;
  border-radius: 4px;
  font-family: 'SF Mono', 'Menlo', 'Monaco', 'Courier New', monospace;
  font-size: 0.9em;
  color: #3d476a;
}

.message-content :deep(.think-content pre code) {
  background-color: transparent;
  padding: 0;
  line-height: 1.6;
  font-size: 0.95em;
}

.message-content :deep(.think-content blockquote) {
  border-left: 4px solid #6d7aad;
  background-color: rgba(109, 122, 173, 0.05);
  padding: 0.8em 1em;
  margin: 1em 0;
  color: #4a5173;
  border-radius: 0 8px 8px 0;
}

.message-content :deep(.think-content a) {
  color: #4a6ee0;
  text-decoration: none;
  border-bottom: 1px solid rgba(74, 110, 224, 0.2);
  transition: all 0.2s ease;
  font-weight: 500;
}

.message-content :deep(.think-content a:hover) {
  color: #3a56b4;
  border-bottom-color: #3a56b4;
}

.message-content :deep(.think-container) {
  position: relative;
}

.message-content :deep(.think-container::before) {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  width: 4px;
  height: 100%;
  background: linear-gradient(to bottom, #4a6ee0, #6d7aad);
  opacity: 0.6;
  border-top-left-radius: 16px;
  border-bottom-left-radius: 16px;
}
</style>
