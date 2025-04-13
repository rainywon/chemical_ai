<template>
  <div class="feedback-stats">
    <!-- 日期范围筛选 -->
    <div class="filter-container">
      <el-form :inline="true" :model="filterForm">
        <el-form-item label="时间范围">
          <el-date-picker
            v-model="filterForm.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            @change="handleDateChange"
          ></el-date-picker>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleFilter">查询</el-button>
          <el-button @click="resetFilter">重置</el-button>
        </el-form-item>
      </el-form>
    </div>
    
    <!-- 统计数据卡片 -->
    <div class="stats-overview">
      <el-row :gutter="20">
        <el-col :xs="24" :sm="12" :md="6">
          <el-card shadow="hover" class="stats-card">
            <div class="card-icon total-icon">
              <el-icon><DataAnalysis /></el-icon>
            </div>
            <div class="card-content">
              <div class="card-title">总反馈数</div>
              <div class="card-value">{{ statsData.total || 0 }}</div>
            </div>
          </el-card>
        </el-col>
        
        <el-col :xs="24" :sm="12" :md="6">
          <el-card shadow="hover" class="stats-card">
            <div class="card-icon resolved-icon">
              <el-icon><Check /></el-icon>
            </div>
            <div class="card-content">
              <div class="card-title">已解决</div>
              <div class="card-value">{{ statsData.resolved || 0 }}</div>
            </div>
          </el-card>
        </el-col>
        
        <el-col :xs="24" :sm="12" :md="6">
          <el-card shadow="hover" class="stats-card">
            <div class="card-icon pending-icon">
              <el-icon><Clock /></el-icon>
            </div>
            <div class="card-content">
              <div class="card-title">待处理</div>
              <div class="card-value">{{ statsData.pending || 0 }}</div>
            </div>
          </el-card>
        </el-col>
        
        <el-col :xs="24" :sm="12" :md="6">
          <el-card shadow="hover" class="stats-card">
            <div class="card-icon processing-icon">
              <el-icon><Loading /></el-icon>
            </div>
            <div class="card-content">
              <div class="card-title">处理中</div>
              <div class="card-value">{{ statsData.processing || 0 }}</div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>
    
    <!-- 图表区域 -->
    <div class="charts-container">
      <el-row :gutter="20">
        <!-- 反馈类型分布 -->
        <el-col :xs="24" :lg="12">
          <el-card shadow="hover" class="chart-card">
            <template #header>
              <div class="card-header">
                <span>反馈类型分布</span>
              </div>
            </template>
            <div class="chart-container" ref="typeChartContainer"></div>
          </el-card>
        </el-col>
        
        <!-- 反馈处理状态分布 -->
        <el-col :xs="24" :lg="12">
          <el-card shadow="hover" class="chart-card">
            <template #header>
              <div class="card-header">
                <span>反馈处理状态分布</span>
              </div>
            </template>
            <div class="chart-container" ref="statusChartContainer"></div>
          </el-card>
        </el-col>
      </el-row>
      
      <!-- 反馈趋势图 -->
      <el-row :gutter="20" class="trend-row">
        <el-col :span="24">
          <el-card shadow="hover" class="chart-card">
            <template #header>
              <div class="card-header">
                <span>反馈趋势分析</span>
                <el-radio-group v-model="trendTimeUnit" size="small" @change="handleTrendUnitChange">
                  <el-radio-button label="day">日</el-radio-button>
                  <el-radio-button label="week">周</el-radio-button>
                  <el-radio-button label="month">月</el-radio-button>
                </el-radio-group>
              </div>
            </template>
            <div class="chart-container trend-chart" ref="trendChartContainer"></div>
          </el-card>
        </el-col>
      </el-row>
    </div>
    
    <!-- 反馈类型明细表格 -->
    <el-card shadow="hover" class="stats-table-card">
      <template #header>
        <div class="card-header">
          <span>反馈类型明细</span>
        </div>
      </template>
      <el-table 
        :data="typeDetailsList" 
        border 
        style="width: 100%"
        :cell-style="{ padding: '12px 8px' }"
        :header-cell-style="{ background:'#f5f7fa', color:'#606266', fontWeight: 'bold' }">
        <el-table-column prop="type_name" label="反馈类型" align="center"></el-table-column>
        <el-table-column prop="total" label="数量" align="center"></el-table-column>
        <el-table-column prop="percentage" label="百分比" align="center">
          <template #default="scope">
            {{ scope.row.percentage }}%
          </template>
        </el-table-column>
        <el-table-column prop="resolved_rate" label="解决率" align="center">
          <template #default="scope">
            <el-progress 
              :percentage="scope.row.resolved_rate" 
              :color="getProgressColor(scope.row.resolved_rate)"
              :format="(percentage) => `${percentage}%`"
            ></el-progress>
          </template>
        </el-table-column>
        <el-table-column prop="avg_resolve_time" label="平均解决时间" align="center">
          <template #default="scope">
            {{ scope.row.avg_resolve_time || '暂无数据' }}
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted, watch } from 'vue';
import { ElMessage } from 'element-plus';
import { DataAnalysis, Check, Clock, Loading } from '@element-plus/icons-vue';
import { API_BASE_URL } from '../../../config';
import * as echarts from 'echarts/core';
import { PieChart, BarChart, LineChart } from 'echarts/charts';
import { GridComponent, TooltipComponent, TitleComponent, LegendComponent } from 'echarts/components';
import { CanvasRenderer } from 'echarts/renderers';

