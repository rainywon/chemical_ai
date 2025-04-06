<template>
  <div id="common">
    <el-container class="container">
      <!-- 侧边栏区域（已优化） -->
      <el-aside class="app-sidebar" :width="sidebarWidth">
        <!-- 侧边栏头部 -->
        <header class="sidebar-header">
          <template v-if="!isCollapsed">
            <img class="brand-icon" src="../assets/product.png" alt="Logo" />
            <span class="brand-text">天工AI智能助手</span>
          </template>
          <el-tooltip :content="isCollapsed ? '展开侧栏' : '收起侧栏'">
            <img class="collapse-icon" src="../assets/aside.png" @click="toggleSidebar" />
          </el-tooltip>
        </header>

        <!-- 新对话 -->
        <div class="new-chat" v-if="!isCollapsed">
          <el-button type="primary" @click="newChat" class="new-chat-btn">+ 新对话</el-button>
        </div>
        <div class="new-chat" v-if="isCollapsed">
          <el-tooltip effect="dark" content="新建对话" placement="top" popper-class="custom-tooltip">
            <img src="../assets/newchat.png" alt="" class="collapse-icon" @click="newChat">
          </el-tooltip>
        </div>
        <!-- 生成模式选择 -->
        <div class="option-container" v-if="!isCollapsed">
          <p class="selection-instruction">
            生成模式
          </p>
          <div class="model_select">
            <el-select v-model="selectedOption" placeholder="请选择生成方式" @change="handleChange">
              <el-option v-for="item in options" :key="item.value" :label="item.label" :value="item.value">
              </el-option>
            </el-select>
          </div>
        </div>
        <!-- 分割线 -->

        <!-- 历史对话 -->
        <div class="history" v-if="!isCollapsed">
          <div class="history-header">
            <span>历史对话</span>
            <el-tooltip content="清除所有历史记录">
              <img class="delete-icon" src="../assets/delete_history.png" @click="clearTotalHistory" width="20px"
                height="20px" />
            </el-tooltip>
          </div>

          <!-- 历史记录列表部分 -->
          <div class="history-list">
            <template v-if="totalChatHistory.length > 0">
              <div v-for="(chat, index) in [...totalChatHistory].reverse()" :key="index" class="history-item"
                @click="selectChat(chat)" :class="{ 'active-chat': chat.id === currentChatId }">
                <span class="history-text">
                  {{ chat.messages?.length > 0 ? chat.messages[0].text : '空对话' }}
                </span>
                <el-tooltip content="删除记录">
                  <!-- 添加.stop修饰符阻止事件冒泡 -->
                  <img class="delete-item-icon" src="../assets/delete_history.png" @click.stop="deleteChat(chat.id)"
                    width="20px" height="20px" />
                </el-tooltip>
              </div>
            </template>
            <div v-else class="empty-history">
              <img src="../assets/no_history.png" class="empty-icon" alt="空状态">
              <p class="empty-text">暂无历史对话</p>
              <p class="empty-tip">开始新的对话吧～</p>
            </div>
          </div>
        </div>

        <!-- 个人信息 -->
        <div class="user-info" v-if="!isCollapsed">
          <img src="../assets/user_img.png" alt="用户头像" width="40px" height="40px">
          <span class="username">{{UserName}}</span>
          <el-tooltip effect="dark" content="退出登录" placement="top" popper-class="custom-tooltip">
            <img class="setting-icon" src="../assets/leave.png" alt="设置" width="20px" height="20px" @click="tologin">
          </el-tooltip>
        </div>
      </el-aside>

      <!-- 主内容区 -->
      <el-container class="main-container">
        <el-header class="chat-header">
          <div class="conversation-title" v-if="currentChatHistory.length > 0">
            {{ currentChatHistory[0]?.text || '新对话' }}
          </div>
          <div class="conversation-title" v-else>新对话</div>
          
          <!-- 添加跳转到welcome页面的按钮 -->
          <div class="welcome-btn" @click="goToWelcome">
            <el-tooltip content="返回欢迎页面" placement="bottom">
              <img src="../assets/leave.png" alt="首页" class="home-icon" />
            </el-tooltip>
          </div>
        </el-header>
        <el-main class="chat-main">
          <!-- 滚动容器,消息展示区 -->
          <div class="chat-scroll-container" ref="scrollContainer">
            <div class="chat-content-container">
              <ChatContentTop />
              <ChatMessage v-for="(message, index) in currentChatHistory" :key="index" :message="message.text"
                :messageType="message.type" :isLoading="message.isLoading" @regenerate="regenerateResponse"
                :messageId="message.id" :references="message.references" :question="message.question"
                :isLast="isLastAiMessage(message)" />
            </div>
            <!-- 添加滑动到底部按钮 -->
            <div class="scroll-to-bottom-btn" v-show="showScrollButton" @click="handleScrollToBottom">
              <i class="scroll-bottom-icon">⬇</i>
            </div>
          </div>

          <!-- 用户输入容器 -->
          <div class="chat-input-container">
            <div class="custom-chat-input">
              <textarea ref="inputRef" v-model="textarea2" @keyup.enter="handleEnter" @keydown.enter="handleShiftEnter"
                placeholder="给天工AI发送消息,Shift + Enter 换行,Enter 发送"
                style="width: 100%; height: 100%; padding: 10px; box-sizing: border-box; background-color: #f9f9f9; color: rgb(71, 71, 71); font-size: 16px; font-weight: normal; border: none; resize: none;   font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;"></textarea>
              <!-- 发送按钮 -->
              <div class="send-button-container" @click="handleSendMessage">
                <img src="../assets/send_message.png" alt="发送" class="send-button" />
              </div>
              <!-- 停止按钮 -->
              <div v-if="isSending" class="stop-button-container" @click="handleStopMessage">
                <img src="../assets/stop_message.png" alt="停止" class="stop-button" />
              </div>
            </div>
            <div class="footer-tip">
              <span style="font-size: 13px; color: rgb(155, 154, 153);">内容由AI生成,请仔细甄别</span>
            </div>
          </div>

          <!-- 登录提示弹窗 -->
          <el-dialog v-model="showLoginPrompt" title="登录提示" width="30%" :show-close="true">
            <template #header>
              <div class="dialog-header">
                <span>登录提示</span>
                <i class="el-icon-close" @click="showLoginPrompt = false" style="cursor: pointer;"></i>
              </div>
            </template>

            <div style="text-align: center">
              <p style="margin-bottom: 20px; font-size: 16px;">您需要登录后才能继续操作</p>
              <el-button type="primary" @click="router.push('/login')" style="width: 120px;">
                立即登录
              </el-button>
            </div>
          </el-dialog>

          <!-- 自定义确认弹窗 -->
          <div class="custom-confirm-overlay" v-if="showCustomConfirm">
            <div class="custom-confirm-modal">
              <div class="custom-confirm-header">
                <div :class="['custom-confirm-icon', confirmType]">
                  <i v-if="confirmType === 'warning'" class="el-icon-warning" style="font-size: 24px;"></i>
                  <i v-else-if="confirmType === 'danger'" class="el-icon-delete" style="font-size: 24px;"></i>
                </div>
                <div class="custom-confirm-title">{{ confirmTitle }}</div>
              </div>
              <div class="custom-confirm-content">
                {{ confirmMessage }}
              </div>
              <div class="custom-confirm-actions">
                <button class="custom-confirm-btn cancel" @click="cancelConfirm">{{ cancelText }}</button>
                <button :class="['custom-confirm-btn', confirmButtonClass]" @click="confirmAction">{{ confirmText }}</button>
              </div>
            </div>
          </div>
        </el-main>
      </el-container>
    </el-container>
    <router-view></router-view> <!-- 路由内容会渲染到这里 -->
  </div>
