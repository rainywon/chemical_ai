<template>
  <div class="login">
    <!-- 添加科技感网格背景 -->
    <div class="tech-grid"></div>
    
    <!-- 添加光晕效果 -->
    <div class="glow-effect"></div>
    
    <!-- 添加神经网络效果 -->
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
    
    <!-- 添加浮动圆环 -->
    <div class="floating-rings">
      <div class="ring"></div>
      <div class="ring"></div>
      <div class="ring"></div>
    </div>
    
    <!-- 添加数据流效果 -->
    <div class="data-stream">
      <div v-for="n in 15" :key="`data-${n}`" class="data-line" :style="{
        left: `${Math.random() * 100}%`,
        top: `${Math.random() * 100}%`,
        width: `${100 + Math.random() * 200}px`,
        transform: `rotate(${Math.random() * 360}deg)`,
        animationDelay: `${Math.random() * 8}s`,
        opacity: 0.1 + Math.random() * 0.3
      }"></div>
    </div>
    
    <!-- 添加浮动粒子 -->
    <div class="floating-particles">
      <div v-for="n in 30" :key="`particle-${n}`" class="particle" :style="{
        left: `${Math.random() * 100}%`,
        top: `${Math.random() * 100}%`,
        animationDelay: `${Math.random() * 5}s`,
        animationDuration: `${10 + Math.random() * 10}s`
      }"></div>
    </div>
    
    <div class="login-container">
      <!-- 标题 -->
      <div class="img-title">
        <img src="../assets/product.png" alt="" />
        <span>天工AI智能助手</span>
      </div>

      <!-- 登录方式切换 -->
      <div class="login-type-selector">
        <el-radio-group v-model="loginByPassword" size="large" @change="toggleLoginType">
          <el-radio-button :label="false">验证码登录</el-radio-button>
          <el-radio-button :label="true">密码登录</el-radio-button>
        </el-radio-group>
      </div>

      <!-- 表单提交 -->
      <div class="table-submit">
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
        
        <!-- 使用固定高度容器包裹切换的表单元素 -->
        <div class="form-container">
          <!-- 密码输入框 - 仅在密码登录模式下显示 -->
          <div v-if="loginByPassword" class="form-item">
            <el-input 
              v-model="formData.password" 
              class="input-field" 
              placeholder="请输入密码" 
              :prefix-icon="Lock" 
              size="large" 
              type="password"
              show-password
              name="password"
              autocomplete="new-password"
            />
          </div>
          
          <!-- 验证码 - 仅在验证码登录模式下显示 -->
          <div v-else class="form-item">
            <!-- 验证码输入 -->
            <el-input v-model="formData.verificationCode" class="input-field" placeholder="请输入6位数验证码"
              :prefix-icon="Search" size="large" @input="handleVerificationCodeInput" />
            <!-- 发送验证码按钮 -->
            <el-button type="primary" class="verification-btn" :disabled="isCodeSent || !isPhoneValid"
              @click="sendVerificationCode">
              {{ isCodeSent ? countdownText : '发送验证码' }}
            </el-button>
          </div>
        </div>
      </div>
      
      <!-- 消息和链接容器 - 使用固定高度包裹，保持位置稳定 -->
      <div class="fixed-height-container">
        <!-- 验证码结果信息 -->
        <div v-if="resultMessage" :class="['result-message', messageType]">
          {{ resultMessage }}
        </div>
        <div v-else class="empty-message-placeholder"></div>
        
        <!-- 忘记密码链接 - 使用固定位置，无论是否显示都保持位置 -->
        <div class="forgot-password-container">
          <div v-if="loginByPassword" class="forgot-password">
            <el-button type="primary" link @click="forgotPassword" class="forgot-btn">忘记密码?</el-button>
          </div>
        </div>
      </div>

      <!-- 隐私协议 -->
      <div class="privacy-agreement">
        <el-checkbox v-model="formData.agreed" class="checkbox">
          我已阅读并同意协议，未注册的手机号将自动注册
        </el-checkbox>
      </div>

      <!-- 按钮组 -->
      <div class="button-group">
        <!-- 登录按钮 -->
        <el-button type="primary" class="action-btn login-btn"
          :disabled="!isFormValid" @click="login" :loading="loading">
          登录
        </el-button>
        
        <!-- 注册按钮 -->
        <el-button type="default" class="action-btn register-btn" @click="goToRegister">
          注册账号
        </el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onUnmounted } from "vue";
