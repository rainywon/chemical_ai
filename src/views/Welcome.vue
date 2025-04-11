<template>
  <div class="welcome-container">
    <div class="welcome-content">
      <!-- 系统概览区域 -->
      <div class="system-overview">
        <AppHeader 
          :current-theme="currentTheme" 
          @toggle-theme="toggleTheme" 
          @show-feedback="showFeedback = true" 
          @logout="logout" 
        />
        <SystemStatusCard />
      </div>
      
      <!-- 功能模块区域 -->
      <div class="features-grid">
        <!-- 智能问答模块 - 占据左半边 -->
        <AIFeatureCard />

        <!-- 右半边容器 -->
        <div class="right-side">
          <!-- 安全资料库模块 -->
          <FileLibraryCard />

          <!-- 应急处理模块 -->
          <EmergencyResponseCard />
        </div>
      </div>
      
      <!-- 反馈弹窗 -->
      <ModalFeedback 
        :show="showFeedback" 
        @close="showFeedback = false" 
        @submit-success="handleFeedbackSuccess" 
      />
      
      <!-- 退出登录确认弹窗 -->
      <ModalConfirm
        :show="showConfirmModal"
        :message="confirmMessage"
        @confirm="confirmLogout"
        @cancel="showConfirmModal = false"
      />
      
      <!-- 反馈提交成功通知 -->
      <NotificationToast
        :show="showSuccessNotification"
        title="提交成功"
        message="感谢您的反馈！我们会认真考虑您的意见。"
        type="success"
        :duration="3000"
        @close="showSuccessNotification = false"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';

// 导入组件
import AppHeader from '@/components/AppHeader.vue';
import SystemStatusCard from '@/components/SystemStatusCard.vue';
import AIFeatureCard from '@/components/AIFeatureCard.vue';
import FileLibraryCard from '@/components/FileLibraryCard.vue';
import EmergencyResponseCard from '@/components/EmergencyResponseCard.vue';
import ModalFeedback from '@/components/ModalFeedback.vue';
import ModalConfirm from '@/components/ModalConfirm.vue';
import NotificationToast from '@/components/NotificationToast.vue';

// 路由
const router = useRouter();

// 状态变量
const showFeedback = ref(false);
const showConfirmModal = ref(false);
const confirmMessage = ref('');
const currentTheme = ref('light');
const showSuccessNotification = ref(false);

// 检查并应用已保存的主题
onMounted(() => {
  // 检查本地存储中的主题设置
  const savedTheme = localStorage.getItem('appTheme');
  if (savedTheme) {
    currentTheme.value = savedTheme;
    applyTheme(savedTheme);
  }
  
  // 检查系统首选主题
  if (!savedTheme && window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
    currentTheme.value = 'dark';
    applyTheme('dark');
  }
});

// 应用主题
const applyTheme = (theme) => {
  if (theme === 'dark') {
    document.body.classList.add('dark-theme');
  } else {
    document.body.classList.remove('dark-theme');
  }
  // 保存主题设置到本地存储
  localStorage.setItem('appTheme', theme);
};

// 切换主题
const toggleTheme = () => {
  const newTheme = currentTheme.value === 'light' ? 'dark' : 'light';
  currentTheme.value = newTheme;
  applyTheme(newTheme);
};

// 处理反馈成功
const handleFeedbackSuccess = () => {
  showSuccessNotification.value = true;
};

// 显示确认对话框
const showConfirm = (message) => {
  confirmMessage.value = message;
  showConfirmModal.value = true;
};

// 确认操作
const confirmLogout = () => {
  // 设置认证状态为false
  localStorage.setItem("isAuthenticated", "false");
  
  // 跳转到登录页面
  setTimeout(() => {
    router.push("/login");
  }, 200);
};

// 退出登录
const logout = () => {
  showConfirm('确定要退出登录吗？');
};
</script>

<style scoped>
.welcome-container {
  height: 100vh;
  background: linear-gradient(135deg, #f0f4fa 0%, #e6ebf5 100%);
  padding: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  box-sizing: border-box;
}

.welcome-content {
  max-width: 1400px;
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 24px;
  max-height: calc(100vh - 48px);
}

/* 系统概览样式 */
.system-overview {
  background: white;
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.06);
}

/* 功能模块网格样式 */
.features-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  overflow: hidden;
  flex: 1;
  height: calc(100vh - 200px);
}

.right-side {
  grid-column: 2;
  grid-row: 1;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  max-height: calc(100vh - 200px);
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .features-grid {
    grid-template-columns: 1fr 1fr;
  }
}

@media (max-width: 900px) {
  .features-grid {
    grid-template-columns: 1fr;
    height: auto;
  }
  
  .right-side {
    grid-column: 1;
    grid-row: auto;
    grid-template-columns: 1fr;
    max-height: none;
  }
}

/* 暗色模式适配 */
body.dark-theme {
  background: #111827;
  color: #f3f4f6;
}

body.dark-theme .welcome-container {
  background: linear-gradient(135deg, #1f2937 0%, #111827 100%);
}

body.dark-theme .system-overview {
  background: #1f2937;
}
</style> 