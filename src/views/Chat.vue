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
            <img src="../assets/leave.png" alt="首页" class="home-icon" />
            <span class="home-text">首页</span>
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
const isSending = ref(false);
let UserName = ref("AI用户");
let abortController = null;
const selectedOption = ref("知识库生成");
const options = [
  { value: "llm", label: "大模型生成" },
  { value: "kb", label: "知识库生成" },
];
const shouldAutoScroll = ref(true);
const showScrollButton = ref(false);
const showCustomConfirm = ref(false);
const confirmTitle = ref('');
const confirmMessage = ref('');
const confirmType = ref('warning');
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
    // 获取用户信息
    const mobile = localStorage.getItem("mobile");
    const generateMode = localStorage.getItem("generateMode");
    if (generateMode) {
      selectedOption.value = generateMode;
    }
    if (mobile) {
      UserName = mobile;
    }
    
    setupScrollListener();
    // 初始化消息数据
    await initializeChatData();
    nextTick(() => {
      scrollToBottom();
    });

    // 检查输入框并聚焦
    if (inputRef.value) {
      inputRef.value.focus();
    }
  } catch (error) {
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

  saveCurrentChat();
  
  // 确保消息添加后立即滚动到底部
  await nextTick(() => {
    scrollToBottom("auto");
    // 强制滚动到底部
    const container = scrollContainer.value;
    if (container) {
      container.scrollTop = container.scrollHeight;
    }
  });
  
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
    saveCurrentChat();
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
    saveCurrentChat();
  }
};

// 监听 生成模式 的变化并处理
const handleChange = (value) => {
  if (value === "llm") {
    selectedOption.value = "大模型生成";
  } else if (value === "kb") {
    selectedOption.value = "知识库生成";
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
        localStorage.setItem("isAuthenticated", "false");
        setTimeout(() => {
          router.push("/login");
        }, 200);
      }
    });
  } catch (e) {
    console.log("用户取消了退出操作", e);
  }
};