</template>

<script setup name="Chat">
import { ref, onMounted, nextTick, computed, onBeforeUnmount } from "vue";
import { useRouter } from "vue-router";
import { ElMessageBox, ElMessage, ElSelect, ElOption } from "element-plus";
import { API_BASE_URL } from "../config";
import ChatMessage from "../components/ChatMessage.vue";
import ChatContentTop from "../components/ChatContentTop.vue";
import axios from "axios";

/* ------------------ 响应式状态 ------------------ */
const router = useRouter();
const scrollContainer = ref(null);
const inputRef = ref(null);
const isCollapsed = ref(false);
const showLoginPrompt = ref(false);
const textarea2 = ref("");
const currentChatHistory = ref([]);
const currentChatId = ref(null);
const totalChatHistory = ref([]);
const isLoading = ref(false);
const isSending = ref(false); // 发送状态，控制按钮的启用禁用
let UserName = ref("AI用户");
let abortController = null; // 用于控制请求的中断
const selectedOption = ref("知识库生成");
const options = [
  { value: "llm", label: "大模型生成" },
  { value: "kb", label: "知识库生成" },
];
const shouldAutoScroll = ref(true); // 新增滚动状态判断
const showScrollButton = ref(false); // 控制滚动按钮显示
const showCustomConfirm = ref(false);
const confirmTitle = ref('');
const confirmMessage = ref('');
const confirmType = ref('warning'); // 'warning' or 'danger'
const confirmText = ref('确定');
const cancelText = ref('取消');
const confirmAction = ref(() => {});
const confirmButtonClass = computed(() => confirmType.value === 'danger' ? 'danger' : 'confirm');

/* ------------------ 计算属性 ------------------ */
const sidebarWidth = computed(() => (isCollapsed.value ? "64px" : "300px"));
// 通过计算属性返回当前选择的标签
const selectedOptionLabel = computed(() => {
  const option = options.find(
    (option) => option.value === selectedOption.value
  );
  return option ? option.label : "";
});
// 计算属性
const lastAiMessageId = computed(() => {
  const aiMessages = currentChatHistory.value.filter((m) => m.type === "ai");
  return aiMessages.length ? aiMessages[aiMessages.length - 1].id : null;
});

// 判断是否为最后一条AI消息
const isLastAiMessage = (msg) => {
  return msg.type === "ai" && msg.id === lastAiMessageId.value;
};

const setupScrollListener = () => {
  const container = scrollContainer.value;
  if (container) {
    container.addEventListener("scroll", handleScroll);
  }
};

// 滚动事件处理
const handleScroll = () => {
  const container = scrollContainer.value;
  if (!container) return;
  
  // 计算距离底部50px视为"触底"
  const threshold = 50;
  const { scrollTop, scrollHeight, clientHeight } = container;
  const isNearBottom = scrollHeight - (scrollTop + clientHeight) < threshold;
  
  shouldAutoScroll.value = isNearBottom;
  // 只有当距离底部超过150px时才显示滚动按钮
  showScrollButton.value = !isNearBottom && scrollHeight > clientHeight + 150;
};

