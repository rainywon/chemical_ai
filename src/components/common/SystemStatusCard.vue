<template>
  <div class="info-card">
    <div class="info-card-header">
      <h3>系统状态</h3>
    </div>
    <div class="info-grid">
      <div class="info-item">
        <span class="info-label">知识库</span>
        <span class="info-value">{{ systemStatus.knowledge_base }}</span>
      </div>
      <div class="info-item">
        <span class="info-label">更新日期</span>
        <span class="info-value">{{ systemStatus.update_date }}</span>
      </div>
      <div class="info-item">
        <span class="info-label">数据源</span>
        <span class="info-value">{{ systemStatus.data_sources }}</span>
      </div>
      <div class="info-item">
        <span class="info-label">响应时间</span>
        <span class="info-value">{{ systemStatus.response_time }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { API_BASE_URL } from '../../config'

const systemStatus = ref({
  knowledge_base: '加载中...',
  update_date: '加载中...',
  data_sources: '加载中...',
  response_time: '加载中...'
})

const fetchSystemStatus = async () => {
  try {
    const response = await fetch(`${API_BASE_URL}/system/status`)
    if (!response.ok) {
      throw new Error('获取系统状态失败')
    }
    const data = await response.json()
    systemStatus.value = data
  } catch (error) {
    console.error('获取系统状态失败:', error)
    systemStatus.value = {
      knowledge_base: '获取失败',
      update_date: '获取失败',
      data_sources: '获取失败',
      response_time: '获取失败'
    }
  }
}

onMounted(() => {
  fetchSystemStatus()
})
</script>

<style scoped>
.info-card {
  background: rgba(248, 250, 252, 0.8);
  border-radius: 12px;
  padding: 14px;
}

.info-card-header {
  margin-bottom: 12px;
  text-align: center;
}

.info-card h3 {
  font-size: 1rem;
  margin: 0;
  color: #1a1f36;
  text-align: center;
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