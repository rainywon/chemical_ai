<template>
  <div id="common">
    <el-container class="container">
      <!-- 侧边栏区域 -->
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
          <el-button type="primary" class="new-chat-btn" @click="createNewChatSession">+ 新对话</el-button>
        </div>
        <div class="new-chat" v-if="isCollapsed">
          <el-tooltip effect="dark" content="新建对话" placement="top" popper-class="custom-tooltip">
            <img src="../assets/newchat.png" alt="" class="collapse-icon" @click="createNewChatSession">
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
              <img class="delete-icon" src="../assets/delete_history.png" width="20px"
                height="20px" @click="clearAllChatHistory" />
            </el-tooltip>
          </div>

          <!-- 历史记录列表部分 -->
          <div class="history-list">
            <template v-if="totalChatHistory.length > 0">
              <div v-for="chat in totalChatHistory" :key="chat.id" class="history-item"
                :class="{ 'active-chat': chat.id === currentChatId }" @click="selectChatSession(chat.id)">
                <span class="history-text" :title="chat.title">
                  {{ chat.title || '新对话' }}
                </span>
                <el-tooltip content="删除记录">
                  <!-- 添加.stop修饰符阻止事件冒泡 -->
                  <img class="delete-item-icon" src="../assets/delete_history.png" 
                    @click.stop="deleteChatSession(chat.id)" width="20px" height="20px" />
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
          <div class="conversation-title" @click="startEditingTitle" v-if="!isEditingTitle">
            {{ currentChatTitle || '新对话' }}
            <el-tooltip content="点击修改标题" effect="dark" placement="top" v-if="currentChatId">
              <i class="el-icon-edit-outline title-edit-icon"></i>
            </el-tooltip>
          </div>
          <div class="title-edit-container" v-else>
            <el-input 
              v-model="editingTitle" 
              placeholder="输入对话标题" 
              size="small" 
              ref="titleInputRef"
              @blur="saveEditedTitle"
              @keyup.enter="saveEditedTitle"
              @keyup.esc="cancelEditingTitle"
            ></el-input>
          </div>
          
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
    <router-view></router-view>
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

/* ------------------ 状态管理 ------------------ */
// 响应式状态：用于管理组件的各种状态
const router = useRouter(); // 路由实例，用于页面导航
const scrollContainer = ref(null); // 滚动容器引用，用于控制消息区域的滚动
const inputRef = ref(null); // 输入框引用，用于聚焦输入框
const titleInputRef = ref(null); // 标题输入框引用
const isCollapsed = ref(false); // 侧边栏折叠状态，控制侧边栏的展开/收起
const showLoginPrompt = ref(false); // 登录提示显示状态，控制登录提示弹窗的显示/隐藏
const textarea2 = ref(""); // 输入框内容，存储用户输入的消息
const currentChatHistory = ref([]); // 当前对话历史，存储当前会话的所有消息
const currentChatId = ref(null); // 当前对话ID，标识当前正在进行的会话
const currentChatTitle = ref(""); // 当前对话标题
const totalChatHistory = ref([]); // 所有对话历史，存储所有历史会话
const isLoading = ref(false); // 加载状态，标识是否正在加载数据
const isSending = ref(false); // 发送状态，标识是否正在发送消息
const isEditingTitle = ref(false); // 是否正在编辑标题
const editingTitle = ref(""); // 编辑中的标题
let UserName = ref("AI用户"); // 用户名，显示当前登录用户
let abortController = null; // 中止控制器，用于取消正在进行的请求
const selectedOption = ref("知识库生成"); // 选中的生成模式，控制使用哪种方式生成回答
const options = [ // 生成模式选项列表
  { value: "llm", label: "大模型生成" },
  { value: "kb", label: "知识库生成" },
];
const shouldAutoScroll = ref(true);
const showScrollButton = ref(false);

// 确认框状态
const showCustomConfirm = ref(false);
const confirmTitle = ref('');
const confirmMessage = ref('');
const confirmType = ref('warning');
const confirmText = ref('确定');
const cancelText = ref('取消');
const confirmAction = ref(() => {});
const confirmButtonClass = computed(() => confirmType.value === 'danger' ? 'danger' : 'confirm');