import { PhoneFilled, Search, Iphone, Lock } from "@element-plus/icons-vue";
import { useRouter } from "vue-router";
import { API_BASE_URL } from "../config";
import axios from "axios";
import { ElMessage } from 'element-plus';

const router = useRouter();

// 登录方式 - true为密码登录，false为验证码登录
const loginByPassword = ref(false);

// 表单数据
const formData = reactive({
  phone: "",
  verificationCode: "",
  password: "",
  agreed: false,
});

// 登录相关状态
const loading = ref(false);

// 切换登录方式
const toggleLoginType = (value) => {
  // 直接使用事件传来的值，而不是反转当前值
  // 清空错误消息
  resultMessage.value = "";
  
  // 如果切换到密码登录，清空密码字段防止自动填充
  if (value) { // 使用参数判断是否为密码登录
    // 延迟清空密码，给浏览器先填充的机会，然后再清空
    setTimeout(() => {
      formData.password = "";
    }, 50);
  } else {
    // 如果切换到验证码登录，清空验证码
    formData.verificationCode = "";
  }
};

// 输入处理
const handlePhoneInput = (value) => {
  // 处理各种可能的输入格式，包括带有+86的号码
  if (typeof value === 'string') {
    // 移除所有非数字字符（包括+号）
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

// 验证计算属性
const isPhoneValid = computed(() => {
  return /^1[3-9]\d{9}$/.test(formData.phone);
});

const isVerificationCodeValid = computed(() => {
  return /^\d{6}$/.test(formData.verificationCode);
});

const isPasswordValid = computed(() => {
  return formData.password.length >= 6;
});

// 表单整体验证
const isFormValid = computed(() => {
  // 基础验证：手机号和协议勾选必须有效
  const baseValid = isPhoneValid.value && formData.agreed;
  
  if (loginByPassword.value) {
    // 密码登录：必须有密码输入
    return baseValid && formData.password.length > 0;
  } else {
    // 验证码登录：必须有验证码输入
    return baseValid && formData.verificationCode.length > 0;
  }
});

// 验证码相关状态
const resultMessage = ref("");
const countdown = ref(60);
const isCodeSent = ref(false);
let timer = null;

const countdownText = computed(() => {
  return `${countdown.value.toString().padStart(2, "0")}`;
});

onUnmounted(() => {
  if (timer) clearInterval(timer);
});

// 添加消息类型状态
const messageType = ref("info");

// 忘记密码处理
const forgotPassword = () => {
  // 清空结果信息
  resultMessage.value = "";
  
  // 检查手机号格式
  if (!isPhoneValid.value) {
    resultMessage.value = "请输入有效的11位手机号";
    messageType.value = "warning";
    return;
  }
  
  // 切换到验证码登录模式
  loginByPassword.value = false;
  
  // 提示用户使用验证码重置密码
  ElMessage({
    message: '请使用验证码登录后重置密码',
    type: 'info'
  });
};

// 修改发送验证码函数，添加消息类型判断
const sendVerificationCode = async () => {
  // 先清空之前的提示信息
  resultMessage.value = "";

  // 检查是否同意协议
  if (!formData.agreed) {
    resultMessage.value = "请勾选同意隐私协议";
    messageType.value = "warning";
    return;
  }

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
      mobile: formData.phone, // 发送的手机号
    });

    if (response.status === 200) {
      resultMessage.value = "验证码已发送，请查收";
      messageType.value = "success"; // 成功发送设置为success类型
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

// 登录处理
const login = async () => {
  // 检测手机号
  if (!isPhoneValid.value) {
    resultMessage.value = "请输入有效的11位手机号";
    messageType.value = "warning";
    return;
  }

  // 根据登录模式检查输入
  if (loginByPassword.value) {
    if (!isPasswordValid.value) {
      resultMessage.value = "密码长度不能少于6位";
      messageType.value = "warning";
      return;
    }
  } else {
    if (!isVerificationCodeValid.value) {
      resultMessage.value = "验证码必须是6位数字";
      messageType.value = "warning";
      return;
    }
  }

  // 根据登录逻辑进行登录请求
  try {
    loading.value = true;
    resultMessage.value = "正在登录...";
    messageType.value = "info";
    
    let response;
    
    if (loginByPassword.value) {
      // 密码登录
      response = await axios.post(`${API_BASE_URL}/login/`, {
        mobile: formData.phone,
        password: formData.password,
        mode: 'password'
      });
    } else {
      // 验证码登录
      response = await axios.post(`${API_BASE_URL}/login/`, {
        mobile: formData.phone,
        code: formData.verificationCode,
        mode: 'code'
      });
    }

    if (response.data.code === 200) {
      // 存储登录状态和Token
      localStorage.setItem("isAuthenticated", "true");
      localStorage.setItem("mobile", formData.phone);
      if (response.data.token) {
        localStorage.setItem("token", response.data.token);
      }
      
      resultMessage.value = "登录成功，正在跳转...";
      messageType.value = "success";
      
      // 显示登录成功提示
      ElMessage.success('登录成功');
      
      // 跳转到首页
      setTimeout(() => {
        router.push("/chat");
      }, 1000);
    } else {
      resultMessage.value = response.data.message || "登录失败";
      messageType.value = "error";
    }
  } catch (error) {
    resultMessage.value = handleLoginError(error);
    messageType.value = "error";
  } finally {
    loading.value = false;
  }
};

const handleLoginError = (error) => {
  return handleApiError(error, "登录");
};

// 添加生成随机数字字符串的方法
const generateRandomDigits = () => {
  const length = 20 + Math.floor(Math.random() * 30);
  let result = '';
  const characters = '01';
  for (let i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * characters.length));
  }
  return result;
};