/* ------------------ 生命周期钩子 ------------------ */
onMounted(async () => {
  try {
    // 尝试从 localStorage 中获取数据
    const mobile = localStorage.getItem("mobile");
    const generateMode = localStorage.getItem("generateMode");
    if (generateMode) {
      selectedOption.value = generateMode;
    } else {
      console.log("No generateMode found in localStorage.");
    }
    if (mobile) {
      UserName = mobile;
    } else {
      console.log("未从 localStorage 中获取到 mobile 数据");
    }
    setupScrollListener();
    // 初始化消息数据
    await initializeChatData(); // 等待 initializeChatData 完成
    nextTick(() => {
      // 滚动到最底部
      scrollToBottom();
    });

    // 检查 inputRef 是否存在并尝试聚焦
    if (inputRef.value) {
      inputRef.value.focus();
    } else {
      console.log("输入框 inputRef 不存在，无法聚焦");
    }
  } catch (error) {
    // 捕获任何错误并输出日志
    console.error("初始化过程中发生了错误:", error);
  }
});
onBeforeUnmount(() => {
  const container = scrollContainer.value;
  if (container) {
    container.removeEventListener("scroll", handleScroll);
  }
});
/* ------------------ 核心方法 ------------------ */
// 用户操作相关
const toggleSidebar = () => {
  // 切换侧边栏状态前记录当前滚动位置
  const scrollPos = scrollContainer.value ? scrollContainer.value.scrollTop : 0;
  
  // 添加过渡效果类
  document.body.classList.add('sidebar-transitioning');
  
  isCollapsed.value = !isCollapsed.value;
  
  // 使用nextTick确保DOM更新后重置滚动位置
  nextTick(() => {
    if (scrollContainer.value) {
      scrollContainer.value.scrollTop = scrollPos;
    }
    
    // 动画完成后移除过渡类
    setTimeout(() => {
      document.body.classList.remove('sidebar-transitioning');
    }, 350); // 与过渡时间匹配
  });
};
const handleEnter = (e) => !e.shiftKey && handleSendMessage();
const handleShiftEnter = (e) => e.shiftKey && null;
const handleSendMessage = async () => {
  if (!checkLogin()) {
    showLoginPrompt.value = true;
    return;
  }
  if (!textarea2.value.trim()) return;
  isSending.value = true;

  // 添加用户消息
  const userText = textarea2.value;
  const userMsg = {
    text: userText,
    type: "user",
    id: Date.now(),
    pairedAiId: null,
  };
  currentChatHistory.value.push(userMsg);

  // 添加 AI 占位消息
  const aiMsg = {
    text: "",
    type: "ai",
    id: Date.now() + 1,
    isLoading: true,
    parentId: userMsg.id,
    references: [],
    question: userText,
  };
  userMsg.pairedAiId = aiMsg.id;
  currentChatHistory.value.push(aiMsg);

  saveCurrentChatHistory();
  await nextTick(() => scrollToBottom("auto")); // 初始滚动立即执行
  textarea2.value = "";
  saveCurrentChat();

  abortController = new AbortController();
  try {
    let generate_mode = "";
    if (selectedOption.value === "大模型生成") {
      generate_mode = "query_model";
    } else if (selectedOption.value === "知识库生成") {
      generate_mode = "query_rag";
    }

    const response = await fetch(`${API_BASE_URL}/${generate_mode}/`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ question: userText }),
      signal: abortController.signal,
    });

    if (!response.body) throw new Error("未收到有效的流式响应");

    const reader = response.body.getReader();
    const decoder = new TextDecoder("utf-8");
    let buffer = "";
    let isFirstChunk = true;
    let partialText = "";
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      buffer += decoder.decode(value, { stream: true });

      // 处理缓冲区中的完整消息
      let newlineIndex;
      while ((newlineIndex = buffer.indexOf("\n")) !== -1) {
        const line = buffer.substring(0, newlineIndex);
        buffer = buffer.substring(newlineIndex + 1);

        try {
          const { type, data } = JSON.parse(line);

          if (type === "references") {
            // 更新参考文档
            currentChatHistory.value = currentChatHistory.value.map((msg) =>
              msg.id === aiMsg.id ? { ...msg, references: data } : msg
            );
          } else if (type === "content") {
            // 追加生成内容
            partialText += data;
            currentChatHistory.value = currentChatHistory.value.map((msg) =>
              msg.id === aiMsg.id ? { ...msg, text: partialText } : msg
            );
          } else if (type === "error") {
            // 处理错误信息
            partialText += data;
            currentChatHistory.value = currentChatHistory.value.map((msg) =>
              msg.id === aiMsg.id ? { ...msg, text: partialText } : msg
            );
          }
        } catch (e) {
          console.error("解析JSON失败:", e);
        }
      }

      await nextTick(() => scrollToBottom("auto")); // 初始滚动立即执行
    }

    // 处理剩余缓冲区内容
    if (buffer) {
      try {
        const { type, data } = JSON.parse(buffer);
        if (type === "content" || type === "error") {
          partialText += data;
          currentChatHistory.value = currentChatHistory.value.map((msg) =>
            msg.id === aiMsg.id ? { ...msg, text: partialText } : msg
          );
        }
      } catch (e) {
        console.error("解析剩余内容失败:", e);
      }
    }

    currentChatHistory.value = currentChatHistory.value.map((msg) =>
      msg.id === aiMsg.id ? { ...msg, isLoading: false } : msg
    );
  } catch (error) {
    // 处理用户主动中止的情况
    if (error.name === "AbortError") {
      console.log("请求已被中止");
      currentChatHistory.value = currentChatHistory.value.map((msg) =>
        msg.id === aiMsg.id ? { ...msg, isLoading: false } : msg
      );
    } else {
      console.error("流式传输出错:", error);
      currentChatHistory.value = currentChatHistory.value.map((msg) =>
        msg.id === aiMsg.id
          ? {
              ...msg,
              text: msg.text + "\n[生成出错，请重试]",
              isLoading: false,
            }
          : msg
      );
    }
  } finally {
    isSending.value = false;
    saveCurrentChatHistory();
  }
};

