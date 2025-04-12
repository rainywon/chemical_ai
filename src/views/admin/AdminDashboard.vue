<template>
  <div class="admin-dashboard">
    <div class="page-header">
      <h1>管理系统控制台</h1>
      <p>欢迎使用天工AI管理系统，您可以在这里管理系统各项功能。</p>
    </div>
    
    <div class="dashboard-cards">
      <!-- 系统概览卡片 -->
      <el-row :gutter="20">
        <el-col :span="6">
          <el-card shadow="hover" class="overview-card">
            <div class="card-content">
              <div class="card-icon user-icon">
                <el-icon><User /></el-icon>
              </div>
              <div class="card-data">
                <div class="data-value">{{ userCount }}</div>
                <div class="data-title">总用户数</div>
              </div>
            </div>
          </el-card>
        </el-col>
        
        <el-col :span="6">
          <el-card shadow="hover" class="overview-card">
            <div class="card-content">
              <div class="card-icon chat-icon">
                <el-icon><ChatLineRound /></el-icon>
              </div>
              <div class="card-data">
                <div class="data-value">{{ chatCount }}</div>
                <div class="data-title">总对话数</div>
              </div>
            </div>
          </el-card>
        </el-col>
        
        <el-col :span="6">
          <el-card shadow="hover" class="overview-card">
            <div class="card-content">
              <div class="card-icon active-icon">
                <el-icon><View /></el-icon>
              </div>
              <div class="card-data">
                <div class="data-value">{{ activeUsers }}</div>
                <div class="data-title">今日活跃用户</div>
              </div>
            </div>
          </el-card>
        </el-col>
        
        <el-col :span="6">
          <el-card shadow="hover" class="overview-card">
            <div class="card-content">
              <div class="card-icon feedback-icon">
                <el-icon><StarFilled /></el-icon>
              </div>
              <div class="card-data">
                <div class="data-value">{{ averageRating }}%</div>
                <div class="data-title">平均满意度</div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
      
      <!-- 功能快捷入口 -->
      <h2 class="section-title">快捷功能</h2>
      <el-row :gutter="20">
        <el-col v-for="(item, index) in quickLinks" :key="index" :span="8">
          <el-card shadow="hover" class="quick-link-card" @click="navigateTo(item.path)">
            <div class="quick-link-content">
              <el-icon class="quick-link-icon"><component :is="item.icon" /></el-icon>
              <div class="quick-link-title">{{ item.title }}</div>
              <div class="quick-link-desc">{{ item.description }}</div>
            </div>
          </el-card>
        </el-col>
      </el-row>
      
      <!-- 系统状态 -->
      <h2 class="section-title">系统状态</h2>
      <el-row :gutter="20">
        <el-col :span="12">
          <el-card shadow="hover" class="chart-card">
            <template #header>
              <div class="card-header">
                <span>用户增长趋势</span>
                <el-radio-group v-model="userChartPeriod" size="small">
                  <el-radio-button label="week">周</el-radio-button>
                  <el-radio-button label="month">月</el-radio-button>
                  <el-radio-button label="year">年</el-radio-button>
                </el-radio-group>
              </div>
            </template>
            <div class="chart-placeholder">图表区域 - 用户增长趋势</div>
          </el-card>
        </el-col>
        
        <el-col :span="12">
          <el-card shadow="hover" class="chart-card">
            <template #header>
              <div class="card-header">
                <span>对话数量趋势</span>
                <el-radio-group v-model="chatChartPeriod" size="small">
                  <el-radio-button label="week">周</el-radio-button>
                  <el-radio-button label="month">月</el-radio-button>
                  <el-radio-button label="year">年</el-radio-button>
                </el-radio-group>
              </div>
            </template>
            <div class="chart-placeholder">图表区域 - 对话数量趋势</div>
          </el-card>
        </el-col>
      </el-row>
      
      <!-- 系统日志 -->
      <h2 class="section-title">最近系统日志</h2>
      <el-card shadow="hover" class="log-card">
        <el-table :data="systemLogs" style="width: 100%">
          <el-table-column prop="time" label="时间" width="180" />
          <el-table-column prop="type" label="类型" width="120" />
          <el-table-column prop="content" label="内容" />
          <el-table-column prop="user" label="操作人" width="120" />
          <el-table-column label="操作" width="120">
            <template #default>
              <el-button type="text" size="small">查看详情</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { 
  User, ChatLineRound, View, StarFilled, 
  Document, Setting, Tools
} from '@element-plus/icons-vue';

