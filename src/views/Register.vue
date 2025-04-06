<template>
  <div class="register">
    <!-- 添加科技感网格背景 -->
    <div class="tech-grid"></div>
    
    <!-- 添加光晕效果 -->
    <div class="glow-effect"></div>
    
    <!-- 添加背景特效 -->
    <div class="neural-network">
      <div v-for="n in 20" :key="`node-${n}`" class="node" :style="{
        left: `${Math.random() * 100}%`,
        top: `${Math.random() * 100}%`,
        opacity: 0.3 + Math.random() * 0.7
      }"></div>
      <div v-for="n in 30" :key="`connection-${n}`" class="connection" :style="{
        left: `${Math.random() * 100}%`,
        top: `${Math.random() * 100}%`,
        width: `${50 + Math.random() * 150}px`,
        transform: `rotate(${Math.random() * 360}deg)`,
        opacity: 0.1 + Math.random() * 0.3
      }"></div>
    </div>
    
    <div class="register-container">
      <!-- 标题 -->
      <div class="img-title">
        <img src="../assets/product.png" alt="" />
        <span>账号注册</span>
      </div>

      <!-- 表单 -->
      <div class="register-form">
        <!-- 步骤提示 -->
        <div class="step-indicator">
          <div class="step completed">
            <div class="step-number">1</div>
            <div class="step-label">输入手机号</div>
          </div>
          <div class="step-line"></div>
          <div class="step active">
            <div class="step-number">2</div>
            <div class="step-label">设置信息</div>
          </div>
          <div class="step-line"></div>
          <div class="step">
            <div class="step-number">3</div>
            <div class="step-label">完成注册</div>
          </div>
        </div>

        <!-- 手机号 -->
        <div class="form-item">
          <el-input 
            v-model="formData.phone" 
            class="input-field" 
            placeholder="请输入11位手机号" 
            :prefix-icon="PhoneFilled"
            size="large" 
            @input="handlePhoneInput"
            type="tel"
            name="phone"
            autocomplete="tel"
            maxlength="11"
          />
        </div>
        
        <!-- 验证码 -->
        <div class="form-item">
          <!-- 验证码输入 -->
          <el-input v-model="formData.verificationCode" class="input-field" placeholder="请输入6位数验证码"
            :prefix-icon="Key" size="large" @input="handleVerificationCodeInput" />
          <!-- 发送验证码按钮 -->
          <el-button type="primary" class="verification-btn" :disabled="isCodeSent || !isPhoneValid"
            @click="sendVerificationCode">
            {{ isCodeSent ? countdownText : '发送验证码' }}
          </el-button>
        </div>
        
        <!-- 密码 -->
        <div class="form-item">
          <el-input 
            v-model="formData.password" 
            class="input-field" 
            placeholder="请输入密码（至少6位）" 
            :prefix-icon="Lock" 
            size="large" 
            type="password"
            show-password
            name="password"
            autocomplete="new-password"
          />
        </div>
        
        <!-- 确认密码 -->
        <div class="form-item">
          <el-input 
            v-model="formData.confirmPassword" 
            class="input-field" 
            placeholder="请再次输入密码" 
            :prefix-icon="Lock" 
            size="large" 
            type="password"
            show-password
            name="confirmPassword"
            autocomplete="new-password"
          />
        </div>
      </div>
      
      <!-- 结果信息 -->
      <div v-if="resultMessage" :class="['result-message', messageType]">
        {{ resultMessage }}
      </div>

      <!-- 隐私协议 -->
      <div class="privacy-agreement">
        <el-checkbox v-model="formData.agreed" class="checkbox">
          我已阅读并同意《用户协议》和《隐私政策》
        </el-checkbox>
      </div>

      <!-- 按钮组 -->
      <div class="button-group">
        <!-- 注册按钮 -->
        <el-button type="primary" class="action-btn register-btn"
          :disabled="!isFormValid" @click="register" :loading="loading">
          立即注册
        </el-button>
        
        <!-- 返回登录 -->
        <el-button type="default" class="action-btn back-btn"
          @click="goToLogin">
          返回登录
        </el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onUnmounted } from "vue";
