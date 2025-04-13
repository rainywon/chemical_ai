<template>
  <div class="feature-card small-feature">
    <div class="feature-header">
      <div class="feature-icon emergency">🚨</div>
      <h2>应急处理</h2>
    </div>
    <p class="feature-desc">化工事故应急预案与快速响应流程</p>
    <div class="emergency-actions">
      <div class="emergency-category">
        <div class="category-name">
          <span>火灾爆炸</span>
        </div>
        <router-link to="/emergency/fire" class="quick-link">查看</router-link>
      </div>
      <div class="emergency-category">
        <div class="category-name">
          <span>化学泄漏</span>
        </div>
        <router-link to="/emergency/leak" class="quick-link">查看</router-link>
      </div>
      <div class="emergency-category">
        <div class="category-name">
          <span>人员中毒</span>
        </div>
        <router-link to="/emergency/poison" class="quick-link">查看</router-link>
      </div>
    </div>
    <div class="button-container">
      <router-link to="/emergency" class="action-button emergency-button">
        应急指南
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

/* 应急处理样式 */
.emergency-actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 12px;
  flex: 1;
  overflow-y: auto;
}

.emergency-category {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(239, 68, 68, 0.05);
  padding: 8px 12px;
  border-radius: 8px;
}

.category-name {
  display: flex;
  align-items: center;
  font-size: 0.8rem;
  font-weight: 500;
  color: #4a5568;
}

.quick-link {
  font-size: 0.75rem;
  color: #ef4444;
  font-weight: 600;
  text-decoration: none;
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

.emergency-button {
  background: linear-gradient(135deg, #ef4444, #f87171);
}

/* Dark theme styles */
body.dark-theme .feature-card {
  background: #1f2937;
}

body.dark-theme .feature-card h2 {
  color: #f3f4f6;
}

body.dark-theme .feature-desc, 
body.dark-theme .category-name {
  color: #d1d5db;
}

body.dark-theme .emergency-category {
  background: rgba(239, 68, 68, 0.15);
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