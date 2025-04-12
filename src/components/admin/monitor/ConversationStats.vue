<template>
  <div class="conversation-stats">
    <h1 class="page-title">对话数据统计</h1>
    
    <!-- 数据概览卡片 -->
    <div class="stats-cards">
      <div class="stat-card">
        <div class="stat-icon">
          <i class="el-icon-chat-line-round"></i>
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ totalSessions }}</div>
          <div class="stat-label">总对话数</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon">
          <i class="el-icon-message"></i>
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ totalMessages }}</div>
          <div class="stat-label">总消息数</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon">
          <i class="el-icon-s-custom"></i>
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ activeUsers }}</div>
          <div class="stat-label">活跃用户数</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon">
          <i class="el-icon-timer"></i>
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ avgMessagesPerSession.toFixed(1) }}</div>
          <div class="stat-label">平均消息/对话</div>
        </div>
      </div>
    </div>
    
    <!-- 时间筛选 -->
    <div class="filter-container">
      <el-date-picker
        v-model="dateRange"
        type="daterange"
        range-separator="至"
        start-placeholder="开始日期"
        end-placeholder="结束日期"
        @change="handleDateChange"
      ></el-date-picker>
    </div>
    
    <!-- 对话趋势图 -->
    <div class="chart-container">
      <div class="chart-header">
        <h2>对话趋势</h2>
        <div class="chart-actions">
          <el-radio-group v-model="timeUnit" @change="handleTimeUnitChange">
            <el-radio-button label="day">日</el-radio-button>
            <el-radio-button label="week">周</el-radio-button>
            <el-radio-button label="month">月</el-radio-button>
          </el-radio-group>
        </div>
      </div>
      <div class="chart" ref="conversationTrendChart"></div>
    </div>
    
    <!-- 消息类型分布 -->
    <div class="charts-row">
      <div class="chart-container half-width">
        <h2>消息类型分布</h2>
        <div class="chart" ref="messageTypeChart"></div>
      </div>
      
      <!-- 热门对话主题 -->
      <div class="chart-container half-width">
        <h2>热门对话主题</h2>
        <div class="chart" ref="topicsChart"></div>
      </div>
    </div>
    
    <!-- 最近对话列表 -->
    <div class="recent-conversations">
      <h2>最近对话</h2>
      <el-table :data="recentConversations" style="width: 100%">
        <el-table-column prop="id" label="会话ID" width="220"></el-table-column>
        <el-table-column prop="title" label="标题"></el-table-column>
        <el-table-column prop="user_id" label="用户ID" width="100"></el-table-column>
        <el-table-column prop="message_count" label="消息数" width="100"></el-table-column>
        <el-table-column prop="created_at" label="创建时间" width="180"></el-table-column>
        <el-table-column prop="updated_at" label="更新时间" width="180"></el-table-column>
      </el-table>
      <div class="pagination">
        <el-pagination
          layout="prev, pager, next"
          :total="totalSessionsCount"
          :page-size="pageSize"
          @current-change="handlePageChange"
        ></el-pagination>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import * as echarts from 'echarts';

// 状态变量
const totalSessions = ref(0);
const totalMessages = ref(0);
const activeUsers = ref(0);
const avgMessagesPerSession = ref(0);
const dateRange = ref([]);
const timeUnit = ref('day');
const recentConversations = ref([]);
const totalSessionsCount = ref(0);
const pageSize = ref(10);
const currentPage = ref(1);

// 图表引用
const conversationTrendChart = ref(null);
const messageTypeChart = ref(null);
const topicsChart = ref(null);
let trendChartInstance = null;
let messageTypeChartInstance = null;
let topicsChartInstance = null;

// 计算属性和方法
const handleDateChange = () => {
  fetchStatisticsData();
};

const handleTimeUnitChange = () => {
  renderConversationTrendChart();
};

const handlePageChange = (page) => {
  currentPage.value = page;
  fetchRecentConversations();
};

// 模拟数据 (后续替换为真实API调用)
const fetchStatisticsData = () => {
  // 模拟数据
  totalSessions.value = 1243;
  totalMessages.value = 9567;
  activeUsers.value = 378;
  avgMessagesPerSession.value = 7.7;
  
  renderCharts();
};

const fetchRecentConversations = () => {
  // 模拟最近对话数据
  recentConversations.value = [
    {
      id: '3ad1b243-41c0-4a2b-aee7-d9772300d832',
      title: '粉尘治理怎么做',
      user_id: '13',
      message_count: 4,
      created_at: '2025-04-12 14:46:10',
      updated_at: '2025-04-12 14:48:14'
    },
    {
      id: 'fd8a7b52-6c1e-4f53-9e28-8a419b76c123',
      title: '化学泄漏应急预案',
      user_id: '15',
      message_count: 12,
      created_at: '2025-04-11 10:23:45',
      updated_at: '2025-04-11 10:45:12'
    },
    {
      id: 'a5e1c983-0f21-4d67-b32a-9c81e567d890',
      title: '危险化学品存储规范',
      user_id: '22',
      message_count: 8,
      created_at: '2025-04-10 16:12:33',
      updated_at: '2025-04-10 16:30:44'
    },
    {
      id: '7b4e9f12-8d23-4a56-b789-0c12d3e4f567',
      title: '工厂消防设备检查',
      user_id: '8',
      message_count: 15,
      created_at: '2025-04-09 09:45:21',
      updated_at: '2025-04-09 10:15:33'
    },
    {
      id: '2c3d4e5f-6a7b-8c9d-0e1f-2a3b4c5d6e7f',
      title: '有毒气体检测方法',
      user_id: '17',
      message_count: 6,
      created_at: '2025-04-08 14:27:39',
      updated_at: '2025-04-08 14:38:52'
    }
  ];
  
  totalSessionsCount.value = 126;
};