import { PhoneFilled, Key, Lock } from "@element-plus/icons-vue";
import { useRouter } from "vue-router";
import { API_BASE_URL } from "../config";
import axios from "axios";
import { ElMessage } from 'element-plus';

const router = useRouter();

// 表单数据
const formData = reactive({
  phone: "",
  verificationCode: "",
  password: "",
  confirmPassword: "",
  agreed: false,
});

// 表单验证
const isPhoneValid = computed(() => {
  return /^1[3-9]\d{9}$/.test(formData.phone);
});

const isVerificationCodeValid = computed(() => {
  return /^\d{6}$/.test(formData.verificationCode);
});

const isPasswordValid = computed(() => {
  return formData.password.length >= 6;
});

const isConfirmPasswordValid = computed(() => {
  return formData.password === formData.confirmPassword && formData.confirmPassword.length > 0;
});

// 表单整体验证
const isFormValid = computed(() => {
  return isPhoneValid.value && 
         isVerificationCodeValid.value && 
         isPasswordValid.value && 
         isConfirmPasswordValid.value && 
         formData.agreed;
});

// 输入处理
const handlePhoneInput = (value) => {
  if (typeof value === 'string') {
    // 移除所有非数字字符
    const digitsOnly = value.replace(/\D/g, "");
    
    // 如果以86开头且长度超过11位，则去掉前面的86
    if (digitsOnly.startsWith('86') && digitsOnly.length > 11) {
      formData.phone = digitsOnly.substring(2).slice(0, 11);
    } else {
      // 否则直接取最后11位数字
      formData.phone = digitsOnly.slice(-11);
    }
  }
};

const handleVerificationCodeInput = (value) => {
  formData.verificationCode = value.replace(/\D/g, "").slice(0, 6);
};

// 验证码相关状态
const resultMessage = ref("");
const messageType = ref("info");
const countdown = ref(60);
const isCodeSent = ref(false);
let timer = null;

const countdownText = computed(() => {
  return `${countdown.value.toString().padStart(2, "0")}`;
});

// 清理定时器
onUnmounted(() => {
  if (timer) clearInterval(timer);
});

// 发送验证码
const sendVerificationCode = async () => {
  // 清空之前的提示信息
  resultMessage.value = "";

  // 检查手机号格式
  if (!isPhoneValid.value) {
    resultMessage.value = "请输入有效的11位手机号";
    messageType.value = "warning";
    return;
  }

  // 发送验证码
  try {
    // 提示用户正在发送验证码
    resultMessage.value = "正在发送验证码...";
    messageType.value = "info";

    const response = await axios.post(`${API_BASE_URL}/send_sms/`, {
      mobile: formData.phone,
      type: 'register' // 指定是注册用的验证码
    });

    if (response.status === 200) {
      resultMessage.value = "验证码已发送，请查收";
      messageType.value = "success";
      // 启动倒计时
      isCodeSent.value = true;
      countdown.value = 60;
      if (timer) clearInterval(timer);
      timer = setInterval(() => {
        countdown.value--;
        if (countdown.value <= 0) {
          clearInterval(timer);
          isCodeSent.value = false;
          resultMessage.value = ""; // 清除发送成功提示
        }
      }, 1000);
    } else {
      resultMessage.value = "验证码发送失败，请稍后重试";
      messageType.value = "error";
    }
  } catch (error) {
    // 网络请求失败的处理
    if (error.response) {
      resultMessage.value = error.response.data.message || "验证码发送失败";
    } else {
      resultMessage.value = "网络连接异常，请检查网络";
    }
    messageType.value = "error";
  }
};

// 注册处理
const loading = ref(false);

