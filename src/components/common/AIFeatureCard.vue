<template>
  <div class="feature-card ai-feature">
    <div class="feature-header">
      <div class="feature-icon ai">🧪</div>
      <h2>化工安全智能问答</h2>
    </div>
    
    <div class="ai-capabilities">
      <div class="ai-capability">
        <span class="capability-text">专业知识查询</span>
      </div>
      <div class="ai-capability">
        <span class="capability-text">实时风险评估</span>
      </div>
      <div class="ai-capability">
        <span class="capability-text">安全标准对照</span>
      </div>
    </div>
    
    <div class="example-box">
      <div class="example-header">示例问题</div>
      <ul class="example-list">
        <li>如何安全处理氧化剂与还原剂的储存？</li>
        <li>氯气泄漏的应急处理流程？</li>
        <li>有机溶剂的安全使用规范？</li>
      </ul>
    </div>
    
    <div class="button-container">
      <router-link to="/chat" class="action-button ai-button">
        开始咨询
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

.ai-feature {
  grid-column: 1;
  grid-row: 1;
  max-height: calc(100vh - 200px);
  display: flex;
  flex-direction: column;
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

/* AI能力样式 */
.ai-capabilities {
  display: flex;
  justify-content: space-between;
  margin: 15px 0;
  background: rgba(79, 70, 229, 0.05);
  border-radius: 12px;
  padding: 15px;
}

.ai-capability {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  width: 30%;
}

.capability-text {
  font-size: 0.9rem;
  font-weight: 600;
  color: #4f46e5;
}

/* 示例问题样式 */
.example-box {
  background: rgba(79, 70, 229, 0.05);
  border-radius: 12px;
  padding: 15px;
  margin: 15px 0;
  flex: 1;
  overflow-y: auto;
}

.example-header {
  font-size: 0.9rem;
  font-weight: 600;
  color: #1a1f36;
  margin-bottom: 12px;
}

.example-list {
  margin: 0;
  padding-left: 20px;
  font-size: 0.85rem;
  color: #4a5568;
}

.example-list li {
  margin-bottom: 8px;
  line-height: 1.4;
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

.ai-button {
  background: linear-gradient(135deg, #4f46e5, #6366f1);
}

/* Dark theme styles */
body.dark-theme .feature-card {
  background: #1f2937;
}

body.dark-theme .example-header, 
body.dark-theme .feature-card h2 {
  color: #f3f4f6;
}

body.dark-theme .example-list li {
  color: #d1d5db;
}

body.dark-theme .example-box {
  background: rgba(79, 70, 229, 0.15);
}

body.dark-theme .capability-text {
  color: #a5b4fc;
}

/* Responsive design */
@media (max-width: 900px) {
  .ai-feature {
    max-height: none;
  }
  
  .action-button {
    width: 100%;
  }
}
</style> 