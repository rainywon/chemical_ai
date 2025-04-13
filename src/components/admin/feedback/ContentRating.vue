<template>
  <div class="content-rating">
    <!-- 筛选条件 -->
    <div class="filter-container">
      <el-form :inline="true" :model="filterForm" class="search-form">
        <el-form-item label="评分">
          <el-select v-model="filterForm.rating" placeholder="选择评分" clearable>
            <el-option v-for="i in 5" :key="i" :label="`${i}星`" :value="i"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="反馈选项">
          <el-select v-model="filterForm.feedbackOption" placeholder="选择反馈选项" clearable>
            <el-option v-for="option in feedbackOptions" :key="option.value" :label="option.label" :value="option.value"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="提交时间">
          <el-date-picker
            v-model="filterForm.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
          ></el-date-picker>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleFilter">查询</el-button>
          <el-button @click="resetFilter">重置</el-button>
        </el-form-item>
      </el-form>
    </div>
    
    <!-- 评分概览 -->
    <div class="rating-overview-container">
      <el-row :gutter="20">
        <el-col :span="24">
          <el-card shadow="hover">
            <div class="rating-overview">
              <div class="rating-header">
                <h3>内容评分概览</h3>
                <div class="average-rating">
                  <span class="average-label">平均评分:</span>
                  <span class="average-value">{{ summaryData.average_rating || 0 }}</span>
                  <el-rate
                    v-model="summaryData.average_rating"
                    disabled
                    show-score
                    text-color="#ff9900"
                    score-template=""
                  ></el-rate>
                </div>
              </div>
              
              <div class="rating-distribution">
                <div class="rating-bars">
                  <div v-for="n in 5" :key="n" class="rating-bar-item">
                    <span class="star-label">{{ n }}星</span>
                    <div class="progress-wrapper">
                      <el-progress 
                        :percentage="getRatingPercentage(n)"
                        :color="getRatingColor(n)"
                        :stroke-width="20"
                        :show-text="false"
                      ></el-progress>
                    </div>
                    <span class="count-label">{{ getRatingCount(n) }}</span>
                    <span class="percent-label">({{ getRatingPercentage(n) }}%)</span>
                  </div>
                </div>
                
                <div class="rating-pie-chart" ref="ratingPieChartRef"></div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>
    
    <!-- 反馈选项分析 -->
    <div class="feedback-analysis-container">
      <el-row :gutter="20">
        <el-col :span="24">
          <el-card shadow="hover">
            <template #header>
              <div class="card-header">
                <span>反馈选项分析</span>
              </div>
            </template>
            <div class="feedback-chart" ref="feedbackChartRef"></div>
          </el-card>
        </el-col>
      </el-row>
    </div>
    
    <!-- 用户评价列表 -->
    <div class="rating-list-container">
      <el-card shadow="hover">
        <template #header>
          <div class="card-header">
            <span>用户评价列表</span>
          </div>
        </template>
        <el-table 
          :data="ratingList" 
          border 
          style="width: 100%" 
          v-loading="loading"
          :cell-style="{ padding: '12px 8px' }"
          :header-cell-style="{ background:'#f5f7fa', color:'#606266', fontWeight: 'bold' }">
          <el-table-column prop="id" label="ID" min-width="80" align="center"></el-table-column>
          <el-table-column label="评分" min-width="120" align="center">
            <template #default="scope">
              <el-rate
                v-model="scope.row.rating"
                disabled
                text-color="#ff9900"
              ></el-rate>
            </template>
          </el-table-column>
          <el-table-column prop="feedback_option" label="反馈选项" min-width="120" align="center">
            <template #default="scope">
              <el-tag :type="getFeedbackOptionType(scope.row.feedback_option)">
                {{ getFeedbackOptionName(scope.row.feedback_option) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="feedback" label="评价内容" min-width="300" align="left" show-overflow-tooltip></el-table-column>
          <el-table-column prop="created_at" label="提交时间" min-width="160" align="center"></el-table-column>
          <el-table-column label="操作" width="120" align="center">
            <template #default="scope">
              <el-button size="small" type="primary" @click="handleViewDetail(scope.row)">查看详情</el-button>
            </template>
          </el-table-column>
        </el-table>
        
        <!-- 分页 -->
        <div class="pagination-container">
          <el-pagination
            background
            layout="total, sizes, prev, pager, next, jumper"
            :total="total"
            :page-size="pageSize"
            :page-sizes="[10, 20, 50, 100]"
            :current-page="currentPage"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          ></el-pagination>
        </div>
      </el-card>
    </div>
    
    <!-- 评价详情对话框 -->
    <el-dialog 
      title="评价详情" 
      v-model="dialogVisible" 
      width="700px"
      :close-on-click-modal="false"
    >
      <div class="rating-detail" v-if="currentRating">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="评价ID">{{ currentRating.id }}</el-descriptions-item>
          <el-descriptions-item label="评分">
            <el-rate v-model="currentRating.rating" disabled text-color="#ff9900"></el-rate>
          </el-descriptions-item>
          <el-descriptions-item label="反馈选项">
            <el-tag :type="getFeedbackOptionType(currentRating.feedback_option)">
              {{ getFeedbackOptionName(currentRating.feedback_option) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="评价内容">
            <div class="feedback-content">{{ currentRating.feedback }}</div>
          </el-descriptions-item>
          <el-descriptions-item label="提交时间">{{ currentRating.created_at }}</el-descriptions-item>
        </el-descriptions>
        
        <el-divider>用户问题</el-divider>
        <div class="question-content">{{ currentRating.question }}</div>
        
        <el-divider>AI回答</el-divider>
        <div class="message-content">{{ currentRating.message }}</div>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">关闭</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted } from 'vue';
import { ElMessage } from 'element-plus';
import { API_BASE_URL } from '../../../config';
import * as echarts from 'echarts/core';
import { PieChart, BarChart } from 'echarts/charts';
import { GridComponent, TooltipComponent, LegendComponent } from 'echarts/components';
import { CanvasRenderer } from 'echarts/renderers';

// 注册必须的组件
echarts.use([
  PieChart,
  BarChart,
  GridComponent,
  TooltipComponent,
  LegendComponent,
  CanvasRenderer
]);

// 图表实例
const ratingPieChart = ref(null);
const feedbackChart = ref(null);

// 图表容器引用
const ratingPieChartRef = ref(null);
const feedbackChartRef = ref(null);

// 状态变量
const loading = ref(false);
const ratingList = ref([]);
const summaryData = ref({
  average_rating: 0,
  rating_distribution: {},
  feedback_distribution: {}
});
const total = ref(0);
const pageSize = ref(10);
const currentPage = ref(1);
const dialogVisible = ref(false);
const currentRating = ref(null);

// 反馈选项列表
const feedbackOptions = [
  { label: '回答不准确', value: 'inaccurate' },
  { label: '回答不完整', value: 'incomplete' },
  { label: '不理解我的问题', value: 'misunderstood' },
  { label: '信息过时', value: 'outdated' },
  { label: '内容有误', value: 'incorrect' },
  { label: '其他原因', value: 'other' }
];

// 筛选表单
const filterForm = reactive({
  rating: '',
  feedbackOption: '',
  dateRange: []
});

// 获取评分数据统计
const fetchRatingSummary = async () => {
  try {
    const params = new URLSearchParams();
    
    if (filterForm.dateRange && filterForm.dateRange.length === 2) {
      const startDate = formatDate(filterForm.dateRange[0]);
      const endDate = formatDate(filterForm.dateRange[1]);
      params.append('start_date', startDate);
      params.append('end_date', endDate);
    }
    
    if (filterForm.rating) {
      params.append('rating', filterForm.rating);
    }
    
    if (filterForm.feedbackOption) {
      params.append('feedback_option', filterForm.feedbackOption);
    }
    
    const adminId = localStorage.getItem('admin_id');
    if (adminId) {
      params.append('admin_id', adminId);
    }
    
    const response = await fetch(`${API_BASE_URL}/admin/feedback/content-rating-summary?${params.toString()}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    const data = await response.json();
    
    if (data.code === 200) {
      summaryData.value = data.data;
      
      // 渲染图表
      renderRatingPieChart();
      renderFeedbackChart();
    } else {
      ElMessage.error(data.message || '获取评分统计数据失败');
    }
  } catch (error) {
    console.error('获取评分统计数据错误:', error);
    ElMessage.error('网络连接异常，请稍后再试');
  }
};

// 获取评分列表
const fetchRatingList = async () => {
  loading.value = true;
  try {
    const params = new URLSearchParams();
    params.append('page', currentPage.value);
    params.append('page_size', pageSize.value);
    
    if (filterForm.rating) {
      params.append('rating', filterForm.rating);
    }
    
    if (filterForm.feedbackOption) {
      params.append('feedback_option', filterForm.feedbackOption);
    }
    
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
    
    const response = await fetch(`${API_BASE_URL}/admin/feedback/content-rating-list?${params.toString()}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    const data = await response.json();
    
    if (data.code === 200) {
      ratingList.value = data.data.list;
      total.value = data.data.total;
    } else {
      ElMessage.error(data.message || '获取评价列表失败');
    }
  } catch (error) {
    console.error('获取评价列表错误:', error);
    ElMessage.error('网络连接异常，请稍后再试');
  } finally {
    loading.value = false;
  }
};

// 渲染评分饼图
const renderRatingPieChart = () => {
  if (!ratingPieChartRef.value) return;
  
  // 如果图表已存在则销毁
  if (ratingPieChart.value) {
    ratingPieChart.value.dispose();
  }
  
  // 数据处理
  const distribution = summaryData.value.rating_distribution || {};
  const chartData = [];
  
  for (let i = 5; i >= 1; i--) {
    chartData.push({
      name: `${i}星`,
      value: distribution[i] || 0
    });
  }
  
  // 创建图表实例
  ratingPieChart.value = echarts.init(ratingPieChartRef.value);
  
  // 图表配置
  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b}: {c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      right: 10,
      top: 'center',
      data: chartData.map(item => item.name)
    },
    series: [
      {
        name: '评分分布',
        type: 'pie',
        radius: ['40%', '65%'],
        avoidLabelOverlap: false,
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
        data: chartData,
        color: ['#67c23a', '#95d475', '#e6a23c', '#f56c6c', '#909399'].reverse()
      }
    ]
  };
  
  // 渲染图表
  ratingPieChart.value.setOption(option);
};

// 渲染反馈选项柱状图
const renderFeedbackChart = () => {
  if (!feedbackChartRef.value) return;
  
  // 如果图表已存在则销毁
  if (feedbackChart.value) {
    feedbackChart.value.dispose();
  }
  
  // 数据处理
  const distribution = summaryData.value.feedback_distribution || {};
  const optionMap = {};
  
  feedbackOptions.forEach(option => {
    optionMap[option.value] = option.label;
  });
  
  const chartData = Object.entries(distribution).map(([key, value]) => ({
    name: optionMap[key] || key,
    value: value
  }));
  
  // 创建图表实例
  feedbackChart.value = echarts.init(feedbackChartRef.value);
  
  // 图表配置
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
      type: 'category',
      data: chartData.map(item => item.name),
      axisLabel: {
        interval: 0,
        rotate: 30
      }
    },
    yAxis: {
      type: 'value'
    },
    series: [
      {
        name: '反馈数量',
        type: 'bar',
        barWidth: '60%',
        data: chartData.map(item => item.value),
        itemStyle: {
          color: function(params) {
            const colorList = ['#409eff', '#67c23a', '#e6a23c', '#f56c6c', '#909399', '#9370db'];
            return colorList[params.dataIndex % colorList.length];
          }
        }
      }
    ]
  };
  
  // 渲染图表
  feedbackChart.value.setOption(option);
};

// 获取特定评分的数量
const getRatingCount = (rating) => {
  const distribution = summaryData.value.rating_distribution || {};
  return distribution[rating] || 0;
};

// 获取特定评分的百分比
const getRatingPercentage = (rating) => {
  const distribution = summaryData.value.rating_distribution || {};
  const count = distribution[rating] || 0;
  const total = Object.values(distribution).reduce((sum, curr) => sum + curr, 0);
  
  if (total === 0) return 0;
  return Math.round((count / total) * 100);
};

// 获取评分对应的颜色
const getRatingColor = (rating) => {
  const colors = {
    5: '#67c23a',  // 绿色
    4: '#95d475',  // 浅绿
    3: '#e6a23c',  // 黄色
    2: '#f56c6c',  // 红色
    1: '#909399'   // 灰色
  };
  return colors[rating] || '#409eff';
};

// 获取反馈选项显示名称
const getFeedbackOptionName = (optionValue) => {
  const option = feedbackOptions.find(opt => opt.value === optionValue);
  return option ? option.label : optionValue;
};

// 获取反馈选项标签类型
const getFeedbackOptionType = (optionValue) => {
  const types = {
    'inaccurate': 'danger',
    'incomplete': 'warning',
    'misunderstood': 'info',
    'outdated': 'warning',
    'incorrect': 'danger',
    'other': ''
  };
  return types[optionValue] || '';
};

// 格式化日期
const formatDate = (date) => {
  const d = new Date(date);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
};

// 筛选处理
const handleFilter = () => {
  currentPage.value = 1;
  fetchRatingSummary();
  fetchRatingList();
};

// 重置筛选
const resetFilter = () => {
  filterForm.rating = '';
  filterForm.feedbackOption = '';
  filterForm.dateRange = [];
  currentPage.value = 1;
  fetchRatingSummary();
  fetchRatingList();
};

// 分页大小改变
const handleSizeChange = (size) => {
  pageSize.value = size;
  fetchRatingList();
};

// 当前页码改变
const handleCurrentChange = (page) => {
  currentPage.value = page;
  fetchRatingList();
};

// 查看评价详情
const handleViewDetail = (rating) => {
  currentRating.value = { ...rating };
  dialogVisible.value = true;
};

// 窗口大小变化时重新绘制图表
const handleResize = () => {
  if (ratingPieChart.value) ratingPieChart.value.resize();
  if (feedbackChart.value) feedbackChart.value.resize();
};

// 页面加载时获取数据
onMounted(() => {
  fetchRatingSummary();
  fetchRatingList();
  
  // 添加窗口大小变化监听
  window.addEventListener('resize', handleResize);
});

// 组件卸载时清理
onUnmounted(() => {
  // 销毁图表实例
  if (ratingPieChart.value) ratingPieChart.value.dispose();
  if (feedbackChart.value) feedbackChart.value.dispose();
  
  // 移除窗口大小变化监听
  window.removeEventListener('resize', handleResize);
});
</script>

<style scoped>
.content-rating {
  padding: 20px;
}

.filter-container {
  background-color: #fff;
  padding: 20px;
  border-radius: 4px;
  margin-bottom: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.rating-overview-container, 
.feedback-analysis-container,
.rating-list-container {
  margin-bottom: 20px;
}

.rating-overview {
  padding: 10px 20px;
}

.rating-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.rating-header h3 {
  margin: 0;
  font-size: 18px;
  color: #303133;
}

.average-rating {
  display: flex;
  align-items: center;
}

.average-label {
  margin-right: 8px;
  font-size: 14px;
  color: #606266;
}

.average-value {
  font-size: 22px;
  font-weight: bold;
  color: #ff9900;
  margin-right: 8px;
}

.rating-distribution {
  display: flex;
  justify-content: space-between;
}

.rating-bars {
  flex: 1;
  margin-right: 20px;
}

.rating-bar-item {
  display: flex;
  align-items: center;
  margin-bottom: 15px;
}

.star-label {
  min-width: 40px;
  color: #606266;
}

.progress-wrapper {
  flex: 1;
  margin: 0 15px;
}

.count-label {
  min-width: 40px;
  text-align: right;
  color: #606266;
}

.percent-label {
  min-width: 60px;
  text-align: right;
  color: #909399;
}

.rating-pie-chart {
  width: 300px;
  height: 240px;
}

.feedback-chart {
  width: 100%;
  height: 350px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header span {
  font-size: 16px;
  font-weight: bold;
}

.pagination-container {
  margin-top: 20px;
  text-align: right;
}

.rating-detail {
  padding: 10px;
}

.feedback-content,
.question-content,
.message-content {
  white-space: pre-wrap;
  line-height: 1.5;
  padding: 10px;
  background-color: #f8f9fa;
  border-radius: 4px;
  color: #303133;
  max-height: 200px;
  overflow-y: auto;
}

/* 响应式样式 */
@media (max-width: 992px) {
  .rating-distribution {
    flex-direction: column;
  }
  
  .rating-pie-chart {
    width: 100%;
    height: 220px;
    margin-top: 20px;
  }
  
  .rating-bars {
    margin-right: 0;
  }
}
</style> 