const register = async () => {
  // 验证表单
  if (!isPhoneValid.value) {
    resultMessage.value = "请输入有效的11位手机号";
    messageType.value = "warning";
    return;
  }

  if (!isVerificationCodeValid.value) {
    resultMessage.value = "验证码必须是6位数字";
    messageType.value = "warning";
    return;
  }

  if (!isPasswordValid.value) {
    resultMessage.value = "密码长度不能少于6位";
    messageType.value = "warning";
    return;
  }

  if (!isConfirmPasswordValid.value) {
    resultMessage.value = "两次输入的密码不一致";
    messageType.value = "warning";
    return;
  }

  if (!formData.agreed) {
    resultMessage.value = "请阅读并同意用户协议和隐私政策";
    messageType.value = "warning";
    return;
  }

  // 发送注册请求
  try {
    loading.value = true;
    resultMessage.value = "正在注册...";
    messageType.value = "info";
    
    const response = await axios.post(`${API_BASE_URL}/register/`, {
      mobile: formData.phone,
      code: formData.verificationCode,
      password: formData.password,
      confirm_password: formData.confirmPassword
    });

    if (response.data.code === 200) {
      // 注册成功，自动登录
      localStorage.setItem("isAuthenticated", "true");
      localStorage.setItem("mobile", formData.phone);
      if (response.data.token) {
        localStorage.setItem("token", response.data.token);
      }
      
      resultMessage.value = "注册成功，正在跳转...";
      messageType.value = "success";
      
      // 显示注册成功提示
      ElMessage.success('注册成功');
      
      // 跳转到首页
      setTimeout(() => {
        router.push("/chat");
      }, 1000);
    } else {
      resultMessage.value = response.data.message || "注册失败";
      messageType.value = "error";
    }
  } catch (error) {
    if (error.response) {
      resultMessage.value = error.response.data.message || "注册失败，请稍后重试";
    } else {
      resultMessage.value = "网络连接异常，请检查网络";
    }
    messageType.value = "error";
  } finally {
    loading.value = false;
  }
};

// 返回登录页
const goToLogin = () => {
  router.push('/login');
};
</script>

<style scoped>
/* 整体页面背景 */
.register {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  background: linear-gradient(125deg, #0b1437 0%, #172554 50%, #1e3a8a 100%);
  overflow: hidden;
  position: relative;
}

/* 科技感网格背景 */
.tech-grid {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-image: 
    linear-gradient(rgba(99, 102, 241, 0.05) 1px, transparent 1px),
    linear-gradient(90deg, rgba(99, 102, 241, 0.05) 1px, transparent 1px);
  background-size: 40px 40px;
  z-index: 0;
  perspective: 1000px;
  transform-style: preserve-3d;
  animation: gridMove 60s linear infinite;
}

@keyframes gridMove {
  0% {
    background-position: 0 0;
  }
  100% {
    background-position: 40px 40px;
  }
}

/* 神经网络效果 */
.neural-network {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 0;
  overflow: hidden;
}

.node {
  position: absolute;
  width: 4px;
  height: 4px;
  background-color: rgba(255, 255, 255, 0.4);
  border-radius: 50%;
  box-shadow: 0 0 10px rgba(147, 197, 253, 0.6);
  z-index: 1;
}

.connection {
  position: absolute;
  height: 1px;
  background: linear-gradient(90deg, rgba(147, 197, 253, 0.1), rgba(147, 197, 253, 0.3), rgba(147, 197, 253, 0.1));
  transform-origin: left center;
  z-index: 0;
}

/* 光晕效果 */
.glow-effect {
  position: absolute;
  width: 100%;
  height: 100%;
  top: 0;
  left: 0;
  background: 
    radial-gradient(circle at 20% 20%, rgba(56, 189, 248, 0.1) 0%, transparent 50%),
    radial-gradient(circle at 80% 80%, rgba(168, 85, 247, 0.1) 0%, transparent 50%),
    radial-gradient(circle at 50% 50%, rgba(59, 130, 246, 0.05) 0%, transparent 70%);
  filter: blur(40px);
  z-index: 0;
  animation: glowPulse 15s infinite alternate;
}

@keyframes glowPulse {
  0% {
    opacity: 0.7;
  }
  50% {
    opacity: 1;
  }
  100% {
    opacity: 0.7;
  }
}

/* 注册容器 */
.register-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 100%;
  max-width: 450px;
  padding: 45px;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(12px);
  border-radius: 24px;
  box-shadow: 
    0 10px 30px rgba(0, 0, 0, 0.08), 
    0 1px 8px rgba(0, 0, 0, 0.03),
    0 0 0 1px rgba(255, 255, 255, 0.9) inset;
  margin-top: 0;
  overflow: visible;
  position: relative;
  z-index: 1;
  transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
  border: 1px solid rgba(255, 255, 255, 0.9);
}