const router = useRouter();

// 示例数据
const userCount = ref(1024);
const chatCount = ref(8795);
const activeUsers = ref(256);
const averageRating = ref(94.8);

// 图表周期选择
const userChartPeriod = ref('week');
const chatChartPeriod = ref('week');

// 快捷功能链接
const quickLinks = ref([
  {
    title: '用户管理',
    description: '查看和管理系统用户',
    icon: 'User',
    path: '/admin/users/list'
  },
  {
    title: '内容管理',
    description: '管理知识库内容',
    icon: 'Document',
    path: '/admin/content/documents'
  },
  {
    title: '系统设置',
    description: '配置系统参数和模型',
    icon: 'Tools',
    path: '/admin/settings/ai-model'
  }
]);

// 系统日志
const systemLogs = ref([
  {
    time: '2023-04-12 14:32:45',
    type: '登录',
    content: '管理员登录系统',
    user: 'admin'
  },
  {
    time: '2023-04-12 13:21:18',
    type: '配置',
    content: '修改了AI模型参数',
    user: 'admin'
  },
  {
    time: '2023-04-12 10:05:37',
    type: '用户',
    content: '禁用了用户账号: user123',
    user: 'admin'
  },
  {
    time: '2023-04-11 16:47:22',
    type: '内容',
    content: '更新了知识库文档: 安全生产指南',
    user: 'editor'
  },
  {
    time: '2023-04-11 15:12:09',
    type: '系统',
    content: '系统备份完成',
    user: 'system'
  }
]);

// 导航到指定页面
const navigateTo = (path) => {
  router.push(path);
};
</script>

<style scoped>
.admin-dashboard {
  padding: 20px 0;
}

.page-header {
  margin-bottom: 20px;
}

.page-header h1 {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
  color: #1f2937;
}

.page-header p {
  margin: 8px 0 0;
  color: #6b7280;
  font-size: 14px;
}

.section-title {
  margin: 30px 0 15px;
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
}

/* 概览卡片样式 */
.overview-card {
  margin-bottom: 20px;
  border-radius: 8px;
  overflow: hidden;
}

.card-content {
  display: flex;
  align-items: center;
  padding: 10px;
}

.card-icon {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 60px;
  height: 60px;
  border-radius: 8px;
  margin-right: 15px;
}

.card-icon .el-icon {
  font-size: 30px;
  color: white;
}

.user-icon {
  background-color: #3b82f6;
}

.chat-icon {
  background-color: #10b981;
}

.active-icon {
  background-color: #f59e0b;
}

.feedback-icon {
  background-color: #8b5cf6;
}

.card-data {
  flex: 1;
}

.data-value {
  font-size: 24px;
  font-weight: 600;
  color: #1f2937;
  line-height: 1.2;
}

.data-title {
  font-size: 14px;
  color: #6b7280;
}

/* 快捷功能卡片 */
.quick-link-card {
  margin-bottom: 20px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
}

.quick-link-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
}

.quick-link-content {
  padding: 20px;
  text-align: center;
}

.quick-link-icon {
  font-size: 36px;
  margin-bottom: 15px;
  color: #3b82f6;
}

.quick-link-title {
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 8px;
}

.quick-link-desc {
  font-size: 14px;
  color: #6b7280;
}

/* 图表卡片 */
.chart-card {
  margin-bottom: 20px;
  border-radius: 8px;
  overflow: hidden;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chart-placeholder {
  height: 300px;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: #f9fafb;
  color: #9ca3af;
  font-size: 14px;
  border-radius: 4px;
}

/* 系统日志表格 */
.log-card {
  margin-bottom: 20px;
  border-radius: 8px;
  overflow: hidden;
}

@media (max-width: 768px) {
  .el-col {
    width: 100%;
  }
}
</style> 