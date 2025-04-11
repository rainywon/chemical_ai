<template>
  <div class="feature-card small-feature">
    <div class="feature-header">
      <div class="feature-icon file">📁</div>
      <h2>安全资料库</h2>
    </div>
    <p class="feature-desc">浏览与下载各类化工安全相关文档与标准</p>
    <div class="feature-tags">
      <span class="tag file-tag">安全手册</span>
      <span class="tag file-tag">标准文件</span>
      <span class="tag file-tag">危化品MSDS</span>
    </div>
    <div class="file-list">
      <div class="file-item">
        <span>化工企业安全生产标准规范</span>
      </div>
      <div class="file-item">
        <span>危险化学品应急处置指南</span>
      </div>
    </div>
    <div class="button-container">
      <router-link to="/files" class="action-button file-button">
        浏览文件
      </router-link>
    </div>
  </div>
</template>

<script setup>
// No props or state needed for this component
</script>

<style scoped>
.feature-card {
  background: white;
  border-radius: 16px;
  padding: 20px;
  display: flex;
  flex-direction: column;
  position: relative;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.06);
  overflow: hidden;
}

.small-feature {
  display: flex;
  flex-direction: column;
  max-height: calc(100vh - 200px);
}

.feature-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 15px;
}

.feature-icon {
  font-size: 1.5rem;
}

.feature-card h2 {
  margin: 0;
  font-size: 1.3rem;
  color: #1a1f36;
}

.feature-desc {
  font-size: 0.9rem;
  color: #4a5568;
  margin: 0 0 15px 0;
  line-height: 1.4;
}

/* 标签样式 */
.feature-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-bottom: 12px;
}

.tag {
  background: rgba(79, 70, 229, 0.1);
  color: #4f46e5;
  font-size: 0.7rem;
  padding: 4px 10px;
  border-radius: 6px;
  font-weight: 500;
}

.file-tag {
  background: rgba(16, 185, 129, 0.1);
  color: #10b981;
}

/* 文件列表样式 */
.file-list {
  background: rgba(16, 185, 129, 0.05);
  border-radius: 8px;
  padding: 12px;
  margin-bottom: 12px;
  flex: 1;
  overflow-y: auto;
}

.file-item {
  display: flex;
  align-items: center;
  font-size: 0.8rem;
  color: #4a5568;
  margin-bottom: 8px;
  padding: 6px 10px;
  border-radius: 4px;
  background: rgba(255, 255, 255, 0.7);
}

/* 按钮容器 */
.button-container {
  margin-top: 15px;
  display: flex;
  justify-content: center;
  width: 100%;
}

/* 按钮样式 */
.action-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background: #4f46e5;
  color: white;
  border: none;
  border-radius: 8px;
  padding: 10px 16px;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  text-decoration: none;
  transition: all 0.2s ease;
  width: 75%;
  text-align: center;
}

.action-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(79, 70, 229, 0.25);
}

.file-button {
  background: linear-gradient(135deg, #10b981, #34d399);
}

/* Dark theme styles */
body.dark-theme .feature-card {
  background: #1f2937;
}

body.dark-theme .feature-card h2 {
  color: #f3f4f6;
}

body.dark-theme .feature-desc, 
body.dark-theme .file-item {
  color: #d1d5db;
}

body.dark-theme .file-list {
  background: rgba(16, 185, 129, 0.15);
}

body.dark-theme .file-item {
  background: rgba(31, 41, 55, 0.7);
}

/* Responsive styles */
@media (max-width: 900px) {
  .small-feature {
    max-height: none;
  }
  
  .action-button {
    width: 100%;
  }
}
</style> 