// 注册必须的组件
echarts.use([
  PieChart,
  BarChart,
  LineChart,
  GridComponent,
  TooltipComponent,
  TitleComponent,
  LegendComponent,
  CanvasRenderer
]);

// 图表实例
const typeChart = ref(null);
const statusChart = ref(null);
const trendChart = ref(null);

// 容器引用
const typeChartContainer = ref(null);
const statusChartContainer = ref(null);
const trendChartContainer = ref(null);

// 状态变量
const statsData = ref({});
const typeDetailsList = ref([]);
const trendTimeUnit = ref('day');
const trendData = ref({});

// 筛选表单
const filterForm = reactive({
  dateRange: []
});

// 获取统计数据
const fetchStatsData = async () => {
  try {
    const params = new URLSearchParams();
    
    if (filterForm.dateRange && filterForm.dateRange.length === 2) {
      const startDate = formatDate(filterForm.dateRange[0]);
      const endDate = formatDate(filterForm.dateRange[1]);
      params.append('start_date', startDate);
      params.append('end_date', endDate);
    }
    
    const adminId = localStorage.getItem('admin_id');
    if (adminId) {
      params.append('admin_id', adminId);
    }
    
    const response = await fetch(`${API_BASE_URL}/admin/feedback/stats?${params.toString()}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    const data = await response.json();
    
    if (data.code === 200) {
      statsData.value = data.data.overview;
      typeDetailsList.value = data.data.type_details;
      
      // 初始化图表
      initTypeChart(data.data.type_details);
      initStatusChart(data.data.status_distribution);
    } else {
      ElMessage.error(data.message || '获取反馈统计数据失败');
    }
  } catch (error) {
    console.error('获取反馈统计数据错误:', error);
    ElMessage.error('网络连接异常，请稍后再试');
  }
};

// 获取趋势数据
const fetchTrendData = async () => {
  try {
    const params = new URLSearchParams();
    params.append('time_unit', trendTimeUnit.value);
    
    if (filterForm.dateRange && filterForm.dateRange.length === 2) {
      const startDate = formatDate(filterForm.dateRange[0]);
      const endDate = formatDate(filterForm.dateRange[1]);
      params.append('start_date', startDate);
      params.append('end_date', endDate);
    }
    
    const adminId = localStorage.getItem('admin_id');
    if (adminId) {
      params.append('admin_id', adminId);
    }
    
    const response = await fetch(`${API_BASE_URL}/admin/feedback/trend?${params.toString()}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    const data = await response.json();
    
    if (data.code === 200) {
      trendData.value = data.data;
      initTrendChart(data.data);
    } else {
      ElMessage.error(data.message || '获取反馈趋势数据失败');
    }
  } catch (error) {
    console.error('获取反馈趋势数据错误:', error);
    ElMessage.error('网络连接异常，请稍后再试');
  }
};

// 初始化反馈类型分布图表
const initTypeChart = (data) => {
  if (!typeChartContainer.value) return;
  
  // 如果图表已存在则销毁
  if (typeChart.value) {
    typeChart.value.dispose();
  }
  
  // 数据处理
  const chartData = data.map(item => ({
    name: item.type_name,
    value: item.total
  }));
  
  // 创建图表实例
  typeChart.value = echarts.init(typeChartContainer.value);
  
  // 图表配置
  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b}: {c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      left: 'left',
      data: chartData.map(item => item.name)
    },
    series: [
      {
        name: '反馈类型',
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
            fontSize: '18',
            fontWeight: 'bold'
          }
        },
        labelLine: {
          show: false
        },
        data: chartData
      }
    ]
  };
  
  // 渲染图表
  typeChart.value.setOption(option);
};

// 初始化反馈状态分布图表
const initStatusChart = (data) => {
  if (!statusChartContainer.value) return;
  
  // 如果图表已存在则销毁
  if (statusChart.value) {
    statusChart.value.dispose();
  }
  
  // 数据处理
  const statusNames = {
    'pending': '待处理',
    'processing': '处理中',
    'resolved': '已解决',
    'rejected': '已拒绝'
  };
  
  const chartData = Object.entries(data).map(([key, value]) => ({
    name: statusNames[key] || key,
    value: value
  }));
  
  // 创建图表实例
  statusChart.value = echarts.init(statusChartContainer.value);
  
  // 图表配置
  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b}: {c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      left: 'left',
      data: chartData.map(item => item.name)
    },
    series: [
      {
        name: '处理状态',
        type: 'pie',
        radius: '50%',
        data: chartData,
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }
    ]
  };
  
  // 渲染图表
  statusChart.value.setOption(option);
};