// 停止消息的逻辑
const handleStopMessage = () => {
  if (abortController) {
    abortController.abort(); // 中止当前请求
    console.log("请求已被中止");
  } else {
    console.log("没有活动的请求可以中止");
  }
  isSending.value = false; // 停止消息后恢复发送按钮
};

// 重新生成消息入口
const regenerateResponse = (aiMsgId) => {
  const aiMessage = currentChatHistory.value.find((msg) => msg.id === aiMsgId);
  if (!aiMessage) return;

  // 找到对应的用户消息
  const userMessage = currentChatHistory.value.find(
    (msg) => msg.id === aiMessage.parentId
  );
  if (userMessage) {
    // 重置AI消息
    currentChatHistory.value = currentChatHistory.value.map((msg) =>
      msg.id === aiMsgId
        ? { ...msg, text: "", isLoading: true, references: [] }
        : msg
    );
    // 使用流式处理逻辑重新生成答案
    handleRegenerate(userMessage.text, aiMsgId);
  }
};

// 重新生成处理器保持不变
const handleRegenerate = async (question, aiMsgId) => {
  abortController = new AbortController();
  try {
    isSending.value = true;
    let generate_mode = "";
    if (selectedOption.value === "大模型生成") {
      generate_mode = "query_model";
    } else if (selectedOption.value === "知识库生成") {
      generate_mode = "query_rag";
    }
    const response = await fetch(`${API_BASE_URL}/${generate_mode}/`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ question: question }),
      signal: abortController.signal,
    });

    if (!response.body) throw new Error("未收到有效的流式响应");

    const reader = response.body.getReader();
    const decoder = new TextDecoder("utf-8");
    let buffer = "";
    let isFirstChunk = true;
    let partialText = "";
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      buffer += decoder.decode(value, { stream: true });

      // 处理缓冲区中的完整消息
      let newlineIndex;
      while ((newlineIndex = buffer.indexOf("\n")) !== -1) {
        const line = buffer.substring(0, newlineIndex);
        buffer = buffer.substring(newlineIndex + 1);

        try {
          const { type, data } = JSON.parse(line);

          if (type === "references") {
            // 更新参考文档
            currentChatHistory.value = currentChatHistory.value.map((msg) =>
              msg.id === aiMsgId ? { ...msg, references: data } : msg
            );
          } else if (type === "content") {
            // 追加生成内容
            partialText += data;
            currentChatHistory.value = currentChatHistory.value.map((msg) =>
              msg.id === aiMsgId ? { ...msg, text: partialText } : msg
            );
          } else if (type === "error") {
            // 处理错误信息
            partialText += data;
            currentChatHistory.value = currentChatHistory.value.map((msg) =>
              msg.id === aiMsgId ? { ...msg, text: partialText } : msg
            );
          }
        } catch (e) {
          console.error("解析JSON失败:", e);
        }
      }

      await nextTick(() => scrollToBottom("auto")); // 初始滚动立即执行
    }

    // 处理剩余缓冲区内容
    if (buffer) {
      try {
        const { type, data } = JSON.parse(buffer);
        if (type === "content" || type === "error") {
          partialText += data;
          currentChatHistory.value = currentChatHistory.value.map((msg) =>
            msg.id === aiMsgId ? { ...msg, text: partialText } : msg
          );
        }
      } catch (e) {
        console.error("解析剩余内容失败:", e);
      }
    }

    currentChatHistory.value = currentChatHistory.value.map((msg) =>
      msg.id === aiMsgId ? { ...msg, isLoading: false } : msg
    );
  } catch (error) {
    if (error.name === "AbortError") {
      console.log("请求已被中止");
      currentChatHistory.value = currentChatHistory.value.map((msg) =>
        msg.id === aiMsgId ? { ...msg, isLoading: false } : msg
      );
      return;
    }
    console.error("重新生成流式传输出错:", error);
    currentChatHistory.value = currentChatHistory.value.map((msg) =>
      msg.id === aiMsgId
        ? { ...msg, text: msg.text + "\n[生成出错，请重试]", isLoading: false }
        : msg
    );
  } finally {
    isSending.value = false;
    saveCurrentChatHistory();
  }
};

// 监听 生成模式 的变化并处理
const handleChange = (value) => {
  if (value === "llm") {
    selectedOption.value = "大模型生成";

    // 这里可以调用大模型生成的相关逻辑
  } else if (value === "kb") {
    selectedOption.value = "知识库生成";
    // 这里可以调用知识库生成的相关逻辑
  }
  localStorage.setItem("generateMode", selectedOption.value);
};
// 退出登录
const tologin = async () => {
  try {
    await showConfirm({
      title: '退出登录',
      message: '您确定要退出登录吗？',
      type: 'warning',
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      onConfirm: () => {
    // 更新本地存储
        localStorage.setItem("isAuthenticated", "false"); 
    setTimeout(() => {
      router.push("/login"); // 延迟跳转，确保退出逻辑完成
    }, 200); // 延迟 200 毫秒
      }
    });
  } catch (e) {
    // 用户点击取消操作
    console.log("用户取消了退出操作", e);
  }
};

// 历史记录管理
const newChat = () => {
  if (currentChatHistory.value.length) saveCurrentChat();
  resetCurrentChat();
};
const selectChat = (chat) => {
  if (currentChatHistory.value.length) saveCurrentChat();
  loadChat(chat);
};
const deleteChat = (chatId) => {
  showConfirm({
    title: '删除对话',
    message: '确定要删除这个对话记录吗？',
    type: 'danger',
    confirmButtonText: '删除',
    cancelButtonText: '取消',
    onConfirm: () => {
      // 删除当前对话记录
      totalChatHistory.value = totalChatHistory.value.filter(
        (c) => c.id !== chatId
      );
      persistTotalHistory(); // 保存更新后的历史记录

      // 如果删除的是当前对话，重置当前对话
      if (chatId === currentChatId.value) {
        resetCurrentChat();
      }

      ElMessage.success("对话记录已删除");
    }
  }).catch(() => {
      // 取消操作时不做任何处理
    });
};

