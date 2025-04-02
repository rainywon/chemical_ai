<template>
  <div class="files-container">
    <!-- 页面头部搜索区 -->
    <div class="files-header">
      <!-- 添加返回按钮 -->
      <div class="back-button" @click="goToWelcome">
        <span class="back-icon">←</span>
        <span class="back-text">返回首页</span>
      </div>
      
      <h1 class="page-title">安全资料库</h1>
      <p class="page-subtitle">浏览和下载化工安全相关文件与标准</p>
      
      <!-- 搜索区域 -->
      <div class="search-area">
        <div class="search-box">
          <input type="text" v-model="searchQuery" placeholder="搜索文件..." class="search-input" />
          <button class="search-btn">搜索</button>
        </div>
      </div>
    </div>
    
    <!-- 主内容区：分类在左，文件在右 -->
    <div class="main-content">
      <!-- 左侧分类列表 -->
      <div class="category-sidebar">
        <h2 class="sidebar-title">文档分类</h2>
        <ul class="category-list">
          <li class="category-item" 
              :class="{ 'active': selectedCategory === '' }"
              @click="selectedCategory = ''; currentPage = 1">
            所有分类
          </li>
          <li class="category-item" 
              v-for="category in fileCategories" 
              :key="category.id"
              :class="{ 'active': selectedCategory === category.type }"
              @click="selectedCategory = category.type; currentPage = 1">
            {{ category.name }}
          </li>
        </ul>
      </div>
      
      <!-- 右侧文件列表 -->
      <div class="files-content">
        <h2 class="content-title">
          {{ selectedCategoryName }}
        </h2>
        
        <!-- 文件列表，每行一个文件 -->
        <div class="files-table">
          <div class="file-row" v-for="file in paginatedFiles" :key="file.id">
            <div class="file-name" @click="viewFile(file)">{{ file.name }}</div>
            <div class="file-actions">
              <button class="download-btn" @click="downloadFile(file)">下载</button>
            </div>
          </div>
          
          <!-- 无结果显示 -->
          <div class="no-results" v-if="filteredFiles.length === 0">
            <div class="no-results-icon">🔍</div>
            <p>未找到匹配的文件</p>
          </div>
        </div>
        
        <!-- 分页控件 -->
        <div class="pagination" v-if="totalPages > 1">
          <button 
            class="page-btn prev" 
            :disabled="currentPage === 1"
            @click="currentPage--">
            上一页
          </button>
          
          <div class="page-numbers">
            <div 
              v-for="page in displayedPages" 
              :key="page"
              :class="['page-number', { active: currentPage === page }]"
              @click="currentPage = page">
              {{ page }}
            </div>
          </div>
          
          <button 
            class="page-btn next" 
            :disabled="currentPage === totalPages"
            @click="currentPage++">
            下一页
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

// 返回欢迎页面
const goToWelcome = () => {
  router.push('/');
};

// 搜索和过滤状态
const searchQuery = ref('');
const selectedCategory = ref('');

// 分页状态
const currentPage = ref(1);
const filesPerPage = 10; // 每页显示的文件数量

// 示例数据 - 实际应用中可能从API获取
const fileCategories = ref([
  {
    id: 1,
    name: '安全手册',
    type: 'manual',
    files: [
      { id: 101, name: '化工厂安全操作手册', type: 'pdf' },
      { id: 102, name: '危险化学品处理指南', type: 'pdf' },
      { id: 103, name: '实验室安全规程', type: 'doc' },
      { id: 104, name: '应急管理程序', type: 'pdf' },
      { id: 105, name: '安全事故案例分析', type: 'pdf' },
    ]
  },
  {
    id: 2,
    name: '行业标准',
    type: 'standard',
    files: [
      { id: 201, name: '化工企业安全生产标准', type: 'pdf' },
      { id: 202, name: '危化品储存标准', type: 'pdf' },
      { id: 203, name: '职业健康安全管理体系要求', type: 'pdf' },
      { id: 204, name: '安全评价规范', type: 'doc' },
    ]
  },
  {
    id: 3,
    name: '法规文件',
    type: 'regulation',
    files: [
      { id: 301, name: '化工安全生产法规汇编', type: 'pdf' },
      { id: 302, name: '环保合规要求', type: 'doc' },
      { id: 303, name: '安全生产许可证管理条例', type: 'pdf' },
      { id: 304, name: '特种设备安全监察条例', type: 'pdf' },
      { id: 305, name: '危险化学品管理条例', type: 'pdf' },
    ]
  },
  {
    id: 4,
    name: '操作指南',
    type: 'guideline',
    files: [
      { id: 401, name: '应急响应流程', type: 'pdf' },
      { id: 402, name: '安全事故处理步骤', type: 'pdf' },
      { id: 403, name: '紧急疏散指南', type: 'pdf' },
      { id: 404, name: '防护装备使用说明', type: 'pdf' },
      { id: 405, name: '安全检查清单', type: 'doc' },
      { id: 406, name: '事故报告程序', type: 'pdf' },
    ]
  }
]);