// 初始化反馈趋势图表
const initTrendChart = (data) => {
  if (!trendChartContainer.value) return;
  
  // 如果图表已存在则销毁
  if (trendChart.value) {
    trendChart.value.dispose();
  }
  
  // 数据处理
  const xAxisData = data.labels;
  const seriesData = [
    {
      name: '总反馈',
      type: 'line',
      data: data.total,
      smooth: true,
      lineStyle: {
        width: 3,
        shadowColor: 'rgba(0,0,0,0.3)',
        shadowBlur: 10,
        shadowOffsetY: 8
      },
      emphasis: {
        focus: 'series'
      }
    },
    {
      name: '已解决',
      type: 'line',
      data: data.resolved,
      smooth: true,
      lineStyle: {
        width: 3
      },
      emphasis: {
        focus: 'series'
      }
    },
    {
      name: '待处理',
      type: 'line',
      data: data.pending,
      smooth: true,
      lineStyle: {
        width: 3
      },
      emphasis: {
        focus: 'series'
      }
    }
  ];
  
  // 创建图表实例
  trendChart.value = echarts.init(trendChartContainer.value);
  
  // 图表配置
  const option = {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      }
    },
    legend: {
      data: ['总反馈', '已解决', '待处理']
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      boundaryGap: false,
      data: xAxisData
    },
    yAxis: {
      type: 'value'
    },
    series: seriesData
  };
  
  // 渲染图表
  trendChart.value.setOption(option);
};

// 格式化日期
const formatDate = (date) => {
  const d = new Date(date);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
};

// 获取进度条颜色
const getProgressColor = (percentage) => {
  if (percentage < 50) return '#f56c6c';
  if (percentage < 80) return '#e6a23c';
  return '#67c23a';
};

// 筛选处理
const handleFilter = () => {
  fetchStatsData();
  fetchTrendData();
};

// 重置筛选
const resetFilter = () => {
  filterForm.dateRange = [];
  fetchStatsData();
  fetchTrendData();
};

// 日期范围变更
const handleDateChange = () => {
  // 可以在这里做一些日期相关的逻辑处理
};

// 趋势时间单位变更
const handleTrendUnitChange = () => {
  fetchTrendData();
};

// 窗口大小变化时重新绘制图表
const handleResize = () => {
  if (typeChart.value) typeChart.value.resize();
  if (statusChart.value) statusChart.value.resize();
  if (trendChart.value) trendChart.value.resize();
};

// 监视日期范围变化
watch(() => filterForm.dateRange, (newVal, oldVal) => {
  // 如果用户清空了日期范围，自动刷新数据
  if (!newVal || newVal.length === 0) {
    if (oldVal && oldVal.length > 0) {
      fetchStatsData();
      fetchTrendData();
    }
  }
});

// 页面加载时获取数据并初始化图表
onMounted(() => {
  fetchStatsData();
  fetchTrendData();
  
  // 添加窗口大小变化监听
  window.addEventListener('resize', handleResize);
});

// 组件卸载时清理
onUnmounted(() => {
  // 销毁图表实例
  if (typeChart.value) typeChart.value.dispose();
  if (statusChart.value) statusChart.value.dispose();
  if (trendChart.value) trendChart.value.dispose();
  
  // 移除窗口大小变化监听
  window.removeEventListener('resize', handleResize);
});
</script>

<style scoped>
.feedback-stats {
  padding: 20px;
}

.filter-container {
  background-color: #fff;
  padding: 20px;
  border-radius: 4px;
  margin-bottom: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.stats-overview {
  margin-bottom: 20px;
}

.stats-card {
  display: flex;
  align-items: center;
  padding: 20px;
  margin-bottom: 20px;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  transition: all 0.3s;
}

.stats-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
}

.card-icon {
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  border-radius: 12px;
  margin-right: 16px;
}

.total-icon {
  background-color: #ecf5ff;
  color: #409eff;
}

.resolved-icon {
  background-color: #f0f9eb;
  color: #67c23a;
}

.pending-icon {
  background-color: #e6f7ff;
  color: #1890ff;
}

.processing-icon {
  background-color: #fdf6ec;
  color: #e6a23c;
}

.card-content {
  flex: 1;
}

.card-title {
  font-size: 14px;
  color: #909399;
  margin-bottom: 8px;
}

.card-value {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
}

.chart-card {
  margin-bottom: 20px;
  height: 360px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chart-container {
  width: 100%;
  height: 280px;
}

.trend-chart {
  height: 350px;
}

.trend-row {
  margin-top: 20px;
}

.stats-table-card {
  margin-top: 20px;
}

/* 确保在小屏幕上良好显示 */
@media (max-width: 768px) {
  .stats-card {
    margin-bottom: 15px;
  }
  
  .chart-card {
    height: auto;
  }
  
  .chart-container, .trend-chart {
    height: 250px;
  }
}
</style> 