const clearTotalHistory = () => {
  showConfirm({
    title: '清空所有记录',
    message: '确定删除所有历史记录吗？此操作无法恢复。',
    type: 'danger',
    confirmButtonText: '清空',
    cancelButtonText: '取消',
    onConfirm: () => {
      // 清空历史记录
      totalChatHistory.value = [];
      localStorage.removeItem("totalChatHistory");

      // 重置当前对话
      currentChatId.value = generateChatId();
      currentChatHistory.value = [];
      localStorage.setItem("currentChatHistory", JSON.stringify([]));

      ElMessage.success("已清除所有历史记录");
    }
  }).catch(() => {
      // 取消操作
    });
};

// 数据持久化
const saveCurrentChat = () => {
  // 判断当前对话是否已经在历史记录中存在
  const existingIndex = totalChatHistory.value.findIndex(
    (c) => c.id === currentChatId.value
  );
  const chatData = {
    id: currentChatId.value,
    title: `对话 ${new Date().toLocaleTimeString()}`,
    messages: [...currentChatHistory.value],
    timestamp: Date.now(),
  };
  // 当前对话在历史记录中存在，则更新该对话的历史记录
  existingIndex > -1
    ? totalChatHistory.value.splice(existingIndex, 1, chatData)
    : totalChatHistory.value.push(chatData);

  persistTotalHistory();
};

const persistTotalHistory = () =>
  localStorage.setItem(
    "totalChatHistory",
    JSON.stringify(totalChatHistory.value)
  );

const saveCurrentChatHistory = () =>
  localStorage.setItem(
    "currentChatHistory",
    JSON.stringify({
      id: currentChatId.value,
      messages: currentChatHistory.value,
    })
  );

/* ------------------ 工具方法 ------------------ */
const checkLogin = () => localStorage.getItem("isAuthenticated") === "true"; //检查用户是否登录
// 生成一个唯一的对话ID
const generateChatId = () =>
  Date.now().toString(36) + Math.random().toString(36).substr(2);
//滑动条滑到底部
const scrollToBottom = (behavior = "smooth") => {
  if (scrollContainer.value && shouldAutoScroll.value) {
    const container = scrollContainer.value;
    container.scrollTo({
      top: container.scrollHeight,
      behavior: behavior,
    });
  }
};
//历史记录内容初始化
const initializeChatData = () => {
  try {
    totalChatHistory.value =
      JSON.parse(localStorage.getItem("totalChatHistory")) || [];
    const current =
      JSON.parse(localStorage.getItem("currentChatHistory")) || {};
    currentChatId.value = current.id || generateChatId();
    currentChatHistory.value = current.messages || [];
  } catch (e) {
    console.error("数据加载失败:", e);
    initializeFreshChat();
  }
};
const initializeFreshChat = () => {
  currentChatId.value = generateChatId();
  currentChatHistory.value = [];
  totalChatHistory.value = [];
  localStorage.removeItem("totalChatHistory");
  localStorage.removeItem("currentChatHistory");
};
// 清空当前对话历史记录的内容
const resetCurrentChat = () => {
  currentChatId.value = generateChatId();
  currentChatHistory.value = [];
  localStorage.setItem("currentChatHistory", JSON.stringify([]));
};

const loadChat = (chat) => {
  currentChatId.value = chat.id;
  currentChatHistory.value = [...chat.messages];
  nextTick(scrollToBottom);
};

// 新增方法来显示自定义确认框
const showConfirm = (options) => {
  confirmTitle.value = options.title || '确认操作';
  confirmMessage.value = options.message || '确定要执行此操作吗？';
  confirmType.value = options.type || 'warning'; 
  confirmText.value = options.confirmButtonText || '确定';
  cancelText.value = options.cancelButtonText || '取消';
  confirmAction.value = options.onConfirm || (() => {});
  showCustomConfirm.value = true;
  
  return new Promise((resolve, reject) => {
    confirmAction.value = () => {
      showCustomConfirm.value = false;
      if (options.onConfirm) options.onConfirm();
      resolve(true);
    };
  });
};

// 取消确认
const cancelConfirm = () => {
  showCustomConfirm.value = false;
};

// 强制滚动到底部的处理函数
const handleScrollToBottom = () => {
  const container = scrollContainer.value;
  if (container) {
    container.scrollTo({
      top: container.scrollHeight,
      behavior: 'smooth'
    });
    // 重置自动滚动状态
    shouldAutoScroll.value = true;
  }
};

// 跳转到welcome页面
const goToWelcome = () => {
  router.push('/');
};
</script>


<style scoped lang="less">
/* 全局容器 */
#common {
  height: 100%;
  font-family: 'SF Pro Display', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
  color: #111827;
  background: white;
}

.container {
  height: 100%;
  display: flex;
  overflow: hidden; /* 防止侧边栏动画时出现滚动条 */
}