// 在script setup中添加注册页面跳转
const goToRegister = () => {
  router.push('/register');
};

// 统一错误处理
const handleApiError = (error, action) => {
  if (error.response) {
    return error.response.data.message || `${action}失败，请稍后重试`;
  }
  return "网络连接异常，请检查网络";
};
</script>

<style scoped>
/* 整体页面背景 - 高科技AI主题背景 */
.login {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  background: linear-gradient(125deg, #0b1437 0%, #172554 50%, #1e3a8a 100%);
  overflow: hidden;
  position: relative;
}

/* 添加科技感网格背景 */
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

/* 添加神经网络效果 */
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

/* 添加浮动圆环效果 */
.floating-rings {
  position: absolute;
  width: 100%;
  height: 100%;
  top: 0;
  left: 0;
  z-index: 0;
  overflow: hidden;
}

.ring {
  position: absolute;
  border-radius: 50%;
  border: 2px solid rgba(147, 197, 253, 0.1);
  box-shadow: 0 0 20px rgba(147, 197, 253, 0.05);
  animation: ringFloat 20s infinite ease-in-out;
}

.ring:nth-child(1) {
  width: 300px;
  height: 300px;
  top: 20%;
  left: 10%;
  border-color: rgba(147, 197, 253, 0.1);
  animation-duration: 25s;
  animation-delay: 0s;
}

.ring:nth-child(2) {
  width: 200px;
  height: 200px;
  bottom: 15%;
  right: 15%;
  border-color: rgba(168, 85, 247, 0.1);
  animation-duration: 20s;
  animation-delay: 5s;
}

.ring:nth-child(3) {
  width: 400px;
  height: 400px;
  top: 60%;
  left: 60%;
  border-color: rgba(59, 130, 246, 0.1);
  animation-duration: 30s;
  animation-delay: 2s;
}

@keyframes ringFloat {
  0% {
    transform: translate(0, 0) rotate(0deg);
  }
  33% {
    transform: translate(-20px, 20px) rotate(120deg);
  }
  66% {
    transform: translate(20px, -20px) rotate(240deg);
  }
  100% {
    transform: translate(0, 0) rotate(360deg);
  }
}

/* 添加光晕效果 */
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

/* 添加数据流效果 */
.data-stream {
  position: absolute;
  width: 100%;
  height: 100%;
  top: 0;
  left: 0;
  z-index: 0;
  overflow: hidden;
}

.data-line {
  position: absolute;
  height: 2px;
  background: linear-gradient(90deg, transparent, rgba(56, 189, 248, 0.5), transparent);
  animation: dataFlow 8s infinite linear;
  transform-origin: left center;
}

@keyframes dataFlow {
  0% {
    transform: translateX(-100%) scaleX(0);
    opacity: 0;
  }
  10% {
    opacity: 1;
  }
  90% {
    opacity: 1;
  }
  100% {
    transform: translateX(100%) scaleX(1);
    opacity: 0;
  }
}

/* 添加浮动粒子 */
.floating-particles {
  position: absolute;
  width: 100%;
  height: 100%;
  top: 0;
  left: 0;
  z-index: 0;
}

.particle {
  position: absolute;
  width: 6px;
  height: 6px;
  background-color: rgba(255, 255, 255, 0.2);
  border-radius: 50%;
  filter: blur(1px);
  animation: particleFloat 15s infinite ease-in-out;
}

.particle:nth-child(3n) {
  width: 4px;
  height: 4px;
  background-color: rgba(56, 189, 248, 0.3);
}

.particle:nth-child(3n+1) {
  width: 3px;
  height: 3px;
  background-color: rgba(99, 102, 241, 0.3);
}

.particle:nth-child(3n+2) {
  width: 5px;
  height: 5px;
  background-color: rgba(168, 85, 247, 0.3);
}

@keyframes particleFloat {
  0% {
    transform: translate(0, 0);
  }
  25% {
    transform: translate(10px, 10px);
  }
  50% {
    transform: translate(0, 20px);
  }
  75% {
    transform: translate(-10px, 10px);
  }
  100% {
    transform: translate(0, 0);
  }
}

/* 登录容器增强 - 更强的玻璃态效果 */
.login-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 30px 45px;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(10px);
  border-radius: 30px;
  max-width: 420px;
  width: 85%;
  box-shadow: 
    0 15px 35px rgba(0, 0, 0, 0.1),
    0 3px 10px rgba(0, 0, 0, 0.05);
  position: relative;
  z-index: 10;
  overflow: hidden;
  min-height: 480px;
  transition: all 0.3s ease;
}