.register-container:hover {
  box-shadow: 
    0 20px 40px rgba(0, 0, 0, 0.1), 
    0 5px 15px rgba(0, 0, 0, 0.05),
    0 0 0 1px rgba(255, 255, 255, 0.95) inset;
  transform: translateY(-5px);
}

/* 标题样式 */
.img-title {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 30px;
  position: relative;
  width: 100%;
}

.img-title::after {
  content: '';
  position: absolute;
  bottom: -15px;
  left: 50%;
  transform: translateX(-50%);
  width: 70px;
  height: 3px;
  background: linear-gradient(90deg, #3b82f6, #60a5fa, #93c5fd);
  border-radius: 3px;
}

.img-title img {
  width: 55px;
  height: 55px;
  margin-right: 18px;
  filter: drop-shadow(0 4px 8px rgba(0, 0, 0, 0.15));
}

.img-title span {
  font-size: 26px;
  font-weight: 800;
  color: #1e293b;
  letter-spacing: 0.5px;
  background: linear-gradient(135deg, #1e293b, #475569);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

/* 步骤指示器 */
.step-indicator {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  margin-bottom: 30px;
}

.step {
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
}

.step-number {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  background-color: #e2e8f0;
  color: #64748b;
  margin-bottom: 8px;
  transition: all 0.3s ease;
}

.step.active .step-number {
  background-color: #3b82f6;
  color: white;
  box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.2);
}

.step.completed .step-number {
  background-color: #10b981;
  color: white;
}

.step-label {
  font-size: 14px;
  color: #64748b;
  font-weight: 500;
}

.step.active .step-label {
  color: #3b82f6;
  font-weight: 600;
}

.step.completed .step-label {
  color: #10b981;
}

.step-line {
  flex: 1;
  height: 2px;
  background-color: #e2e8f0;
  margin: 0 10px;
  margin-bottom: 20px;
}

/* 表单样式 */
.register-form {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 100%;
}

.form-item {
  display: flex;
  flex-direction: row;
  align-items: center;
  width: 100%;
  margin-bottom: 22px;
  position: relative;
}

/* 输入框样式 */
.input-field {
  width: 100%;
  height: 54px;
  font-size: 15px;
  border-radius: 14px !important;
  background: rgba(255, 255, 255, 0.9) !important;
  border: 1px solid rgba(226, 232, 240, 0.8) !important;
  box-shadow: 
    0 2px 6px rgba(0, 0, 0, 0.03), 
    0 0 0 1px rgba(255, 255, 255, 0.8) inset !important;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1) !important;
  padding-left: 16px !important;
}

.input-field:focus {
  border-color: #3b82f6 !important;
  box-shadow: 
    0 0 0 3px rgba(59, 130, 246, 0.25), 
    0 2px 8px rgba(0, 0, 0, 0.05) !important;
  background: #ffffff !important;
  transform: translateY(-1px);
}

/* 验证码按钮 */
.verification-btn {
  margin-left: 12px;
  height: 54px;
  min-width: 120px;
  border-radius: 14px !important;
  background: linear-gradient(135deg, #3b82f6, #2563eb) !important;
  border: none !important;
  color: white !important;
  font-weight: 600 !important;
  letter-spacing: 0.5px;
  box-shadow: 
    0 4px 12px rgba(37, 99, 235, 0.25), 
    0 2px 4px rgba(37, 99, 235, 0.1) !important;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1) !important;
  position: relative;
  overflow: hidden;
}

.verification-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 
    0 6px 18px rgba(37, 99, 235, 0.3), 
    0 2px 6px rgba(37, 99, 235, 0.2) !important;
  background: linear-gradient(135deg, #2563eb, #1d4ed8) !important;
}

.verification-btn:active:not(:disabled) {
  transform: translateY(0);
}

/* 禁用状态 */
.verification-btn:disabled {
  background: linear-gradient(135deg, #93c5fd, #bfdbfe) !important;
  color: #eff6ff !important;
  box-shadow: none !important;
  cursor: not-allowed;
}

/* 结果消息 */
.result-message {
  padding: 12px 16px;
  border-radius: 12px;
  font-size: 14px;
  line-height: 1.5;
  margin-bottom: 18px;
  width: 100%;
  text-align: left;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  position: relative;
  overflow: hidden;
}

.result-message.success {
  background: rgba(236, 253, 245, 0.7);
  border-left: 3px solid #10b981;
  color: #065f46;
}

.result-message.info {
  background: rgba(236, 246, 255, 0.7);
  border-left: 3px solid #3b82f6;
  color: #1e40af;
}

.result-message.warning {
  background: rgba(255, 251, 235, 0.7);
  border-left: 3px solid #f59e0b;
  color: #92400e;
}

.result-message.error {
  background: rgba(254, 226, 226, 0.7);
  border-left: 3px solid #ef4444;
  color: #b91c1c;
}

/* 隐私协议 */
.privacy-agreement {
  margin-bottom: 25px;
  width: 100%;
}

.checkbox {
  font-size: 14px;
  color: #64748b;
  text-align: left;
  word-wrap: break-word;
  word-break: break-word;
  transition: color 0.3s ease;
}

.checkbox:hover {
  color: #475569;
}

/* 按钮组 */
.button-group {
  display: flex;
  width: 100%;
  gap: 15px;
  margin-top: 10px;
}

.action-btn {
  flex: 1;
  height: 54px !important;
  border-radius: 14px !important;
  font-weight: 600 !important;
  letter-spacing: 0.5px;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1) !important;
  position: relative;
  overflow: hidden;
  font-size: 16px !important;
}

/* 注册按钮 */
.register-btn {
  background: linear-gradient(135deg, #3b82f6, #2563eb) !important;
  border: none !important;
  color: white !important;
  box-shadow: 
    0 4px 12px rgba(37, 99, 235, 0.25), 
    0 2px 4px rgba(37, 99, 235, 0.1) !important;
}

.register-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 
    0 8px 20px rgba(37, 99, 235, 0.3), 
    0 4px 8px rgba(37, 99, 235, 0.2) !important;
  background: linear-gradient(135deg, #2563eb, #1d4ed8) !important;
}

.register-btn:active:not(:disabled) {
  transform: translateY(0);
}

.register-btn:disabled {
  background: linear-gradient(135deg, #93c5fd, #bfdbfe) !important;
  color: #eff6ff !important;
  box-shadow: none !important;
  cursor: not-allowed;
}

/* 返回按钮 */
.back-btn {
  background: rgba(255, 255, 255, 0.8) !important;
  border: 1px solid #e2e8f0 !important;
  color: #475569 !important;
  box-shadow: 
    0 2px 6px rgba(0, 0, 0, 0.03), 
    0 0 0 1px rgba(255, 255, 255, 0.8) inset !important;
}

.back-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  background: #f8fafc !important;
  border-color: #cbd5e1 !important;
  color: #334155 !important;
  box-shadow: 
    0 4px 12px rgba(0, 0, 0, 0.05), 
    0 0 0 1px rgba(255, 255, 255, 0.9) inset !important;
}

.back-btn:active:not(:disabled) {
  transform: translateY(0);
}

/* 响应式调整 */
@media (max-width: 480px) {
  .register-container {
    max-width: 90%;
    padding: 35px 20px;
  }
  
  .img-title img {
    width: 45px;
    height: 45px;
  }
  
  .img-title span {
    font-size: 22px;
  }
  
  .form-item {
    flex-direction: column;
    align-items: stretch;
  }
  
  .verification-btn {
    margin-left: 0;
    margin-top: 12px;
    width: 100%;
  }
  
  .button-group {
    flex-direction: column;
    gap: 10px;
  }
  
  .step-label {
    font-size: 12px;
  }
}
</style>