/* 侧边栏区域 */
.app-sidebar {
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(10px);
  display: flex;
  flex-direction: column;
  transition: all 0.35s cubic-bezier(0.25, 1, 0.5, 1); /* 更平滑的缓动函数 */
  box-shadow: 0 1px 20px rgba(0, 0, 0, 0.06);
  border-right: 1px solid rgba(226, 232, 240, 0.8);
  position: relative;
  z-index: 10;
  overflow: hidden; /* 收起时防止内容溢出 */

  /* 侧边栏头部 */
  .sidebar-header {
    padding: 20px 16px;
    height: auto;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid rgba(226, 232, 240, 0.8);
    transition: padding 0.35s cubic-bezier(0.25, 1, 0.5, 1); /* 添加过渡效果 */

    .brand-icon {
      height: 32px;
      margin-right: 12px;
      filter: drop-shadow(0 2px 5px rgba(0, 0, 0, 0.1));
      transition: all 0.3s ease, opacity 0.2s ease, transform 0.3s ease;
      
      &:hover {
        transform: scale(1.05);
      }
    }

    .brand-text {
      font-family: 'SF Pro Display', -apple-system, sans-serif;
      font-size: 22px;
      font-weight: 700;
      letter-spacing: -0.5px;
      text-align: center;
      display: flex;
      justify-content: space-between;
      background: linear-gradient(135deg, #3b82f6, #8b5cf6);
      -webkit-background-clip: text;
      background-clip: text;
      -webkit-text-fill-color: transparent;
      text-shadow: 0 1px 1px rgba(0, 0, 0, 0.05);
      transition: opacity 0.25s ease; /* 添加淡入淡出效果 */
      white-space: nowrap; /* 防止文本换行 */
    }

    .collapse-icon {
      cursor: pointer;
      padding: 6px;
      height: 20px;
      border-radius: 6px;
      transition: all 0.25s ease, transform 0.3s ease;
      
      &:hover {
        background: rgba(59, 130, 246, 0.1);
        transform: scale(1.05);
      }
    }
  }

  /* 新对话按钮 */
  .new-chat {
    display: flex;
    height: auto;
    padding: 20px 16px;
    justify-content: center;

    .new-chat-btn {
      width: 90%;
      height: 48px;
      border-radius: 12px;
      background: linear-gradient(135deg, #3b82f6, #6366f1);
      border: none;
      font-weight: 600;
      letter-spacing: 0.3px;
      font-size: 15px;
      box-shadow: 0 4px 12px rgba(99, 102, 241, 0.25);
      transition: all 0.3s ease;
      
      &:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 16px rgba(99, 102, 241, 0.35);
      }
      
      &:active {
        transform: translateY(0);
      }
    }
    
    .collapse-icon {
      cursor: pointer;
      padding: 8px;
      height: 28px;
      border-radius: 8px;
      background: rgba(59, 130, 246, 0.1);
      transition: all 0.2s;
      
      &:hover {
        background: rgba(59, 130, 246, 0.2);
        transform: scale(1.05);
    }
  }
}

/* 生成模式选择 */
.option-container {
  margin: 5px 16px 15px;
  padding: 10px;
  background: rgba(248, 250, 252, 0.6);
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  
  .selection-instruction {
    font-size: 14px;
    font-weight: 600;
    color: #64748b;
    margin-bottom: 8px;
    text-align: left;
  }
  
  .model_select {
    padding: 0;
    
    .el-select {
      width: 100%;
      
      :deep(.el-input__wrapper) {
        border-radius: 10px;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
        background: white;
      }
      
      :deep(.el-input__inner) {
        font-size: 14px;
        font-weight: 500;
        color: #334155;
      }
    }
  }
}

/* 历史对话区域 */
.history {
  padding: 10px 8px;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
  flex: 1;
  margin-bottom: 16px;
  
  .history-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 14px;
    font-weight: 600;
    color: #64748b;
    margin-bottom: 8px;
    padding: 0 8px 6px;
    border-bottom: 1px solid rgba(226, 232, 240, 0.8);
    
    .delete-icon {
      padding: 4px;
      border-radius: 6px;
      transition: all 0.2s ease;
      width: 18px;
      height: 18px;
      
      &:hover {
        background-color: rgba(239, 68, 68, 0.1);
        transform: scale(1.05);
        cursor: pointer;
      }
    }
  }

  .history-list {
    display: flex;
    flex-direction: column;
    gap: 3px;

    .history-item {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 6px 8px;
      margin: 0 4px;
      cursor: pointer;
      border-radius: 8px;
      transition: all 0.2s;
      border: 1px solid transparent;
      min-height: 28px;

      &:hover {
        background: rgba(248, 250, 252, 0.8);
        border-color: rgba(226, 232, 240, 0.8);

        .delete-item-icon {
          opacity: 1;
          visibility: visible;
        }
      }

      .history-text {
        margin-left: 6px;
        font-size: 13px;
        font-weight: 500;
        max-width: 80%;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        color: #475569;
        line-height: 1.2;
      }

      .delete-item-icon {
        opacity: 0;
        visibility: hidden;
        transition: all 0.2s ease;
        cursor: pointer;
        margin-left: auto;
        padding: 3px;
        border-radius: 6px;
        width: 18px;
        height: 18px;
        
        &:hover {
          background-color: rgba(239, 68, 68, 0.1);
        }
      }

      &.active-chat {
        background: rgba(59, 130, 246, 0.08);
        border-left: 2px solid #3b82f6;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.03);
        
        .history-text {
          color: #1e40af;
          font-weight: 600;
        }
      }
    }
  }

  .empty-history {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 200px;
    padding: 20px;
    text-align: center;
    opacity: 0.8;
    animation: fadeIn 0.5s ease;

    .empty-icon {
      width: 80px;
      height: 80px;
      margin-bottom: 20px;
      opacity: 0.7;
      filter: grayscale(0.3);
    }

    .empty-text {
      font-size: 16px;
      font-weight: 600;
      color: #64748b;
      margin-bottom: 8px;
    }

    .empty-tip {
      font-size: 14px;
      color: #94a3b8;
    }
  }
}

/* 个人信息区域 */
.user-info {
    display: flex;
    height: auto;
    align-items: center;
    padding: 16px;
    border-top: 1px solid rgba(226, 232, 240, 0.8);
    background: rgba(248, 250, 252, 0.6);

    img {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      object-fit: cover;
      box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
    }

    .username {
      margin-left: 12px;
      font-size: 14px;
      font-weight: 500;
      color: #334155;
    }

    .setting-icon {
      margin-left: auto;
      cursor: pointer;
      padding: 6px;
      border-radius: 6px;
      transition: all 0.2s;
      width: 16px;
      height: 16px;
      
      &:hover {
        background: rgba(239, 68, 68, 0.1);
        transform: scale(1.05);
      }
    }
  }
}