// 计算属性
const sidebarWidth = computed(() => (isCollapsed.value ? "64px" : "300px"));
const selectedOptionLabel = computed(() => {
  const option = options.find(
    (option) => option.value === selectedOption.value
  );
  return option ? option.label : "";
});
const lastAiMessageId = computed(() => {
  const aiMessages = currentChatHistory.value.filter((m) => m.type === "ai");
  return aiMessages.length ? aiMessages[aiMessages.length - 1].id : null;
});

/* ------------------ 用户操作 ------------------ */
// 登录相关操作
const checkLogin = () => localStorage.getItem("isAuthenticated") === "true";
const getUserId = () => localStorage.getItem("user_id");
const tologin = async () => {
  try {
    await showConfirm({
      title: '退出登录',
      message: '确定要退出登录吗？',
      type: 'warning',
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      onConfirm: async () => {
        try {
          const response = await fetch(`${API_BASE_URL}/logout/`, {
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${localStorage.getItem('token')}`
            }
          });

          if (!response.ok) {
            throw new Error('退出登录失败');
          }

          localStorage.removeItem("isAuthenticated");
          localStorage.removeItem("user_id");
          localStorage.removeItem("token");
          localStorage.removeItem("mobile");
          localStorage.removeItem("generateMode");
          
          setTimeout(() => {
            router.push("/login");
          }, 200);
        } catch (error) {
          console.error("退出登录失败:", error);
          ElMessage.error("退出登录失败，请重试");
        }
      }
    });
  } catch (e) {
    // 移除非必要的日志
  }
};

// 页面导航
const goToWelcome = () => {
  router.push('/');
};

// 侧边栏操作
const toggleSidebar = () => {
  const scrollPos = scrollContainer.value ? scrollContainer.value.scrollTop : 0;
  document.body.classList.add('sidebar-transitioning');
  isCollapsed.value = !isCollapsed.value;
  nextTick(() => {
    if (scrollContainer.value) {
      scrollContainer.value.scrollTop = scrollPos;
    }
    setTimeout(() => {
      document.body.classList.remove('sidebar-transitioning');
    }, 350);
  });
};

// 生成模式切换
const handleChange = (value) => {
  if (value === "llm") {
    selectedOption.value = "大模型生成";
  } else if (value === "kb") {
    selectedOption.value = "知识库生成";
  }
  localStorage.setItem("generateMode", selectedOption.value);
};

/* ------------------ 消息处理 ------------------ */
// 消息发送相关
const handleEnter = (e) => !e.shiftKey && handleSendMessage();
const handleShiftEnter = (e) => e.shiftKey && null;

// 发送消息
const handleSendMessage = async () => {
  if (!checkLogin()) {
    showLoginPrompt.value = true;
    return;
  }
  if (!textarea2.value.trim()) return;
  isSending.value = true;

  try {
    // 如果没有会话ID，需要确定是新建会话还是使用现有会话
    if (!currentChatId.value) {
      // 检查是否有现有会话可以使用
      if (totalChatHistory.value.length > 0) {
        // 使用最近的会话
        const mostRecentSession = totalChatHistory.value[0];
        currentChatId.value = mostRecentSession.id;
        currentChatTitle.value = mostRecentSession.title;
        // 加载会话消息
        await loadChatSessionMessages(mostRecentSession.id);
      } else {
        // 没有现有会话，创建新会话
        const userId = getUserId();
        const title = `新对话`;
        
        const response = await fetch(`${API_BASE_URL}/chat/sessions`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            user_id: userId,
            title: title
          })
        });

        if (!response.ok) throw new Error("创建会话失败");
        
        const data = await response.json();
        currentChatId.value = data.id;
        currentChatTitle.value = data.title;
        
        // 添加到会话列表
        const newSession = {
          id: data.id,
          title: data.title,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        };
        
        totalChatHistory.value = [newSession, ...totalChatHistory.value];
      }
    }

    // 添加用户消息
    const userText = textarea2.value;
    const userMsgId = Date.now().toString();
    const aiMsgId = (Date.now() + 1).toString();
    
    // 创建用户消息对象
    const userMsg = {
      text: userText,
      type: "user",
      id: userMsgId,
      pairedAiId: aiMsgId,
    };
    
    // 创建AI占位消息对象
    const aiMsg = {
      text: "",
      type: "ai",
      id: aiMsgId,
      isLoading: true,
      parentId: userMsgId,
      references: [],
      question: userText,
    };
    
    // 添加消息到前端显示
    currentChatHistory.value.push(userMsg);
    currentChatHistory.value.push(aiMsg);
    
    // 保存用户消息到数据库
    await saveMessage(userMsg);
    
    // 保存空的AI占位消息到数据库
    await saveMessage(aiMsg);
    
    // 如果是会话的第一条消息，则使用这条消息的内容作为会话标题
    if (currentChatHistory.value.length === 2) {
      await updateSessionTitle(currentChatId.value, userText);
    }
    
    // 滚动到底部
    await nextTick(() => {
      scrollToBottom("auto");
    });
    
    textarea2.value = "";

    // 处理AI响应
    await processAIResponse(userText, aiMsg);
  } catch (error) {
    console.error("发送消息失败:", error);
    ElMessage.error("发送消息失败，请重试");
    isSending.value = false;
  }
};

// 停止消息
const handleStopMessage = () => {
  if (abortController) {
    abortController.abort();
    // 移除非必要的日志
  } else {
    // 移除非必要的日志
  }
  isSending.value = false;
};

// 重新生成消息
const regenerateResponse = async (aiMsgId) => {
  const aiMessage = currentChatHistory.value.find((msg) => msg.id === aiMsgId);
  if (!aiMessage) return;

  const userMessage = currentChatHistory.value.find(
    (msg) => msg.id === aiMessage.parentId
  );
  if (userMessage) {
    currentChatHistory.value = currentChatHistory.value.map((msg) =>
      msg.id === aiMsgId
        ? { ...msg, text: "", isLoading: true, references: [] }
        : msg
    );
    
    // 更新消息状态
    if (currentChatId.value) {
      const updatedAiMsg = currentChatHistory.value.find(msg => msg.id === aiMsgId);
      if (updatedAiMsg) {
        await updateMessage(updatedAiMsg);
      }
    }
    
    await processAIResponse(userMessage.text, aiMsgId);
  }
};




/* ------------------ API 调用 ------------------ */
// 处理AI响应
const processAIResponse = async (question, aiMsgOrId) => {
  abortController = new AbortController();
  isSending.value = true;
  
  try {
    // 确定aiMsg
    let aiMsg = aiMsgOrId;
    if (typeof aiMsgOrId === 'number' || typeof aiMsgOrId === 'string') {
      aiMsg = currentChatHistory.value.find((msg) => msg.id === aiMsgOrId);
      if (!aiMsg) {
        throw new Error("找不到对应的AI消息");
      }
    }
    
    // 移除非必要的日志
    
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
    let partialText = "";
    
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      buffer += decoder.decode(value, { stream: true });

      let newlineIndex;
      while ((newlineIndex = buffer.indexOf("\n")) !== -1) {
        const line = buffer.substring(0, newlineIndex);
        buffer = buffer.substring(newlineIndex + 1);

        try {
          const { type, data } = JSON.parse(line);

          if (type === "references") {
            // 更新前端显示的引用
            currentChatHistory.value = currentChatHistory.value.map((msg) =>
              msg.id === aiMsg.id ? { ...msg, references: data } : msg
            );
            
            // 此处不急于更新数据库中的消息，等待一些内容再更新
          } else if (type === "content") {
            partialText += data;
            
            // 更新前端显示的消息内容
            currentChatHistory.value = currentChatHistory.value.map((msg) =>
              msg.id === aiMsg.id ? { ...msg, text: partialText } : msg
            );
            
            // 每隔一段文本更新一次数据库（避免频繁更新）
            if (partialText.length % 100 === 0 && currentChatId.value) {
              const updatedMsg = currentChatHistory.value.find(msg => msg.id === aiMsg.id);
              if (updatedMsg) {
                // 移除非必要的日志
                await updateMessage(updatedMsg);
              }
            }
          } else if (type === "error") {
            partialText += data;
            
            // 更新前端显示的错误消息
            currentChatHistory.value = currentChatHistory.value.map((msg) =>
              msg.id === aiMsg.id ? { ...msg, text: partialText } : msg
            );
            
            // 出错时立即更新数据库
            if (currentChatId.value) {
              const updatedMsg = currentChatHistory.value.find(msg => msg.id === aiMsg.id);
              if (updatedMsg) {
                // 移除非必要的日志
                await updateMessage(updatedMsg);
              }
            }
          }
        } catch (e) {
          console.error("解析JSON失败:", e);
        }
      }

      await nextTick(() => scrollToBottom("auto"));
    }

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

    // 更新消息状态为完成
    currentChatHistory.value = currentChatHistory.value.map((msg) =>
      msg.id === aiMsg.id ? { ...msg, isLoading: false } : msg
    );
    
    // 保存完整的AI消息
    if (currentChatId.value) {
      const completedAiMsg = currentChatHistory.value.find(msg => msg.id === aiMsg.id);
      if (completedAiMsg) {
        // 移除非必要的日志
        await updateMessage(completedAiMsg);
      }
    }
  } catch (error) {
    if (error.name === "AbortError") {
      // 移除非必要的日志
      currentChatHistory.value = currentChatHistory.value.map((msg) =>
        msg.id === aiMsgOrId.id || msg.id === aiMsgOrId ? { ...msg, isLoading: false } : msg
      );
      
      // 更新消息状态
      if (currentChatId.value) {
        const abortedMsg = currentChatHistory.value.find(msg => 
          msg.id === (typeof aiMsgOrId === 'object' ? aiMsgOrId.id : aiMsgOrId));
        if (abortedMsg) {
          // 移除非必要的日志
          await updateMessage(abortedMsg);
        }
      }
      return;
    }
    console.error("流式传输出错:", error);
    currentChatHistory.value = currentChatHistory.value.map((msg) =>
      msg.id === aiMsgOrId.id || msg.id === aiMsgOrId
        ? { ...msg, text: msg.text + "\n[生成出错，请重试]", isLoading: false }
        : msg
    );
    
    // 更新错误消息
    if (currentChatId.value) {
      const errorMsg = currentChatHistory.value.find(msg => 
        msg.id === (typeof aiMsgOrId === 'object' ? aiMsgOrId.id : aiMsgOrId));
      if (errorMsg) {
        // 移除非必要的日志
        await updateMessage(errorMsg);
      }
    }
  } finally {
    isSending.value = false;
  }
};




/* ------------------ 工具方法 ------------------ */
// 滚动相关
const setupScrollListener = () => {
  const container = scrollContainer.value;
  if (container) {
    container.addEventListener("scroll", handleScroll);
  }
};

const handleScroll = () => {
  const container = scrollContainer.value;
  if (!container) return;
  
  const threshold = 50;
  const { scrollTop, scrollHeight, clientHeight } = container;
  const isNearBottom = scrollHeight - (scrollTop + clientHeight) < threshold;
  
  shouldAutoScroll.value = isNearBottom;
  showScrollButton.value = !isNearBottom && scrollHeight > clientHeight + 150;
};

const scrollToBottom = (behavior = "smooth") => {
  if (scrollContainer.value && shouldAutoScroll.value) {
    const container = scrollContainer.value;
    container.scrollTo({
      top: container.scrollHeight,
      behavior: behavior,
    });
  }
};

const handleScrollToBottom = () => {
  const container = scrollContainer.value;
  if (container) {
    container.scrollTo({
      top: container.scrollHeight,
      behavior: 'smooth'
    });
    shouldAutoScroll.value = true;
  }
};

// 确认框相关
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

const cancelConfirm = () => {
  showCustomConfirm.value = false;
};

// 判断是否为最后一条AI消息
const isLastAiMessage = (msg) => {
  return msg.type === "ai" && msg.id === lastAiMessageId.value;
};

/* ------------------ 聊天历史管理 ------------------ */
// 加载用户的所有聊天会话
const loadUserChatSessions = async () => {
  if (!checkLogin()) return;
  
  try {
    const userId = getUserId();
    const response = await fetch(`${API_BASE_URL}/chat/sessions/${userId}`);
    
    if (!response.ok) {
      throw new Error("获取会话列表失败");
    }
    
    const data = await response.json();
    totalChatHistory.value = data.sessions || [];
    
    // 按更新时间降序排序
    totalChatHistory.value.sort((a, b) => {
      return new Date(b.updated_at) - new Date(a.updated_at);
    });
  } catch (error) {
    console.error("加载聊天历史失败:", error);
    ElMessage.error("加载聊天历史失败");
  }
};

// 加载特定会话的消息
const loadChatSessionMessages = async (sessionId) => {
  try {
    const response = await fetch(`${API_BASE_URL}/chat/sessions/${sessionId}/messages`);
    
    if (!response.ok) {
      throw new Error("获取会话消息失败");
    }
    
    const data = await response.json();
    
    // 转换消息格式以适应前端展示
    const messages = (data.messages || []).map(msg => {
      // 解析 message_references 字符串为对象
      let references = [];
      try {
        if (msg.message_references) {
          // 检查类型，确保只对字符串使用 trim
          if (typeof msg.message_references === 'string' && msg.message_references.trim() !== '') {
            references = JSON.parse(msg.message_references);
          } else if (typeof msg.message_references === 'object') {
            // 已经是对象，直接使用
            references = msg.message_references;
          }
        }
      } catch (error) {
        console.error("解析 message_references 失败:", error, "原始数据:", msg.message_references);
        references = [];
      }
      
      return {
        id: msg.id,
        text: msg.content || "",
        type: msg.message_type,
        parentId: msg.parent_id,
        pairedAiId: msg.paired_ai_id,
        references: references, // 使用解析后的对象，如果解析失败则使用空数组
        question: msg.question || "",
        isLoading: Boolean(msg.is_loading),
        createdAt: msg.created_at
      };
    });
    
    currentChatHistory.value = messages;
    
    // 查找该会话的标题
    const session = totalChatHistory.value.find(s => s.id === sessionId);
    if (session) {
      currentChatTitle.value = session.title;
      
      // 检查标题是否为默认标题（包含"新对话"或"对话"字样）
      const isDefaultTitle = session.title === '新对话' || 
                            session.title.includes('对话 ');
      
      // 如果是默认标题且有消息记录，则用第一条用户消息更新标题
      if (isDefaultTitle && messages.length > 0) {
        // 查找第一条用户消息
        const firstUserMsg = messages.find(msg => msg.type === 'user');
        if (firstUserMsg && firstUserMsg.text) {
          await updateSessionTitle(sessionId, firstUserMsg.text);
        }
      }
    }
  } catch (error) {
    console.error("加载聊天消息失败:", error);
    ElMessage.error("加载聊天消息失败");
  }
};

// 创建新的聊天会话
const createNewChatSession = async () => {
  if (!checkLogin()) {
    showLoginPrompt.value = true;
    return;
  }
  
  try {
    // 创建新会话
    const userId = getUserId();
    const title = `新对话`;
    
    const response = await fetch(`${API_BASE_URL}/chat/sessions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        user_id: userId,
        title: title
      })
    });
    
    if (!response.ok) {
      throw new Error("创建会话失败");
    }
    
    const data = await response.json();
    
    // 添加到会话列表
    const newSession = {
      id: data.id,
      title: data.title,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    
    totalChatHistory.value = [newSession, ...totalChatHistory.value];
    
    // 切换到新会话
    await selectChatSession(data.id);
    
    // 提示用户
    ElMessage.success("已创建新对话");
  } catch (error) {
    console.error("创建新会话失败:", error);
    ElMessage.error("创建新会话失败");
  }
};

// 选择聊天会话
const selectChatSession = async (sessionId) => {
  if (sessionId === currentChatId.value) return;
  
  // 清空当前消息列表
  currentChatHistory.value = [];
  
  // 设置当前会话ID
  currentChatId.value = sessionId;
  
  // 加载会话消息
  await loadChatSessionMessages(sessionId);
  
  // 滚动到底部
  await nextTick(() => {
    scrollToBottom("auto");
  });
  
  // 聚焦输入框
  if (inputRef.value) {
    inputRef.value.focus();
  }
};

// 删除聊天会话
const deleteChatSession = async (sessionId) => {
  try {
    await showConfirm({
      title: '删除对话',
      message: '确定要删除这个对话吗？此操作不可恢复。',
      type: 'danger',
      confirmButtonText: '确定删除',
      cancelButtonText: '取消',
      onConfirm: async () => {
        try {
          const response = await fetch(`${API_BASE_URL}/chat/sessions/${sessionId}`, {
            method: 'DELETE'
          });
          
          if (!response.ok) {
            throw new Error("删除会话失败");
          }
          
          // 从列表中移除
          totalChatHistory.value = totalChatHistory.value.filter(s => s.id !== sessionId);
          
          // 如果删除的是当前会话，则清空当前消息
          if (sessionId === currentChatId.value) {
            currentChatHistory.value = [];
            currentChatId.value = null;
            currentChatTitle.value = "";
          }
          
          ElMessage.success("对话已删除");
        } catch (error) {
          console.error("删除会话失败:", error);
          ElMessage.error("删除会话失败");
        }
      }
    });
  } catch (e) {
    // 移除非必要的日志
  }
};

// 清除所有聊天历史
const clearAllChatHistory = async () => {
  if (!checkLogin()) {
    showLoginPrompt.value = true;
    return;
  }
  
  if (totalChatHistory.value.length === 0) {
    ElMessage.info("暂无历史对话可清除");
    return;
  }
  
  try {
    await showConfirm({
      title: '清除所有历史',
      message: '确定要清除所有对话历史吗？此操作不可恢复。',
      type: 'danger',
      confirmButtonText: '确定清除',
      cancelButtonText: '取消',
      onConfirm: async () => {
        try {
          const userId = getUserId();
          const response = await fetch(`${API_BASE_URL}/chat/sessions/user/${userId}`, {
            method: 'DELETE'
          });
          
          if (!response.ok) {
            throw new Error("清除历史失败");
          }
          
          // 清空会话列表和当前消息
          totalChatHistory.value = [];
          currentChatHistory.value = [];
          currentChatId.value = null;
          currentChatTitle.value = "";
          
          ElMessage.success("所有历史对话已清除");
        } catch (error) {
          console.error("清除历史失败:", error);
          ElMessage.error("清除历史失败");
        }
      }
    });
  } catch (e) {
    // 移除非必要的日志
  }
};

// 保存消息到数据库
const saveMessage = async (message) => {
  if (!currentChatId.value) {
    console.warn("无法保存消息：当前没有活动的会话ID");
    return;
  }
  
  try {
    // 处理 references 字段，将对象转换为 JSON 字符串
    let referencesJson = '[]';
    if (message.references) {
      try {
        referencesJson = JSON.stringify(message.references);
      } catch (error) {
        console.error("序列化 references 失败:", error);
        referencesJson = '[]';
      }
    }
    
    const messageData = {
      id: message.id,
      session_id: currentChatId.value,
      message_type: message.type,
      content: message.text,
      parent_id: message.parentId || null,
      paired_ai_id: message.pairedAiId || null,
      message_references: referencesJson,
      question: message.question || null,
      is_loading: message.isLoading || false
    };
    
    // 移除非必要的日志
    
    const response = await fetch(`${API_BASE_URL}/chat/messages`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(messageData)
    });
    
    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      console.error("保存消息失败，状态码:", response.status, "错误详情:", errorData);
      throw new Error(`保存消息失败: ${response.status} ${response.statusText}`);
    } else {
      // 移除非必要的日志
    }
  } catch (error) {
    console.error(`保存消息失败 ID=${message.id}:`, error);
  }
};

// 更新消息
const updateMessage = async (message) => {
  if (!currentChatId.value) {
    console.warn("无法更新消息：当前没有活动的会话ID");
    return;
  }
  
  try {
    // 处理 references 字段，将对象转换为 JSON 字符串
    let referencesJson = '[]';
    if (message.references) {
      try {
        referencesJson = JSON.stringify(message.references);
      } catch (error) {
        console.error("序列化 references 失败:", error);
        referencesJson = '[]';
      }
    }
    
    const messageData = {
      content: message.text,
      message_references: referencesJson,
      is_loading: message.isLoading
    };
    
    // 移除非必要的日志
    
    const response = await fetch(`${API_BASE_URL}/chat/messages/${message.id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(messageData)
    });
    
    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      console.error("更新消息失败，状态码:", response.status, "错误详情:", errorData);
      throw new Error(`更新消息失败: ${response.status} ${response.statusText}`);
    } else {
      // 移除非必要的日志
    }
  } catch (error) {
    console.error(`更新消息失败 ID=${message.id}:`, error);
  }
};

// 编辑对话标题
const startEditingTitle = () => {
  if (!currentChatId.value) return;
  
  editingTitle.value = currentChatTitle.value;
  isEditingTitle.value = true;
  
  nextTick(() => {
    if (titleInputRef.value) {
      titleInputRef.value.focus();
    }
  });
};

const saveEditedTitle = async () => {
  if (!currentChatId.value || !isEditingTitle.value) return;
  
  // 去除前后空格
  const newTitle = editingTitle.value.trim();
  
  // 如果为空，使用默认标题
  if (!newTitle) {
    editingTitle.value = `对话 ${new Date().toLocaleTimeString()}`;
  }
  
  try {
    const response = await fetch(`${API_BASE_URL}/chat/sessions/${currentChatId.value}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        title: editingTitle.value
      })
    });
    
    if (!response.ok) {
      throw new Error("更新标题失败");
    }
    
    // 更新当前标题
    currentChatTitle.value = editingTitle.value;
    
    // 更新总会话列表中的标题
    totalChatHistory.value = totalChatHistory.value.map(session => {
      if (session.id === currentChatId.value) {
        return { ...session, title: editingTitle.value };
      }
      return session;
    });
  } catch (error) {
    console.error("更新标题失败:", error);
    ElMessage.error("更新标题失败");
  } finally {
    isEditingTitle.value = false;
  }
};