// 图表渲染函数
const renderCharts = () => {
  renderConversationTrendChart();
  renderMessageTypeChart();
  renderTopicsChart();
};

const renderConversationTrendChart = () => {
  if (!trendChartInstance) {
    trendChartInstance = echarts.init(conversationTrendChart.value);
  }
  
  // 生成模拟数据
  const dates = [];
  const sessionData = [];
  const messageData = [];
  
  // 根据选择的时间单位生成数据
  let daysToShow = 14; // 默认显示两周
  if (timeUnit.value === 'week') daysToShow = 12; // 12周
  if (timeUnit.value === 'month') daysToShow = 12; // 12个月
  
  const today = new Date();
  
  for (let i = daysToShow - 1; i >= 0; i--) {
    const date = new Date();
    
    if (timeUnit.value === 'day') {
      date.setDate(today.getDate() - i);
      dates.push(date.getMonth() + 1 + '/' + date.getDate());
    } else if (timeUnit.value === 'week') {
      date.setDate(today.getDate() - i * 7);
      dates.push('第' + (daysToShow - i) + '周');
    } else {
      date.setMonth(today.getMonth() - i);
      dates.push(date.getMonth() + 1 + '月');
    }
    
    // 生成随机数据
    sessionData.push(Math.floor(Math.random() * 50) + 20);
    messageData.push(Math.floor(Math.random() * 300) + 100);
  }
  
  const option = {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      }
    },
    legend: {
      data: ['对话数', '消息数']
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: dates
    },
    yAxis: [
      {
        type: 'value',
        name: '对话数',
        position: 'left'
      },
      {
        type: 'value',
        name: '消息数',
        position: 'right'
      }
    ],
    series: [
      {
        name: '对话数',
        type: 'bar',
        data: sessionData
      },
      {
        name: '消息数',
        type: 'line',
        yAxisIndex: 1,
        data: messageData
      }
    ]
  };
  
  trendChartInstance.setOption(option);
};

const renderMessageTypeChart = () => {
  if (!messageTypeChartInstance) {
    messageTypeChartInstance = echarts.init(messageTypeChart.value);
  }
  
  const option = {
    tooltip: {
      trigger: 'item'
    },
    legend: {
      top: 'bottom'
    },
    series: [
      {
        name: '消息类型',
        type: 'pie',
        radius: ['40%', '70%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 10,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: false,
          position: 'center'
        },
        emphasis: {
          label: {
            show: true,
            fontSize: '20',
            fontWeight: 'bold'
          }
        },
        labelLine: {
          show: false
        },
        data: [
          { value: 5238, name: '用户消息' },
          { value: 4329, name: 'AI回复' }
        ]
      }
    ]
  };
  
  messageTypeChartInstance.setOption(option);
};

const renderTopicsChart = () => {
  if (!topicsChartInstance) {
    topicsChartInstance = echarts.init(topicsChart.value);
  }
  
  const option = {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'value',
      boundaryGap: [0, 0.01]
    },
    yAxis: {
      type: 'category',
      data: ['粉尘治理', '危险化学品', '安全预案', '设备检查', '防护装备', '泄漏处理']
    },
    series: [
      {
        name: '对话次数',
        type: 'bar',
        data: [89, 76, 65, 54, 48, 42]
      }
    ]
  };
  
  topicsChartInstance.setOption(option);
};

// 生命周期钩子
onMounted(() => {
  fetchStatisticsData();
  fetchRecentConversations();
  
  // 窗口大小变化时重新调整图表大小
  window.addEventListener('resize', () => {
    trendChartInstance?.resize();
    messageTypeChartInstance?.resize();
    topicsChartInstance?.resize();
  });
});
</script>

<style scoped>
.conversation-stats {
  padding: 20px;
}

.page-title {
  margin-bottom: 24px;
  font-size: 24px;
  font-weight: 500;
  color: #333;
}

.stats-cards {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  flex: 1;
  min-width: 200px;
  background-color: #fff;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
}

.stat-icon {
  font-size: 36px;
  margin-right: 16px;
  color: #409EFF;
}

.stat-content {
  display: flex;
  flex-direction: column;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #909399;
}

.filter-container {
  margin-bottom: 24px;
  display: flex;
  justify-content: flex-end;
}

.chart-container {
  background-color: #fff;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 24px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.chart-header h2 {
  margin: 0;
  font-size: 18px;
  font-weight: 500;
}

.chart {
  height: 350px;
}

.charts-row {
  display: flex;
  gap: 20px;
  margin-bottom: 24px;
}

.half-width {
  flex: 1;
}

.recent-conversations {
  background-color: #fff;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.recent-conversations h2 {
  margin-top: 0;
  margin-bottom: 16px;
  font-size: 18px;
  font-weight: 500;
}

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}

@media (max-width: 768px) {
  .stats-cards {
    flex-direction: column;
  }
  
  .charts-row {
    flex-direction: column;
  }
  
  .chart {
    height: 300px;
  }
}
</style> 