/* 主内容区域 */
.main-container {
  flex: 1;
  height: 100vh;
  overflow: hidden;
  background: #ffffff;
  width: calc(100% - 64px);
  transition: width 0.35s cubic-bezier(0.25, 1, 0.5, 1); /* 匹配侧边栏过渡 */
  position: relative;
}

/* 添加 header 样式 */
.chat-header {
  height: 60px;
  line-height: 60px;
  border-bottom: 1px solid rgba(226, 232, 240, 0.8);
  padding: 0 20px;
  background: white;
  display: flex;
  align-items: center;
  transition: all 0.35s ease; /* 添加过渡效果 */
  position: relative; /* 添加相对定位 */
}

.conversation-title {
  font-size: 16px;
  font-weight: 500;
  color: #334155;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 90%;
  margin: 0 auto;
  text-align: center;
}

/* 添加welcome按钮样式 */
.welcome-btn {
  position: absolute;
  right: 20px;
  cursor: pointer;
  transition: all 0.25s ease;
  padding: 8px;
  border-radius: 8px;
  
  &:hover {
    background: rgba(59, 130, 246, 0.1);
    transform: translateY(-2px);
  }
  
  &:active {
    transform: translateY(0);
  }
  
  .home-icon {
    width: 20px;
    height: 20px;
    filter: grayscale(0.3);
  }
}

.chat-main {
  height: 100%;
  width: 100%;
  padding: 0;
  display: flex;
  flex-direction: column;
  background: white;

  /* 消息展示区域 */
  .chat-scroll-container {
    flex: 1;
    overflow-y: auto;
    padding: 20px 0;
    height: calc(100vh - 200px);
    scrollbar-width: thin;
    scrollbar-color: #cbd5e1 transparent;
    position: relative; /* 添加相对定位 */

    &::-webkit-scrollbar {
      width: 6px;
      background-color: transparent;
    }

    &::-webkit-scrollbar-thumb {
      border-radius: 6px;
      background-color: #cbd5e1;
      transition: background-color 0.3s;

      &:hover {
        background-color: #94a3b8;
      }
    }

    .chat-content-container {
      width: 55%;
      max-width: 900px;
      min-width: 600px;
      margin: 0 auto;
      padding: 40px 20px;
      min-height: calc(100% - 80px);
      box-sizing: border-box;
    }
    
    /* 滑动到底部按钮 */
    .scroll-to-bottom-btn {
      position: fixed;
      bottom: 180px;
      right: 30px;
      width: 40px;
      height: 40px;
      border-radius: 50%;
      background: white;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      box-shadow: 0 2px 12px rgba(0, 0, 0, 0.15);
      transition: all 0.3s ease;
      border: 1px solid rgba(226, 232, 240, 0.8);
      z-index: 10;
      
      &:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
      }
      
      .scroll-bottom-icon {
        font-style: normal;
        font-size: 20px;
        color: #3b82f6;
        font-weight: bold;
      }
    }
  }

  /* 用户输入区域 */
  .chat-input-container {
    width: 55%;
    max-width: 900px;
    min-width: 600px;
    margin: 0 auto 5px;
    padding: 2px 0;
    background: transparent;
    position: sticky;
    bottom: 0;
    z-index: 1;

    .custom-chat-input {
      position: relative;
      border-radius: 16px;
      background-color: white;
      overflow: hidden;
      box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08), 0 0 1px rgba(0, 0, 0, 0.1);
      transition: all 0.3s ease;
      border: 1px solid rgba(226, 232, 240, 0.8);

      textarea {
        min-height: 100px;
        max-height: 150px;
        overflow-y: auto;
        outline: none;
        border-radius: 16px;
        padding: 16px 80px 16px 16px;
        font-size: 15px;
        line-height: 1.5;
        color: #334155;
        background-color: transparent;
        
        &::placeholder {
          color: #94a3b8;
        }
      }
      
      &:focus-within {
        box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2), 0 2px 15px rgba(0, 0, 0, 0.1);
        border-color: rgba(59, 130, 246, 0.3);
      }

      textarea::-webkit-scrollbar {
        width: 4px;
        background: transparent;
      }

      textarea::-webkit-scrollbar-thumb {
        background: #cbd5e1;
        border-radius: 4px;
      }

      textarea::-webkit-scrollbar-thumb:hover {
        background: #94a3b8;
      }
      
      /* 发送按钮 */
      .send-button-container {
        position: absolute;
        bottom: 12px;
        right: 12px;
        background: linear-gradient(135deg, #3b82f6, #6366f1);
        border-radius: 50%;
        padding: 12px;
        cursor: pointer;
        transition: all 0.3s ease;
        display: flex;
        justify-content: center;
        align-items: center;
        box-shadow: 0 3px 10px rgba(99, 102, 241, 0.25);
        
        &:hover {
          transform: translateY(-2px);
          box-shadow: 0 4px 12px rgba(99, 102, 241, 0.35);
        }
        
        &:active {
          transform: translateY(0);
        }
      }

      .send-button {
        width: 20px;
        height: 20px;
        filter: brightness(2);
      }

      /* 停止按钮 */
      .stop-button-container {
        position: absolute;
        bottom: 12px;
        right: 12px;
        background: linear-gradient(135deg, #ef4444, #f43f5e);
        border-radius: 50%;
        padding: 12px;
        cursor: pointer;
        transition: all 0.3s ease;
  display: flex;
        justify-content: center;
  align-items: center;
        box-shadow: 0 3px 10px rgba(239, 68, 68, 0.25);
        
        &:hover {
          transform: translateY(-2px);
          box-shadow: 0 4px 12px rgba(239, 68, 68, 0.35);
        }
        
        &:active {
          transform: translateY(0);
        }
      }

      .stop-button {
        width: 20px;
        height: 20px;
        filter: brightness(2);
      }
    }

    .footer-tip {
      text-align: center;
      
      span {
        font-size: 13px;
        color: #64748b;
        border-radius: 4px;
        padding: 6px 10px;
        backdrop-filter: blur(4px);
      }
    }
  }
}