const cancelEditingTitle = () => {
  isEditingTitle.value = false;
};

// 新增：更新会话标题为第一条消息内容
const updateSessionTitle = async (sessionId, messageText) => {
  if (!sessionId) return;
  
  try {
    // 截取消息的前20个字符作为标题
    let title = messageText.trim();
    if (title.length > 20) {
      title = title.substring(0, 20) + "...";
    }
    
    // 更新数据库中的会话标题
    const response = await fetch(`${API_BASE_URL}/chat/sessions/${sessionId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        title: title
      })
    });
    
    if (!response.ok) {
      throw new Error("更新会话标题失败");
    }
    
    // 更新前端显示
    currentChatTitle.value = title;
    
    // 更新会话列表中的标题
    totalChatHistory.value = totalChatHistory.value.map(session => {
      if (session.id === sessionId) {
        return { ...session, title: title };
      }
      return session;
    });
    
    // 移除非必要的日志
  } catch (error) {
    console.error("更新会话标题失败:", error);
  }
};

/* ------------------ 初始化相关 ------------------ */
// 组件挂载时执行
onMounted(async () => {
  try {
    const mobile = localStorage.getItem("mobile");
    const generateMode = localStorage.getItem("generateMode");
    if (generateMode) {
      selectedOption.value = generateMode;
    }
    if (mobile) {
      UserName = mobile;
    }
    
    // 加载用户的所有聊天历史
    if (checkLogin()) {
      await loadUserChatSessions();
      
      // 如果有历史会话且没有指定当前会话，自动选择最近的一个
      if (totalChatHistory.value.length > 0 && !currentChatId.value) {
        // 历史会话已按更新时间降序排序，所以第一个就是最近的
        const mostRecentSession = totalChatHistory.value[0];
        await selectChatSession(mostRecentSession.id);
      }
    }
    
    setupScrollListener();
    nextTick(() => {
      scrollToBottom();
    });

    if (inputRef.value) {
      inputRef.value.focus();
    }
  } catch (error) {
    console.error("初始化过程中发生了错误:", error);
  }
});

// 组件卸载前执行
onBeforeUnmount(() => {
  const container = scrollContainer.value;
  if (container) {
    container.removeEventListener("scroll", handleScroll);
  }
});
</script>

<style scoped lang="less">
@import '../styles/chat.less';
</style>