<template>
  <div class="feature-card small-feature">
    <div class="feature-header">
      <h2>应急处理</h2>
    </div>
    <p class="feature-desc">化工事故应急预案与快速响应流程</p>
    <div class="emergency-actions">
      <div 
        class="emergency-category" 
        v-for="file in emergencyFiles" 
        :key="file.id"
        :title="file.name"
      >
        <div class="category-name">
          <span>{{ truncateFileName(file.name) }}</span>
        </div>
      </div>
    </div>
    <div class="button-container">
      <router-link to="/emergency_files" class="action-button emergency-button">
        应急指南
      </router-link>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { API_BASE_URL } from '@/config';

const router = useRouter();
const emergencyFiles = ref([]);

// 获取应急文件列表
const fetchEmergencyFiles = async () => {
  try {
    const response = await fetch(`${API_BASE_URL}/emergency_files/?page=1&page_size=5`, {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('token')}`,
        'X-User-ID': localStorage.getItem('user_id')
      }
    });
    
    if (!response.ok) {
      throw new Error('获取文件列表失败');
    }
    
    const data = await response.json();
    if (data.code === 200) {
      emergencyFiles.value = data.data;
    }
  } catch (error) {
    console.error('获取应急文件列表失败:', error);
  }
};

// 截断文件名，确保在一行内显示
const truncateFileName = (name) => {
  if (name.length > 25) {
    return name.substring(0, 25) + '...';
  }
  return name;
};

// 查看文件
const viewFile = (file) => {
  router.push(`/emergency_files/${file.id}`);
};

onMounted(() => {
  fetchEmergencyFiles();
});
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
  justify-content: center;
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
  width: 100%;
  box-sizing: border-box;
}

.emergency-category {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(239, 68, 68, 0.05);
  padding: 8px 12px;
  border-radius: 8px;
  transition: all 0.2s ease;
  width: 100%;
  box-sizing: border-box;
}

.emergency-category:hover {
  background: rgba(239, 68, 68, 0.1);
}

.category-name {
  display: block;
  font-size: 0.9rem;
  font-weight: 500;
  color: #4a5568;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  width: 100%;
  box-sizing: border-box;
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