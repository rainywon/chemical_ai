<template>
  <div class="info-card">
    <div class="info-card-header">
      <span class="info-icon">📊</span>
      <h3>系统状态</h3>
    </div>
    <div class="info-grid">
      <div class="info-item">
        <span class="info-label">知识库</span>
        <span class="info-value">v3.2.1</span>
      </div>
      <div class="info-item">
        <span class="info-label">更新日期</span>
        <span class="info-value">2023-12-15</span>
      </div>
      <div class="info-item">
        <span class="info-label">数据源</span>
        <span class="info-value">32个专业库</span>
      </div>
      <div class="info-item">
        <span class="info-label">响应时间</span>
        <span class="info-value">≤ 2秒</span>
      </div>
    </div>
  </div>
</template>

<script setup>
// No props or state needed for this component
</script>

<style scoped>
.info-card {
  background: rgba(248, 250, 252, 0.8);
  border-radius: 12px;
  padding: 14px;
}

.info-card-header {
  display: flex;
  align-items: center;
  margin-bottom: 12px;
}

.info-icon {
  font-size: 1.2rem;
  margin-right: 8px;
}

.info-card h3 {
  font-size: 1rem;
  margin: 0;
  color: #1a1f36;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
}

.info-item {
  display: flex;
  flex-direction: column;
}

.info-label {
  font-size: 0.7rem;
  color: #6b7280;
  margin-bottom: 2px;
}

.info-value {
  font-size: 0.85rem;
  font-weight: 600;
  color: #1f2937;
}

/* Dark theme styles */
body.dark-theme .info-card {
  background: rgba(17, 24, 39, 0.8);
}

body.dark-theme .info-card h3 {
  color: #f3f4f6;
}

body.dark-theme .info-label {
  color: #9ca3af;
}

body.dark-theme .info-value {
  color: #e5e7eb;
}
</style> 