// 历史记录管理
const newChat = async () => {
  try {
    // 如果当前有对话，先保存
    if (currentChatHistory.value.length) {
      await saveCurrentChat();
    }
    
    // 创建新会话
    const userId = getUserId();
    if (!userId) {
      ElMessage.error("未找到用户ID");
      return;
    }

    const response = await fetch(`${API_BASE_URL}/chat/sessions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        user_id: userId,
        title: `对话 ${new Date().toLocaleTimeString()}`
      })
    });

    if (!response.ok) throw new Error("创建会话失败");
    
    const data = await response.json();
    currentChatId.value = data.id;
    currentChatHistory.value = [];
    
    // 刷新会话列表
    await fetchChatSessions();
  } catch (error) {
    console.error("创建新对话失败:", error);
    ElMessage.error("创建新对话失败");
  }
};

const selectChat = async (chat) => {
  try {
    // 如果当前有对话，先保存
    if (currentChatHistory.value.length) {
      await saveCurrentChat();
    }
    
    // 加载选中的会话
    currentChatId.value = chat.id;
    const messages = await fetchChatMessages(chat.id);
    currentChatHistory.value = messages;
    nextTick(scrollToBottom);
  } catch (error) {
    console.error("加载对话失败:", error);
    ElMessage.error("加载对话失败");
  }
};

const deleteChat = async (chatId) => {
  try {
    await showConfirm({
      title: '删除对话',
      message: '确定要删除这个对话记录吗？',
      type: 'danger',
      confirmButtonText: '删除',
      cancelButtonText: '取消',
      onConfirm: async () => {
        const response = await fetch(`${API_BASE_URL}/chat/sessions/${chatId}`, {
          method: 'DELETE'
        });

        if (!response.ok) throw new Error("删除会话失败");
        
        // 更新本地状态
        totalChatHistory.value = totalChatHistory.value.filter(
          (c) => c.id !== chatId
        );
        
        // 如果删除的是当前对话，创建新对话
        if (chatId === currentChatId.value) {
          await newChat();
        }
        
        ElMessage.success("对话记录已删除");
      }
    });
  } catch (error) {
    console.error("删除对话失败:", error);
    ElMessage.error("删除对话失败");
  }
};

const clearTotalHistory = async () => {
  try {
    await showConfirm({
      title: '清空所有记录',
      message: '确定删除所有历史记录吗？此操作无法恢复。',
      type: 'danger',
      confirmButtonText: '清空',
      cancelText: '取消',
      onConfirm: async () => {
        const userId = getUserId();
        if (!userId) {
          ElMessage.error("未找到用户ID");
          return;
        }

        const response = await fetch(`${API_BASE_URL}/chat/sessions/clear?user_id=${userId}`, {
          method: 'DELETE'
        });
        
        if (!response.ok) throw new Error("清空历史记录失败");
        
        totalChatHistory.value = [];
        await newChat();
        ElMessage.success("已清除所有历史记录");
      }
    });
  } catch (error) {
    console.error("清空历史记录失败:", error);
    ElMessage.error("清空历史记录失败");
  }
};

// 数据持久化
const saveCurrentChat = async () => {
  try {
    if (!currentChatId.value) {
      await newChat();
      return;
    }

    // 保存所有消息
    for (const message of currentChatHistory.value) {
      const response = await fetch(`${API_BASE_URL}/chat/messages`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          session_id: currentChatId.value,
          message_type: message.type,
          content: message.text,
          parent_id: message.parentId,
          paired_ai_id: message.pairedAiId,
          references: message.references,
          question: message.question,
          is_loading: message.isLoading
        })
      });

      if (!response.ok) throw new Error("保存消息失败");
    }
  } catch (error) {
    console.error("保存对话失败:", error);
    ElMessage.error("保存对话失败");
  }
};

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
const initializeChatData = async () => {
  try {
    const userId = getUserId();
    if (!userId) {
      console.error("未找到用户ID");
      return;
    }

    // 获取会话列表
    const response = await fetch(`${API_BASE_URL}/chat/sessions?user_id=${userId}`);
    if (!response.ok) throw new Error("获取会话列表失败");
    
    const sessions = await response.json();
    totalChatHistory.value = sessions.map(session => ({
      id: session.id,
      title: session.title,
      messages: [],
      timestamp: new Date(session.created_at).getTime()
    }));

    // 如果有会话，加载最新的
    if (totalChatHistory.value.length > 0) {
      const latestSession = totalChatHistory.value[0];
      currentChatId.value = latestSession.id;
      const messages = await fetchChatMessages(latestSession.id);
      currentChatHistory.value = messages;
    } else {
      // 没有会话，创建新对话
      await newChat();
    }
  } catch (error) {
    console.error("初始化聊天数据失败:", error);
    ElMessage.error("初始化聊天数据失败");
  }
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

// 获取用户ID
const getUserId = () => {
  return localStorage.getItem("userId");
};

// 获取聊天会话列表
const fetchChatSessions = async () => {
  try {
    const userId = getUserId();
    if (!userId) {
      console.error("未找到用户ID");
      return;
    }
    
    const response = await fetch(`${API_BASE_URL}/chat/sessions?user_id=${userId}`);
    if (!response.ok) throw new Error("获取会话列表失败");
    
    const data = await response.json();
    totalChatHistory.value = data.map(session => ({
      id: session.id,
      title: session.title,
      messages: [],
      timestamp: new Date(session.created_at).getTime()
    }));
  } catch (error) {
    console.error("获取会话列表失败:", error);
    ElMessage.error("获取会话列表失败");
  }
};

// 获取特定会话的消息
const fetchChatMessages = async (sessionId) => {
  try {
    const response = await fetch(`${API_BASE_URL}/chat/messages?session_id=${sessionId}`);
    if (!response.ok) throw new Error("获取消息失败");
    
    const data = await response.json();
    return data.map(msg => ({
      id: msg.id,
      text: msg.content,
      type: msg.message_type,
      isLoading: msg.is_loading,
      parentId: msg.parent_id,
      pairedAiId: msg.paired_ai_id,
      references: msg.references,
      question: msg.question
    }));
  } catch (error) {
    console.error("获取消息失败:", error);
    ElMessage.error("获取消息失败");
    return [];
  }
};

// 保存新会话
const saveNewSession = async () => {
  try {
    const userId = getUserId();
    if (!userId) {
      console.error("未找到用户ID");
      return;
    }

    const response = await fetch(`${API_BASE_URL}/chat/sessions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        user_id: userId,
        title: `对话 ${new Date().toLocaleTimeString()}`
      })
    });

    if (!response.ok) throw new Error("创建会话失败");
    
    const data = await response.json();
    currentChatId.value = data.id;
    return data.id;
  } catch (error) {
    console.error("创建会话失败:", error);
    ElMessage.error("创建会话失败");
    return null;
  }
};

// 保存消息
const saveMessage = async (message) => {
  try {
    const response = await fetch(`${API_BASE_URL}/chat/messages`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        session_id: currentChatId.value,
        message_type: message.type,
        content: message.text,
        parent_id: message.parentId,
        paired_ai_id: message.pairedAiId,
        references: message.references,
        question: message.question,
        is_loading: message.isLoading
      })
    });

    if (!response.ok) throw new Error("保存消息失败");
    
    const data = await response.json();
    return data.id;
  } catch (error) {
    console.error("保存消息失败:", error);
    ElMessage.error("保存消息失败");
    return null;
  }
};

// 删除会话
const deleteSession = async (sessionId) => {
  try {
    const response = await fetch(`${API_BASE_URL}/chat/sessions/${sessionId}`, {
      method: 'DELETE'
    });

    if (!response.ok) throw new Error("删除会话失败");
    
    return true;
  } catch (error) {
    console.error("删除会话失败:", error);
    ElMessage.error("删除会话失败");
    return false;
  }
};
</script>

<style scoped lang="less">
@import '../styles/chat.less';
</style>