// 获取所选分类的名称
const selectedCategoryName = computed(() => {
  if (!selectedCategory.value) return '所有文件';
  const category = fileCategories.value.find(c => c.type === selectedCategory.value);
  return category ? category.name : '所有文件';
});

// 获取筛选后的文件列表
const filteredFiles = computed(() => {
  // 所有文件的扁平列表
  let allFiles = [];
  
  if (selectedCategory.value) {
    // 筛选特定分类的文件
    const category = fileCategories.value.find(c => c.type === selectedCategory.value);
    allFiles = category ? [...category.files] : [];
  } else {
    // 获取所有分类的文件
    fileCategories.value.forEach(category => {
      allFiles = [...allFiles, ...category.files];
    });
  }
  
  // 根据搜索条件进一步筛选
  if (searchQuery.value.trim()) {
    const query = searchQuery.value.toLowerCase();
    return allFiles.filter(file => file.name.toLowerCase().includes(query));
  }
  
  return allFiles;
});

// 总页数
const totalPages = computed(() => {
  return Math.ceil(filteredFiles.value.length / filesPerPage);
});

// 当前页显示的文件
const paginatedFiles = computed(() => {
  const startIndex = (currentPage.value - 1) * filesPerPage;
  return filteredFiles.value.slice(startIndex, startIndex + filesPerPage);
});

// 显示的页码范围 (始终显示5个页码)
const displayedPages = computed(() => {
  if (totalPages.value <= 5) {
    return Array.from({ length: totalPages.value }, (_, i) => i + 1);
  }
  
  const halfWindow = 2;
  let start = Math.max(currentPage.value - halfWindow, 1);
  let end = Math.min(start + 4, totalPages.value);
  
  // 调整开始值，确保显示5个页码
  if (end - start < 4) {
    start = Math.max(end - 4, 1);
  }
  
  return Array.from({ length: end - start + 1 }, (_, i) => start + i);
});

// 文件操作函数
const viewFile = (file) => {
  console.log('查看文件:', file);
  // 实现文件预览逻辑，可能打开新窗口或使用预览组件
};

const downloadFile = (file) => {
  console.log('下载文件:', file);
  // 实现文件下载逻辑
};
</script>

<style scoped>
.files-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
  height: 100vh;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
}

/* 头部样式 */
.files-header {
  margin-bottom: 20px;
  text-align: center;
  position: relative; /* 为返回按钮的绝对定位添加相对定位容器 */
}

/* 返回按钮样式 */
.back-button {
  position: absolute;
  left: 0;
  top: 0;
  display: flex;
  align-items: center;
  padding: 8px 12px;
  border-radius: 6px;
  background-color: #f5f6fa;
  color: #4a6ee0;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 14px;
  font-weight: 500;
}

.back-button:hover {
  background-color: #eef2ff;
  transform: translateX(-3px);
}

.back-icon {
  font-size: 18px;
  margin-right: 6px;
}

.back-text {
  line-height: 1;
}

.page-title {
  font-size: 24px;
  color: #2b3674;
  margin-bottom: 5px;
}

.page-subtitle {
  font-size: 14px;
  color: #606478;
  margin-bottom: 15px;
}

.search-area {
  display: flex;
  justify-content: center;
  margin-bottom: 15px;
}

