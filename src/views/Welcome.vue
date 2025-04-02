<template>
  <div class="welcome-container">
    <div class="welcome-card">
      <div class="top-section">
        <div class="logo-container">
          <img src="@/assets/product_logo.png" alt="应用Logo" class="logo" />
        </div>
        
        <h1 class="title">欢迎使用智能助手</h1>
        <p class="subtitle">您的化工安全AI对话助手，随时为您提供专业帮助</p>
      </div>
      
      <!-- 核心特点简化展示 -->
      <div class="features">
        <div class="feature-item">
          <div class="feature-icon">💬</div>
          <div class="feature-text">智能对话</div>
        </div>
        <div class="feature-item">
          <div class="feature-icon">📚</div>
          <div class="feature-text">知识丰富</div>
        </div>
        <div class="feature-item">
          <div class="feature-icon">⚡</div>
          <div class="feature-text">快速响应</div>
        </div>
      </div>
      
      <!-- 新增的两个模块区域 -->
      <div class="modules-container">
        <!-- 化工安全智能问答模块 -->
        <div class="module-card chemical-safety">
          <div class="module-header">
            <div class="module-icon">🧪</div>
            <h2 class="module-title">化工安全智能问答</h2>
          </div>
          <p class="module-desc">针对化工安全知识的实时咨询，为您解答安全疑问</p>
          <div class="module-features">
            <div class="module-feature">
              <span class="check-icon">✓</span>
              <span>专业知识库</span>
            </div>
            <div class="module-feature">
              <span class="check-icon">✓</span>
              <span>安全建议</span>
            </div>
          </div>
          <router-link to="/chat" class="module-btn">开始咨询</router-link>
        </div>
        
        <!-- 文件浏览下载模块 -->
        <div class="module-card file-browser">
          <div class="module-header">
            <div class="module-icon">📁</div>
            <h2 class="module-title">安全资料库</h2>
          </div>
          <p class="module-desc">浏览与下载各类化工安全相关文档与标准</p>
          <div class="module-features">
            <div class="module-feature">
              <span class="check-icon">✓</span>
              <span>安全手册</span>
            </div>
            <div class="module-feature">
              <span class="check-icon">✓</span>
              <span>标准文件</span>
            </div>
          </div>
          <router-link to="/files" class="module-btn">浏览文件</router-link>
        </div>
      </div>
      
      <div class="action-buttons">
        <div class="secondary-actions">
          <router-link to="/login" class="secondary-btn">登录</router-link>
          <router-link to="/register" class="secondary-btn">注册</router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
// Welcome 页面逻辑
</script>

<style scoped>
.welcome-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh; /* 使用固定高度而非最小高度 */
  background: linear-gradient(135deg, #f5f7fa 0%, #e4e8f0 100%);
  padding: 0;
  overflow: hidden; /* 防止滚动 */
}

.welcome-card {
  max-width: 900px;
  width: 90%;
  background: white;
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
  padding: 30px;
  text-align: center;
  animation: fadeIn 0.8s ease-out;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  height: auto;
  max-height: 90vh;
}

.top-section {
  margin-bottom: 20px;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.logo-container {
  margin-bottom: 15px;
}

.logo {
  width: 60px;
  height: 60px;
  object-fit: contain;
}

.title {
  font-size: 24px;
  font-weight: 600;
  color: #2b3674;
  margin-bottom: 5px;
  letter-spacing: -0.5px;
}

.subtitle {
  font-size: 14px;
  color: #606478;
  margin-bottom: 15px;
  line-height: 1.4;
}

.features {
  display: flex;
  justify-content: center;
  gap: 30px;
  margin-bottom: 25px;
}

.feature-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  transition: all 0.3s ease;
}

.feature-item:hover {
  transform: translateY(-3px);
}

.feature-icon {
  font-size: 24px;
  margin-bottom: 8px;
}

.feature-text {
  font-size: 13px;
  font-weight: 500;
  color: #4a5173;
}

/* 模块样式优化 */
.modules-container {
  display: flex;
  gap: 20px;
  margin-bottom: 25px;
}

.module-card {
  flex: 1;
  background: #f9fafc;
  border-radius: 16px;
  padding: 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  border: 1px solid rgba(223, 225, 230, 0.6);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.module-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.08);
  border-color: rgba(223, 225, 230, 0.9);
}

.module-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 5px;
  transition: all 0.3s ease;
}

.chemical-safety::before {
  background: linear-gradient(to right, #4d72e3, #8175c9);
}

.file-browser::before {
  background: linear-gradient(to right, #42b883, #35a56f);
}

.module-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
  width: 100%;
  justify-content: center;
}

.module-icon {
  font-size: 24px;
  background: rgba(255, 255, 255, 0.8);
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  box-shadow: 0 3px 8px rgba(0, 0, 0, 0.08);
}

.module-title {
  font-size: 16px;
  font-weight: 600;
  color: #2b3674;
  margin: 0;
}

.module-desc {
  font-size: 13px;
  color: #606478;
  margin-bottom: 12px;
  line-height: 1.4;
}

.module-features {
  width: 100%;
  margin-bottom: 15px;
  text-align: left;
}

.module-feature {
  display: flex;
  align-items: center;
  margin-bottom: 6px;
  font-size: 13px;
  color: #4a5173;
}

.check-icon {
  color: #4a6ee0;
  margin-right: 8px;
  font-weight: bold;
  font-size: 12px;
}

.file-browser .check-icon {
  color: #42b883;
}

.module-btn {
  background: #4a6ee0;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 8px;
  font-weight: 500;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.3s ease;
  text-decoration: none;
  display: inline-block;
  box-shadow: 0 3px 8px rgba(74, 110, 224, 0.2);
}

.file-browser .module-btn {
  background: #42b883;
  box-shadow: 0 3px 8px rgba(66, 184, 131, 0.2);
}

.module-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 12px rgba(74, 110, 224, 0.3);
}

.file-browser .module-btn:hover {
  box-shadow: 0 5px 12px rgba(66, 184, 131, 0.3);
}

.action-buttons {
  margin-top: 10px;
}

.secondary-actions {
  display: flex;
  justify-content: center;
  gap: 20px;
}

.secondary-btn {
  color: #4a6ee0;
  font-size: 13px;
  font-weight: 500;
  text-decoration: none;
  padding: 5px 0;
  position: relative;
  transition: all 0.3s ease;
}

.secondary-btn::after {
  content: '';
  position: absolute;
  width: 0;
  height: 2px;
  bottom: 0;
  left: 0;
  background-color: #4a6ee0;
  transition: width 0.3s ease;
}

.secondary-btn:hover {
  color: #3a56b4;
}

.secondary-btn:hover::after {
  width: 100%;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .welcome-card {
    padding: 20px 15px;
    width: 95%;
  }
  
  .features {
    gap: 15px;
  }
  
  .modules-container {
    flex-direction: column;
    gap: 15px;
  }
  
  .module-card {
    padding: 15px;
    margin-bottom: 0;
  }
  
  .module-feature {
    font-size: 12px;
  }
  
  .logo {
    width: 50px;
    height: 50px;
  }
  
  .title {
    font-size: 20px;
  }
}

/* 修复Safari中的特定问题 */
@supports (-webkit-touch-callout: none) {
  .welcome-container {
    height: -webkit-fill-available;
  }
}
</style> 