/* 登录提示弹窗 */
:deep(.el-dialog) {
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
  
  .el-dialog__header {
    padding: 20px;
    margin: 0;
    border-bottom: 1px solid #f1f5f9;
  }
  
  .el-dialog__title {
    font-weight: 600;
    font-size: 18px;
    color: #1e293b;
  }
  
  .el-dialog__body {
    padding: 30px 20px;
  }
  
  .el-button--primary {
    background: linear-gradient(135deg, #3b82f6, #6366f1);
    border: none;
    border-radius: 10px;
    height: 44px;
    font-weight: 600;
    letter-spacing: 0.3px;
    box-shadow: 0 4px 12px rgba(99, 102, 241, 0.25);
    transition: all 0.3s ease;
    
    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 16px rgba(99, 102, 241, 0.35);
    }
    
    &:active {
      transform: translateY(0);
    }
  }
}

.dialog-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  
  .el-icon-close {
    font-size: 20px;
    color: #64748b;
    transition: all 0.2s;
    border-radius: 50%;
    padding: 4px;
    
    &:hover {
      color: #1e293b;
      background: rgba(226, 232, 240, 0.5);
    }
  }
}

/* 动画 */
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(15px);
  }
  to {
    opacity: 0.8;
    transform: translateY(0);
  }
}

/* 响应式调整 */
@media (max-width: 1200px) {
  .chat-main .chat-content-container,
  .chat-main .chat-input-container {
    width: 70%;
    min-width: 500px;
  }
}

@media (max-width: 768px) {
  .chat-main .chat-content-container,
  .chat-main .chat-input-container {
    width: 85%;
    min-width: 300px;
  }
  
  .app-sidebar .history-item .history-text {
    max-width: 70%;
  }
}

/* 自定义确认模块 */
.custom-confirm-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(15, 23, 42, 0.6);
  backdrop-filter: blur(5px);
  z-index: 2000;
  display: flex;
  align-items: center;
  justify-content: center;
  animation: fadeIn 0.2s ease-out;
}

.custom-confirm-modal {
  width: 380px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15), 0 10px 30px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  display: flex;
  flex-direction: column;
  animation: scaleIn 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  border: 1px solid rgba(226, 232, 240, 0.8);
}

.custom-confirm-header {
  padding: 20px 24px 10px;
  display: flex;
  align-items: center;
}

.custom-confirm-icon {
  width: 40px;
  height: 40px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
  flex-shrink: 0;
}

.custom-confirm-icon.warning {
  background: linear-gradient(135deg, #ffedd5, #fed7aa);
  color: #ea580c;
}

.custom-confirm-icon.danger {
  background: linear-gradient(135deg, #fee2e2, #fecaca);
  color: #dc2626;
}

.custom-confirm-title {
  font-weight: 600;
  font-size: 18px;
  color: #0f172a;
  flex-grow: 1;
}

.custom-confirm-content {
  padding: 10px 24px 20px;
  color: #64748b;
  font-size: 15px;
  line-height: 1.5;
}

.custom-confirm-actions {
  padding: 14px 24px;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  background: #f8fafc;
  border-top: 1px solid #f1f5f9;
}

.custom-confirm-btn {
  padding: 8px 20px;
  font-size: 14px;
  font-weight: 600;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: 100px;
}

.custom-confirm-btn.cancel {
  background: #f1f5f9;
  color: #475569;
  border: 1px solid #e2e8f0;
}

.custom-confirm-btn.cancel:hover {
  background: #e2e8f0;
  transform: translateY(-1px);
}

.custom-confirm-btn.confirm {
  background: linear-gradient(135deg, #3b82f6, #6366f1);
  color: white;
  border: none;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.25);
}

.custom-confirm-btn.confirm:hover {
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(99, 102, 241, 0.35);
}

.custom-confirm-btn.danger {
  background: linear-gradient(135deg, #ef4444, #dc2626);
  color: white;
  border: none;
  box-shadow: 0 4px 12px rgba(220, 38, 38, 0.25);
}

.custom-confirm-btn.danger:hover {
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(220, 38, 38, 0.35);
}

/* 动画 */
@keyframes scaleIn {
  from { transform: scale(0.9); opacity: 0; }
  to { transform: scale(1); opacity: 1; }
}

/* 全局样式 - 侧边栏过渡期间的状态 */
.sidebar-transitioning * {
  pointer-events: none; /* 过渡期间禁用交互 */
}

.sidebar-transitioning .app-sidebar {
  will-change: width; /* 优化性能 */
}

.sidebar-transitioning .main-container {
  will-change: width; /* 优化性能 */
}
</style>