.search-box {
  display: flex;
  width: 100%;
  max-width: 500px;
}

.search-input {
  flex: 1;
  padding: 10px 15px;
  border: 1px solid #e0e3e7;
  border-radius: 8px 0 0 8px;
  font-size: 14px;
}

.search-btn {
  background: #4a6ee0;
  color: white;
  border: none;
  padding: 0 20px;
  border-radius: 0 8px 8px 0;
  cursor: pointer;
  font-weight: 500;
}

/* 主内容区样式 */
.main-content {
  display: flex;
  gap: 20px;
  flex: 1;
  overflow: hidden; /* 防止出现垂直滚动条 */
}

/* 左侧分类栏样式 */
.category-sidebar {
  width: 200px;
  flex-shrink: 0;
  background: white;
  border-radius: 8px;
  padding: 15px;
  box-shadow: 0 1px 5px rgba(0, 0, 0, 0.05);
  overflow-y: auto; /* 如果分类很多，允许垂直滚动 */
}

.sidebar-title {
  font-size: 16px;
  color: #2b3674;
  padding-bottom: 10px;
  margin-bottom: 10px;
  border-bottom: 1px solid #f0f1f5;
}

.category-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.category-item {
  padding: 10px;
  border-radius: 6px;
  font-size: 14px;
  color: #4a5173;
  margin-bottom: 4px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.category-item:hover {
  background: #f5f6fa;
}

.category-item.active {
  background: #eef2ff;
  color: #4a6ee0;
  font-weight: 500;
}

/* 右侧文件列表样式 */
.files-content {
  flex: 1;
  background: white;
  border-radius: 8px;
  padding: 15px;
  box-shadow: 0 1px 5px rgba(0, 0, 0, 0.05);
  display: flex;
  flex-direction: column;
  overflow: hidden; /* 防止内容溢出 */
}

.content-title {
  font-size: 16px;
  color: #2b3674;
  margin-bottom: 15px;
  padding-bottom: 10px;
  border-bottom: 1px solid #f0f1f5;
}

.files-table {
  display: flex;
  flex-direction: column;
  gap: 5px;
  overflow-y: auto; /* 文件过多时允许垂直滚动 */
  flex: 1;
}

.file-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 15px;
  border-radius: 6px;
  background: #f9fafc;
  transition: all 0.2s ease;
}

.file-row:hover {
  background: #f5f6fa;
}

.file-name {
  font-size: 14px;
  color: #4a6ee0;
  cursor: pointer;
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.file-name:hover {
  text-decoration: underline;
}

.file-actions {
  margin-left: 15px;
}

.download-btn {
  padding: 6px 12px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  border: none;
  background: #4a6ee0;
  color: white;
}

.download-btn:hover {
  background: #3a56b4;
}

.no-results {
  text-align: center;
  padding: 30px 0;
  color: #818498;
}

.no-results-icon {
  font-size: 36px;
  margin-bottom: 10px;
}

/* 分页控件 */
.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 15px;
  padding-top: 15px;
  border-top: 1px solid #f0f1f5;
}

.page-btn {
  padding: 6px 12px;
  background: #f5f6fa;
  border: 1px solid #e0e3e7;
  border-radius: 4px;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
  color: #4a5173;
}

.page-btn:hover:not(:disabled) {
  background: #e4e6ed;
}

.page-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.page-numbers {
  display: flex;
  gap: 5px;
  margin: 0 10px;
}

.page-number {
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  cursor: pointer;
  font-size: 13px;
  color: #4a5173;
  transition: all 0.2s ease;
}

.page-number:hover {
  background: #f5f6fa;
}

.page-number.active {
  background: #4a6ee0;
  color: white;
}

/* 响应式布局 */
@media (max-width: 768px) {
  .files-container {
    height: 100%;
    padding: 15px;
  }
  
  .main-content {
    flex-direction: column;
    gap: 15px;
  }
  
  .category-sidebar {
    width: 100%;
    margin-bottom: 15px;
  }
  
  .file-row {
    padding: 8px 12px;
  }
  
  .download-btn {
    padding: 4px 10px;
  }
}
</style> 