.login-container:hover {
  box-shadow: 
    0 20px 40px rgba(0, 0, 0, 0.1), 
    0 5px 15px rgba(0, 0, 0, 0.05),
    0 0 0 1px rgba(255, 255, 255, 0.95) inset;
  transform: translateY(-5px);
}

/* 添加容器内光效 */
.login-container::before {
  content: '';
  position: absolute;
  top: -2px;
  left: -2px;
  right: -2px;
  bottom: -2px;
  background: linear-gradient(45deg, transparent, rgba(255, 255, 255, 0.8), transparent);
  z-index: -1;
  border-radius: 26px;
  animation: borderLight 6s linear infinite;
  opacity: 0.6;
}

@keyframes borderLight {
  0% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0% 50%;
  }
}

/* 标题样式 - 更精美的排版和动画 */
.img-title {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 20px;
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
  animation: shimmer 2s infinite;
}

@keyframes shimmer {
  0% {
    background-position: -70px 0;
  }
  100% {
    background-position: 70px 0;
  }
}

.img-title img {
  width: 55px;
  height: 55px;
  margin-right: 18px;
  filter: drop-shadow(0 4px 8px rgba(0, 0, 0, 0.15));
  animation: pulse 3s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
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

/* 表单样式 - 更精美的输入框 */
.table-submit {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 100%;
  margin-bottom: 5px;
}

/* 添加固定高度容器确保切换时高度一致 */
.form-container {
  width: 100%;
  min-height: 66px;
  position: relative;
  margin-top: 15px;
}

.form-item {
  display: flex;
  flex-direction: row;
  align-items: center;
  width: 100%;
  margin-bottom: 12px;
  position: relative;
}

/* 输入框样式 */
.input-field {
  width: 100%;
  height: 48px;
  font-size: 15px;
  border-radius: 12px !important;
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

.el-input__prefix {
  color: #64748b !important;
  font-size: 18px !important;
  margin-right: 4px !important;
}

/* 验证码按钮 */
.verification-btn {
  margin-left: 12px;
  height: 48px;
  min-width: 110px;
  border-radius: 12px !important;
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

.verification-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: all 0.6s ease;
}

.verification-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 
    0 6px 18px rgba(37, 99, 235, 0.3), 
    0 2px 6px rgba(37, 99, 235, 0.2) !important;
  background: linear-gradient(135deg, #2563eb, #1d4ed8) !important;
}

.verification-btn:hover:not(:disabled)::before {
  left: 100%;
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

/* 结果消息 - 基础样式 */
.result-message {
  padding: 6px 12px;
  border-radius: 12px;
  font-size: 14px;
  line-height: 1.4;
  margin-bottom: 5px;
  width: 100%;
  text-align: left;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
  backdrop-filter: blur(4px);
  animation: fadeIn 0.3s ease-out;
  display: flex;
  align-items: center;
  position: relative;
  overflow: hidden;
}

/* 根据消息类型设置不同样式 */
.result-message.success {
  background: rgba(236, 253, 245, 0.7);
  border-left: 3px solid #10b981;
  color: #065f46;
}

.result-message.info {
  background: rgba(236, 246, 255, 0.7);
  border-left: 3px solid #3b82f6;
  color: #1e40af;
  animation: fadeIn 0.3s ease-out, pulsate 2s infinite ease-in-out;
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

/* 添加脉动动画用于"发送中"状态 */
@keyframes pulsate {
  0% {
    box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.2);
  }
  70% {
    box-shadow: 0 0 0 8px rgba(59, 130, 246, 0);
  }
  100% {
    box-shadow: 0 0 0 0 rgba(59, 130, 246, 0);
  }
}

/* 添加图标 */
.result-message::before {
  content: '';
  width: 20px;
  height: 20px;
  margin-right: 10px;
  background-size: contain;
  background-position: center;
  background-repeat: no-repeat;
  display: inline-block;
}

.result-message.success::before {
  content: '✓';
  color: #10b981;
  font-weight: bold;
  text-align: center;
  line-height: 20px;
}

.result-message.info::before {
  content: 'i';
  color: #3b82f6;
  font-weight: bold;
  font-style: italic;
  text-align: center;
  line-height: 20px;
}

.result-message.warning::before {
  content: '!';
  color: #f59e0b;
  font-weight: bold;
  text-align: center;
  line-height: 20px;
}

.result-message.error::before {
  content: '✕';
  color: #ef4444;
  font-weight: bold;
  text-align: center;
  line-height: 20px;
}

/* 隐私协议 */
.privacy-agreement {
  margin-bottom: 10px;
  margin-top: 0px;
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

/* 登录类型选择器样式调整，避免切换时高度变化 */
.login-type-selector {
  width: 100%;
  margin-bottom: 18px;
  display: flex;
  justify-content: center;
}

.login-type-selector .el-radio-group {
  width: 100%;
  display: flex;
  border-radius: 14px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.login-type-selector .el-radio-button {
  flex: 1;
}

.login-type-selector .el-radio-button__inner {
  width: 100%;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-color: #e2e8f0;
  background: rgba(248, 250, 252, 0.8);
  color: #64748b;
  font-weight: 500;
  transition: all 0.3s;
  font-size: 15px;
}

.login-type-selector .el-radio-button__original {
  opacity: 0;
}

.login-type-selector .el-radio-button__inner:hover {
  background: rgba(241, 245, 249, 0.9);
  color: #3b82f6;
}

.login-type-selector .el-radio-button.is-active .el-radio-button__inner {
  background: #3b82f6;
  color: white;
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.25);
  border-color: #3b82f6;
}

/* 按钮组 */
.button-group {
  display: flex;
  width: 100%;
  gap: 15px;
  margin-top: 5px;
}

.action-btn {
  flex: 1;
  height: 48px !important;
  border-radius: 12px !important;
  font-weight: 600 !important;
  letter-spacing: 0.5px;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1) !important;
  position: relative;
  overflow: hidden;
  font-size: 16px !important;
}

/* 添加固定高度的消息和链接容器 */
.fixed-height-container {
  width: 100%;
  min-height: 45px;
  display: flex;
  flex-direction: column;
  position: relative;
  margin-bottom: 0;
}

/* 为空消息状态添加占位符 */
.empty-message-placeholder {
  width: 100%;
  height: 20px;
  margin-bottom: 5px;
}

/* 为忘记密码添加固定容器 */
.forgot-password-container {
  width: 100%;
  height: 18px;
  margin-bottom: 5px;
}

/* 忘记密码链接 */
.forgot-password {
  display: flex;
  justify-content: flex-end;
  width: 100%;
  height: 100%;
}

.forgot-password .forgot-btn {
  color: #4b5563;
  font-size: 14px;
  padding: 0 4px;
  font-weight: 500;
  position: relative;
  transition: all 0.3s ease;
  margin-right: 2px;
}

.forgot-password .forgot-btn::after {
  content: '';
  position: absolute;
  width: 0;
  height: 1.5px;
  bottom: -2px;
  left: 0;
  background: linear-gradient(90deg, #3b82f6, #60a5fa);
  transition: width 0.3s ease;
  border-radius: 4px;
}

.forgot-password .forgot-btn:hover {
  color: #3b82f6;
  transform: translateY(-1px);
}

.forgot-password .forgot-btn:hover::after {
  width: 100%;
}

.forgot-password .forgot-btn:active {
  transform: translateY(0);
}

/* 移除元素内部样式，使用上面的自定义样式 */
.forgot-password .el-button.forgot-btn:focus-visible {
  outline: none;
  box-shadow: none;
}

/* 登录按钮 */
.login-btn {
  background: linear-gradient(135deg, #3b82f6, #2563eb) !important;
  border: none !important;
  color: white !important;
  box-shadow: 
    0 4px 12px rgba(37, 99, 235, 0.25), 
    0 2px 4px rgba(37, 99, 235, 0.1) !important;
}

.login-btn::after {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  transition: all 0.6s ease;
}

.login-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 
    0 8px 20px rgba(37, 99, 235, 0.3), 
    0 4px 8px rgba(37, 99, 235, 0.2) !important;
  background: linear-gradient(135deg, #2563eb, #1d4ed8) !important;
}

.login-btn:hover::after {
  left: 100%;
}

.login-btn:active:not(:disabled) {
  transform: translateY(0);
}

.login-btn:disabled {
  background: linear-gradient(135deg, #93c5fd, #bfdbfe) !important;
  color: #eff6ff !important;
  box-shadow: none !important;
  cursor: not-allowed;
}

/* 注册按钮 */
.register-btn {
  background: rgba(255, 255, 255, 0.8) !important;
  border: 1px solid #e2e8f0 !important;
  color: #475569 !important;
  box-shadow: 
    0 2px 6px rgba(0, 0, 0, 0.03), 
    0 0 0 1px rgba(255, 255, 255, 0.8) inset !important;
}

.register-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  background: #f8fafc !important;
  border-color: #cbd5e1 !important;
  color: #334155 !important;
  box-shadow: 
    0 4px 12px rgba(0, 0, 0, 0.05), 
    0 0 0 1px rgba(255, 255, 255, 0.9) inset !important;
}

.register-btn:active:not(:disabled) {
  transform: translateY(0);
}

.register-btn:disabled {
  background: rgba(241, 245, 249, 0.8) !important;
  color: #94a3b8 !important;
  border-color: #e2e8f0 !important;
  box-shadow: none !important;
  cursor: not-allowed;
}

/* 响应式调整 */
@media (max-width: 480px) {
  .login-container {
    max-width: 90%;
    padding: 35px 25px;
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
}
</style>
