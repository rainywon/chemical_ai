<template>
  <div class="admin-dashboard">
    <h1 class="dashboard-title">管理员控制台</h1>
    
    <!-- 1. 核心数据概览区域 -->
    <el-row :gutter="20" class="data-overview">
      <!-- 用户统计 -->
      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="overview-card user-card" shadow="hover">
          <div class="card-header">
            <div class="card-icon"><i class="el-icon-user"></i></div>
            <div class="card-title">用户统计</div>
          </div>
          <div class="card-body">
            <div class="data-item">
              <span class="data-label">总用户数量</span>
              <span class="data-value">{{ stats.totalUsers }}</span>
            </div>
            <div class="data-item">
              <span class="data-label">今日新增</span>
              <span class="data-value">{{ stats.newUsers }}</span>
              <span class="data-trend" :class="stats.newUsersTrend > 0 ? 'up' : 'down'" v-if="stats.newUsersTrend">
                {{ Math.abs(stats.newUsersTrend) }}%
              </span>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <!-- 内容统计 -->
      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="overview-card content-card" shadow="hover">
          <div class="card-header">
            <div class="card-icon"><i class="el-icon-document"></i></div>
            <div class="card-title">内容统计</div>
          </div>
          <div class="card-body">
            <div class="data-item">
              <span class="data-label">总文档数量</span>
              <span class="data-value">{{ stats.totalDocuments }}</span>
            </div>
            <div class="data-item">
              <span class="data-label">应急预案</span>
              <span class="data-value">{{ stats.emergencyPlans }}</span>
            </div>
            <div class="data-item">
              <span class="data-label">分类数量</span>
              <span class="data-value">{{ stats.categories }}</span>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <!-- 系统活跃度 -->
      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="overview-card activity-card" shadow="hover">
          <div class="card-header">
            <div class="card-icon"><i class="el-icon-chat-line-round"></i></div>
            <div class="card-title">系统活跃度</div>
          </div>
          <div class="card-body">
            <div class="data-item">
              <span class="data-label">总对话数量</span>
              <span class="data-value">{{ stats.totalSessions }}</span>
            </div>
            <div class="data-item">
              <span class="data-label">活跃用户数</span>
              <span class="data-value">{{ stats.activeUsers }}</span>
            </div>
            <div class="data-item">
              <span class="data-label">平均消息/对话</span>
              <span class="data-value">{{ stats.avgMessagesPerSession.toFixed(1) }}</span>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <!-- 反馈统计 -->
      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="overview-card feedback-card" shadow="hover">
          <div class="card-header">
            <div class="card-icon"><i class="el-icon-star-on"></i></div>
            <div class="card-title">反馈统计</div>
          </div>
          <div class="card-body">
            <div class="data-item">
              <span class="data-label">总反馈数量</span>
              <span class="data-value">{{ stats.totalFeedbacks }}</span>
            </div>
            <div class="data-item">
              <span class="data-label">系统功能反馈</span>
              <span class="data-value">{{ stats.systemFeedbacks }}</span>
            </div>
            <div class="data-item">
              <span class="data-label">AI内容反馈</span>
              <span class="data-value">{{ stats.contentFeedbacks }}</span>
            </div>
            <div class="data-item">
              <span class="data-label">平均评分</span>
              <span class="data-value">{{ stats.avgRating.toFixed(1) }}</span>
              <div class="rating-stars">
                <el-rate v-model="stats.avgRating" disabled text-color="#ff9900"></el-rate>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
    
    <!-- 2. 趋势图表区域 -->
    <el-row :gutter="20" class="chart-section">
      <!-- 用户活跃度趋势图 -->
      <el-col :xs="24" :lg="8">
        <el-card class="chart-card" shadow="hover">
          <div class="chart-header">
            <h3 class="chart-title">用户活跃度趋势</h3>
            <div class="chart-actions">
              <el-radio-group v-model="userChartTimeRange" size="small" @change="loadUserActivityChart">
                <el-radio-button label="7">7天</el-radio-button>
                <el-radio-button label="30">30天</el-radio-button>
              </el-radio-group>
            </div>
          </div>
          <div class="chart-container" ref="userActivityChart"></div>
        </el-card>
      </el-col>
      
      <!-- 对话数量趋势图 -->
      <el-col :xs="24" :lg="8">
        <el-card class="chart-card" shadow="hover">
          <div class="chart-header">
            <h3 class="chart-title">对话数量趋势</h3>
            <div class="chart-actions">
              <el-radio-group v-model="conversationChartTimeRange" size="small" @change="loadConversationChart">
                <el-radio-button label="7">7天</el-radio-button>
                <el-radio-button label="30">30天</el-radio-button>
              </el-radio-group>
            </div>
          </div>
          <div class="chart-container" ref="conversationChart"></div>
        </el-card>
      </el-col>
      
      <!-- 反馈评分趋势图 -->
      <el-col :xs="24" :lg="8">
        <el-card class="chart-card" shadow="hover">
          <div class="chart-header">
            <h3 class="chart-title">反馈评分趋势</h3>
            <div class="chart-actions">
              <el-radio-group v-model="feedbackChartTimeRange" size="small" @change="loadFeedbackChart">
                <el-radio-button label="7">7天</el-radio-button>
                <el-radio-button label="30">30天</el-radio-button>
              </el-radio-group>
            </div>
          </div>
          <div class="chart-container" ref="feedbackChart"></div>
        </el-card>
      </el-col>
    </el-row>
    
    <!-- 3. 最近活动区域 -->
    <el-row :gutter="20" class="activity-section">
      <!-- 最近对话列表 -->
      <el-col :xs="24" :md="8">
        <el-card class="activity-card" shadow="hover">
          <template #header>
            <div class="card-header-with-action">
              <h3 class="section-title">最近对话</h3>
              <router-link to="/admin/monitor/conversation" class="view-more">查看更多</router-link>
            </div>
          </template>
          <div class="activity-list">
            <el-table :data="recentConversations" style="width: 100%" size="small" :show-header="false">
              <el-table-column>
                <template #default="scope">
                  <div class="activity-item">
                    <div class="activity-icon conversation-icon">
                      <i class="el-icon-chat-dot-round"></i>
                    </div>
                    <div class="activity-content">
                      <div class="activity-title">{{ scope.row.title || '无标题对话' }}</div>
                      <div class="activity-meta">
                        <span>用户: {{ scope.row.user_id }}</span>
                        <span>消息数: {{ scope.row.message_count }}</span>
                        <span class="activity-time">{{ scope.row.created_at }}</span>
                      </div>
                    </div>
                  </div>
                </template>
              </el-table-column>
            </el-table>
            <div class="empty-data" v-if="recentConversations.length === 0">
              <i class="el-icon-chat-dot-round"></i>
              <span>暂无对话数据</span>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <!-- 最近用户登录 -->
      <el-col :xs="24" :md="8">
        <el-card class="activity-card" shadow="hover">
          <template #header>
            <div class="card-header-with-action">
              <h3 class="section-title">最近登录</h3>
              <router-link to="/admin/users/login-history" class="view-more">查看更多</router-link>
            </div>
          </template>
          <div class="activity-list">
            <el-table :data="recentLogins" style="width: 100%" size="small" :show-header="false">
              <el-table-column>
                <template #default="scope">
                  <div class="activity-item">
                    <div class="activity-icon login-icon">
                      <i class="el-icon-user"></i>
                    </div>
                    <div class="activity-content">
                      <div class="activity-title">用户登录</div>
                      <div class="activity-meta">
                        <span>用户: {{ scope.row.user_id }}</span>
                        <span>IP: {{ scope.row.ip_address }}</span>
                        <span class="activity-time">{{ scope.row.login_time }}</span>
                      </div>
                    </div>
                  </div>
                </template>
              </el-table-column>
            </el-table>
            <div class="empty-data" v-if="recentLogins.length === 0">
              <i class="el-icon-user"></i>
              <span>暂无登录数据</span>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <!-- 最新反馈 -->
      <el-col :xs="24" :md="8">
        <el-card class="activity-card" shadow="hover">
          <template #header>
            <div class="card-header-with-action">
              <h3 class="section-title">最新反馈</h3>
              <router-link to="/admin/feedback/ratings" class="view-more">查看更多</router-link>
            </div>
          </template>
          <div class="activity-list">
            <el-table :data="recentFeedbacks" style="width: 100%" size="small" :show-header="false">
              <el-table-column>
                <template #default="scope">
                  <div class="activity-item">
                    <div class="activity-icon feedback-icon" :class="getFeedbackIconClass(scope.row.type)">
                      <i :class="getFeedbackIcon(scope.row.type)"></i>
                    </div>
                    <div class="activity-content">
                      <div class="activity-title">
                        <el-tag size="small" :type="getFeedbackType(scope.row.type)">{{ scope.row.typeLabel }}</el-tag>
                        <span v-if="scope.row.rating" class="feedback-rating">
                          <el-rate v-model="scope.row.rating" disabled :colors="ratingColors" :max="5"></el-rate>
                        </span>
                      </div>
                      <div class="activity-desc">{{ scope.row.content }}</div>
                      <div class="activity-meta">
                        <span class="activity-time">{{ scope.row.created_at }}</span>
                      </div>
                    </div>
                  </div>
                </template>
              </el-table-column>
            </el-table>
            <div class="empty-data" v-if="recentFeedbacks.length === 0">
              <i class="el-icon-star-on"></i>
              <span>暂无反馈数据</span>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
    
    <!-- 4. 系统状态区域 & 5. 待处理事项区域 -->
    <el-row :gutter="20" class="status-section">
      <!-- 系统状态区域 -->
      <el-col :xs="24" :lg="16">
        <el-card class="status-card" shadow="hover">
          <template #header>
            <div class="card-header-with-action">
              <h3 class="section-title">系统状态</h3>
              <router-link to="/admin/settings/system-params" class="view-more">系统设置</router-link>
            </div>
          </template>
          <el-row :gutter="20">
            <!-- 系统参数 -->
            <el-col :xs="24" :md="8">
              <div class="status-block">
                <h4 class="block-title">系统参数</h4>
                <ul class="param-list">
                  <li v-for="(param, index) in systemParams" :key="index" class="param-item">
                    <span class="param-label">{{ param.name }}</span>
                    <span class="param-value">{{ param.value }}</span>
                  </li>
                </ul>
              </div>
            </el-col>
            
            <!-- 操作日志 -->
            <el-col :xs="24" :md="8">
              <div class="status-block">
                <h4 class="block-title">最近操作日志</h4>
                <ul class="log-list">
                  <li v-for="(log, index) in operationLogs" :key="index" class="log-item">
                    <div class="log-content">
                      <span class="log-admin">{{ log.admin_name }}</span>
                      <span class="log-action">{{ log.action }}</span>
                    </div>
                    <span class="log-time">{{ log.operation_time }}</span>
                  </li>
                </ul>
                <div class="block-footer">
                  <router-link to="/admin/admins/logs" class="view-more-link">查看所有日志</router-link>
                </div>
              </div>
            </el-col>
            
            <!-- 系统版本 -->
            <el-col :xs="24" :md="8">
              <div class="status-block">
                <h4 class="block-title">系统版本</h4>
                <div class="version-info">
                  <div class="current-version">
                    <span class="version-label">当前版本</span>
                    <span class="version-number">{{ systemVersion.version_number }}</span>
                  </div>
                  <div class="version-date">
                    <span class="version-label">发布日期</span>
                    <span class="version-value">{{ systemVersion.release_date }}</span>
                  </div>
                  <div class="version-notes">
                    <div class="notes-title">更新内容：</div>
                    <div class="notes-content">{{ systemVersion.update_notes }}</div>
                  </div>
                </div>
              </div>
            </el-col>
          </el-row>
        </el-card>
      </el-col>
      
      <!-- 待处理事项区域 -->
      <el-col :xs="24" :lg="8">
        <el-card class="todo-card" shadow="hover">
          <template #header>
            <div class="card-header-with-action">
              <h3 class="section-title">待处理事项</h3>
              <el-button type="primary" size="small" round @click="refreshTodo">刷新</el-button>
            </div>
          </template>
          
          <div class="todo-list">
            <!-- 待处理反馈 -->
            <router-link to="/admin/feedback/list" class="todo-item" v-if="pendingItems.feedbacks > 0">
              <div class="todo-icon feedback-icon">
                <i class="el-icon-message"></i>
                <el-badge :value="pendingItems.feedbacks" class="todo-badge"></el-badge>
              </div>
              <div class="todo-content">
                <div class="todo-title">待处理反馈</div>
                <div class="todo-desc">有 {{ pendingItems.feedbacks }} 条用户反馈等待处理</div>
              </div>
              <div class="todo-action">
                <i class="el-icon-arrow-right"></i>
              </div>
            </router-link>
            
            <!-- 待审核内容 -->
            <router-link to="/admin/content/document-manager" class="todo-item" v-if="pendingItems.documents > 0">
              <div class="todo-icon document-icon">
                <i class="el-icon-document"></i>
                <el-badge :value="pendingItems.documents" class="todo-badge"></el-badge>
              </div>
              <div class="todo-content">
                <div class="todo-title">待审核内容</div>
                <div class="todo-desc">有 {{ pendingItems.documents }} 份文档等待审核</div>
              </div>
              <div class="todo-action">
                <i class="el-icon-arrow-right"></i>
              </div>
            </router-link>
            
            <!-- 系统告警 -->
            <div class="todo-item warning-item" v-if="pendingItems.warnings > 0">
              <div class="todo-icon warning-icon">
                <i class="el-icon-warning"></i>
                <el-badge :value="pendingItems.warnings" class="todo-badge"></el-badge>
              </div>
              <div class="todo-content">
                <div class="todo-title">系统告警</div>
                <div class="todo-desc">系统检测到 {{ pendingItems.warnings }} 个潜在问题</div>
              </div>
              <div class="todo-action">
                <el-button type="danger" size="small" round @click="handleWarnings">查看</el-button>
              </div>
            </div>
            
            <!-- 无待处理事项 -->
            <div class="empty-todo" v-if="pendingItems.feedbacks === 0 && pendingItems.documents === 0 && pendingItems.warnings === 0">
              <i class="el-icon-check"></i>
              <span>没有待处理事项</span>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, reactive, nextTick } from 'vue';
import { useRouter } from 'vue-router';
import axios from 'axios';
import { API_BASE_URL } from '../../config';
import * as echarts from 'echarts';
import { ElMessage } from 'element-plus';

const router = useRouter();

// 统计数据
const stats = reactive({
  // 用户统计
  totalUsers: 0,
  newUsers: 0,
  newUsersTrend: 5.2,
  
  // 内容统计
  totalDocuments: 0,
  emergencyPlans: 0,
  categories: 0,
  
  // 系统活跃度
  totalSessions: 0,
  activeUsers: 0,
  avgMessagesPerSession: 0,
  
  // 反馈统计
  totalFeedbacks: 0,
  systemFeedbacks: 0,
  contentFeedbacks: 0,
  avgRating: 0
});

// 最近活动数据
const recentConversations = ref([]);
const recentLogins = ref([]);
const recentFeedbacks = ref([]);

// 图表时间范围
const userChartTimeRange = ref('7');
const conversationChartTimeRange = ref('7');
const feedbackChartTimeRange = ref('7');

// 图表引用
const userActivityChart = ref(null);
const conversationChart = ref(null);
const feedbackChart = ref(null);

// 评分颜色
const ratingColors = reactive(['#F56C6C', '#E6A23C', '#E6A23C', '#67C23A', '#67C23A']);

// 系统参数
const systemParams = ref([]);

// 操作日志
const operationLogs = ref([]);

// 系统版本
const systemVersion = ref({});

// 待处理事项
const pendingItems = reactive({
  feedbacks: 0,
  documents: 0,
  warnings: 0
});

// 获取反馈类型
const getFeedbackType = (type) => {
  switch (type) {
    case 'positive': return 'success';
    case 'negative': return 'danger';
    case 'suggestion': return 'warning';
    default: return 'info';
  }
};

// 获取反馈图标
const getFeedbackIcon = (type) => {
  switch (type) {
    case 'positive': return 'el-icon-circle-check';
    case 'negative': return 'el-icon-circle-close';
    case 'suggestion': return 'el-icon-warning-outline';
    default: return 'el-icon-chat-line-round';
  }
};

// 获取反馈图标类
const getFeedbackIconClass = (type) => {
  switch (type) {
    case 'positive': return 'positive-icon';
    case 'negative': return 'negative-icon';
    case 'suggestion': return 'suggestion-icon';
    default: return '';
  }
};

// 加载统计数据
const loadStats = async () => {
  try {
    // 在实际项目中，这里应该从API获取数据
    // 这里使用模拟数据
    
    // 用户统计
    stats.totalUsers = 1284;
    stats.newUsers = 27;
    
    // 内容统计
    stats.totalDocuments = 356;
    stats.emergencyPlans = 48;
    stats.categories = 12;
    
    // 系统活跃度
    stats.totalSessions = 8975;
    stats.activeUsers = 498;
    stats.avgMessagesPerSession = 4.6;
    
    // 反馈统计
    stats.totalFeedbacks = 627;
    stats.systemFeedbacks = 213;
    stats.contentFeedbacks = 414;
    stats.avgRating = 4.2;
    
    // 如果API可用，请使用以下代码替换上述模拟数据
    /*
    const response = await axios.get(`${API_BASE_URL}/admin/dashboard/stats`);
    if (response.data.code === 200) {
      const data = response.data.data;
      
      // 用户统计
      stats.totalUsers = data.user_stats.total_users;
      stats.newUsers = data.user_stats.new_users;
      stats.newUsersTrend = data.user_stats.new_users_trend;
      
      // 内容统计
      stats.totalDocuments = data.content_stats.total_documents;
      stats.emergencyPlans = data.content_stats.emergency_plans;
      stats.categories = data.content_stats.categories;
      
      // 系统活跃度
      stats.totalSessions = data.activity_stats.total_sessions;
      stats.activeUsers = data.activity_stats.active_users;
      stats.avgMessagesPerSession = data.activity_stats.avg_messages_per_session;
      
      // 反馈统计
      stats.totalFeedbacks = data.feedback_stats.total_feedbacks;
      stats.systemFeedbacks = data.feedback_stats.system_feedbacks;
      stats.contentFeedbacks = data.feedback_stats.content_feedbacks;
      stats.avgRating = data.feedback_stats.avg_rating;
    }
    */
  } catch (error) {
    console.error('加载统计数据失败:', error);
  }
};

// 加载最近对话
const loadRecentConversations = async () => {
  try {
    // 在实际项目中，这里应该从API获取数据
    // 这里使用模拟数据
    recentConversations.value = [
      { id: 'cs-001', title: '关于安全预案的咨询', user_id: 'user123', message_count: 8, created_at: '2023-05-10 15:30:45' },
      { id: 'cs-002', title: '生产安全事故预防', user_id: 'user456', message_count: 12, created_at: '2023-05-09 11:20:38' },
      { id: 'cs-003', title: '化学品储存问题', user_id: 'user789', message_count: 6, created_at: '2023-05-08 09:15:22' },
      { id: 'cs-004', title: '设备检修安全规范', user_id: 'user234', message_count: 9, created_at: '2023-05-07 14:45:10' },
      { id: 'cs-005', title: '员工安全培训资料', user_id: 'user567', message_count: 5, created_at: '2023-05-06 16:30:55' }
    ];
  } catch (error) {
    console.error('加载最近对话失败:', error);
  }
};

// 加载最近登录
const loadRecentLogins = async () => {
  try {
    // 在实际项目中，这里应该从API获取数据
    // 这里使用模拟数据
    recentLogins.value = [
      { user_id: 'user123', ip_address: '192.168.1.101', login_time: '2023-05-10 16:45:12' },
      { user_id: 'user456', ip_address: '192.168.1.102', login_time: '2023-05-10 15:30:45' },
      { user_id: 'user789', ip_address: '192.168.1.103', login_time: '2023-05-10 14:20:38' },
      { user_id: 'user234', ip_address: '192.168.1.104', login_time: '2023-05-10 13:15:22' },
      { user_id: 'user567', ip_address: '192.168.1.105', login_time: '2023-05-10 10:45:10' }
    ];
  } catch (error) {
    console.error('加载最近登录失败:', error);
  }
};

// 加载最新反馈
const loadRecentFeedbacks = async () => {
  try {
    // 在实际项目中，这里应该从API获取数据
    // 这里使用模拟数据
    recentFeedbacks.value = [
      { id: 'fb-001', type: 'positive', typeLabel: '正面', rating: 5, content: '回答非常准确，解决了我的问题', created_at: '2023-05-10 16:30:45' },
      { id: 'fb-002', type: 'negative', typeLabel: '负面', rating: 2, content: '回答不够详细，希望提供更多信息', created_at: '2023-05-09 14:20:38' },
      { id: 'fb-003', type: 'suggestion', typeLabel: '建议', rating: null, content: '希望能增加更多化工安全预案案例', created_at: '2023-05-08 11:15:22' },
      { id: 'fb-004', type: 'positive', typeLabel: '正面', rating: 4, content: '系统操作简单便捷，界面友好', created_at: '2023-05-07 09:45:10' },
      { id: 'fb-005', type: 'suggestion', typeLabel: '建议', rating: null, content: '建议增加批量导入文档的功能', created_at: '2023-05-06 15:30:55' }
    ];
  } catch (error) {
    console.error('加载最新反馈失败:', error);
  }
};

// 加载系统参数
const loadSystemParams = async () => {
  try {
    // 在实际项目中，这里应该从API获取数据
    // 这里使用模拟数据
    systemParams.value = [
      { name: '知识库最后更新日期', value: '2023-05-05' },
      { name: '知识库数据源数量', value: '16' },
      { name: '系统响应时间限制', value: '5000ms' },
      { name: '系统运行状态', value: '正常' }
    ];
  } catch (error) {
    console.error('加载系统参数失败:', error);
  }
};

// 加载操作日志
const loadOperationLogs = async () => {
  try {
    // 在实际项目中，这里应该从API获取数据
    // 这里使用模拟数据
    operationLogs.value = [
      { admin_name: '管理员1', action: '更新了系统参数', operation_time: '10分钟前' },
      { admin_name: '管理员2', action: '上传了新文档', operation_time: '30分钟前' },
      { admin_name: '管理员1', action: '处理了用户反馈', operation_time: '1小时前' },
      { admin_name: '管理员3', action: '添加了新用户', operation_time: '2小时前' }
    ];
  } catch (error) {
    console.error('加载操作日志失败:', error);
  }
};

// 加载系统版本
const loadSystemVersion = async () => {
  try {
    // 在实际项目中，这里应该从API获取数据
    // 这里使用模拟数据
    systemVersion.value = {
      version_number: 'v1.2.5',
      release_date: '2023-05-01',
      update_notes: '1. 优化了AI回答算法\n2. 修复了文档上传bug\n3. 新增了批量导入功能\n4. 改进了用户界面体验'
    };
  } catch (error) {
    console.error('加载系统版本失败:', error);
  }
};

// 加载待处理事项
const loadPendingItems = async () => {
  try {
    // 在实际项目中，这里应该从API获取数据
    // 这里使用模拟数据
    pendingItems.feedbacks = 8;
    pendingItems.documents = 3;
    pendingItems.warnings = 1;
  } catch (error) {
    console.error('加载待处理事项失败:', error);
  }
};

// 刷新待处理事项
const refreshTodo = () => {
  loadPendingItems();
};

// 处理系统告警
const handleWarnings = () => {
  // 实际项目中应该打开告警详情或跳转到相应页面
  ElMessage.info('查看系统告警详情');
};

// 初始化图表
const initCharts = () => {
  loadUserActivityChart();
  loadConversationChart();
  loadFeedbackChart();
};

// 加载用户活跃度图表
const loadUserActivityChart = () => {
  if (!userActivityChart.value) return;
  
  const chart = echarts.init(userActivityChart.value);
  
  // 模拟数据
  const days = userChartTimeRange.value === '7' ? 7 : 30;
  const dates = [];
  const activeData = [];
  
  for (let i = days - 1; i >= 0; i--) {
    const date = new Date();
    date.setDate(date.getDate() - i);
    dates.push(`${date.getMonth() + 1}/${date.getDate()}`);
    activeData.push(Math.floor(Math.random() * 100 + 50));
  }
  
  const option = {
    tooltip: {
      trigger: 'axis'
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
      data: dates
    },
    yAxis: {
      type: 'value'
    },
    series: [{
      name: '活跃用户',
      type: 'line',
      smooth: true,
      symbol: 'circle',
      symbolSize: 6,
      lineStyle: {
        width: 3,
        color: '#409EFF'
      },
      itemStyle: {
        color: '#409EFF'
      },
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{
          offset: 0,
          color: 'rgba(64, 158, 255, 0.3)'
        }, {
          offset: 1,
          color: 'rgba(64, 158, 255, 0.1)'
        }])
      },
      data: activeData
    }]
  };
  
  chart.setOption(option);
  
  // 自适应窗口大小
  window.addEventListener('resize', () => {
    chart.resize();
  });
};

// 加载对话数量图表
const loadConversationChart = () => {
  if (!conversationChart.value) return;
  
  const chart = echarts.init(conversationChart.value);
  
  // 模拟数据
  const days = conversationChartTimeRange.value === '7' ? 7 : 30;
  const dates = [];
  const conversationData = [];
  
  for (let i = days - 1; i >= 0; i--) {
    const date = new Date();
    date.setDate(date.getDate() - i);
    dates.push(`${date.getMonth() + 1}/${date.getDate()}`);
    conversationData.push(Math.floor(Math.random() * 200 + 100));
  }
  
  const option = {
    tooltip: {
      trigger: 'axis'
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
      data: dates
    },
    yAxis: {
      type: 'value'
    },
    series: [{
      name: '对话数量',
      type: 'line',
      smooth: true,
      symbol: 'circle',
      symbolSize: 6,
      lineStyle: {
        width: 3,
        color: '#67C23A'
      },
      itemStyle: {
        color: '#67C23A'
      },
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{
          offset: 0,
          color: 'rgba(103, 194, 58, 0.3)'
        }, {
          offset: 1,
          color: 'rgba(103, 194, 58, 0.1)'
        }])
      },
      data: conversationData
    }]
  };
  
  chart.setOption(option);
  
  // 自适应窗口大小
  window.addEventListener('resize', () => {
    chart.resize();
  });
};

// 加载反馈评分图表
const loadFeedbackChart = () => {
  if (!feedbackChart.value) return;
  
  const chart = echarts.init(feedbackChart.value);
  
  // 模拟数据
  const days = feedbackChartTimeRange.value === '7' ? 7 : 30;
  const dates = [];
  const ratingData = [];
  
  for (let i = days - 1; i >= 0; i--) {
    const date = new Date();
    date.setDate(date.getDate() - i);
    dates.push(`${date.getMonth() + 1}/${date.getDate()}`);
    ratingData.push((Math.random() * 1 + 4).toFixed(1));
  }
  
  const option = {
    tooltip: {
      trigger: 'axis'
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
      data: dates
    },
    yAxis: {
      type: 'value',
      min: 1,
      max: 5
    },
    series: [{
      name: '平均评分',
      type: 'line',
      smooth: true,
      symbol: 'circle',
      symbolSize: 6,
      lineStyle: {
        width: 3,
        color: '#E6A23C'
      },
      itemStyle: {
        color: '#E6A23C'
      },
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{
          offset: 0,
          color: 'rgba(230, 162, 60, 0.3)'
        }, {
          offset: 1,
          color: 'rgba(230, 162, 60, 0.1)'
        }])
      },
      data: ratingData
    }]
  };
  
  chart.setOption(option);
  
  // 自适应窗口大小
  window.addEventListener('resize', () => {
    chart.resize();
  });
};

onMounted(() => {
  loadStats();
  loadRecentConversations();
  loadRecentLogins();
  loadRecentFeedbacks();
  
  // 图表初始化需要等DOM渲染完成后执行
  nextTick(() => {
    initCharts();
  });
  
  loadSystemParams();
  loadOperationLogs();
  loadSystemVersion();
  loadPendingItems();
});
</script>

<style scoped>
.admin-dashboard {
  padding: 20px;
  background-color: #f0f2f5;
  min-height: calc(100vh - 60px);
}

.dashboard-title {
  margin-bottom: 24px;
  font-size: 24px;
  font-weight: 500;
  color: #303133;
}

/* 核心数据概览区域样式 */
.data-overview {
  margin-bottom: 24px;
}

.overview-card {
  height: 100%;
  border-radius: 8px;
  overflow: hidden;
  transition: all 0.3s;
  margin-bottom: 20px;
}

.overview-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.card-header {
  display: flex;
  align-items: center;
  padding-bottom: 12px;
  border-bottom: 1px solid #ebeef5;
  margin-bottom: 12px;
}

.card-icon {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background-color: #ecf5ff;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
  font-size: 20px;
}

.user-card .card-icon {
  background-color: #ecf5ff;
  color: #409eff;
}

.content-card .card-icon {
  background-color: #f0f9eb;
  color: #67c23a;
}

.activity-card .card-icon {
  background-color: #fdf6ec;
  color: #e6a23c;
}

.feedback-card .card-icon {
  background-color: #fef0f0;
  color: #f56c6c;
}

.card-title {
  font-size: 16px;
  font-weight: 500;
  color: #303133;
}

.card-body {
  padding-top: 4px;
}

.data-item {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  margin-bottom: 10px;
}

.data-item:last-child {
  margin-bottom: 0;
}

.data-label {
  color: #909399;
  font-size: 14px;
  margin-right: 8px;
  flex: 0 0 auto;
}

.data-value {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin-right: 8px;
}

.data-trend {
  font-size: 12px;
  padding: 2px 4px;
  border-radius: 4px;
}

.data-trend.up {
  color: #67c23a;
  background-color: #f0f9eb;
}

.data-trend.down {
  color: #f56c6c;
  background-color: #fef0f0;
}

.rating-stars {
  margin-top: 4px;
}

/* 趋势图表区域样式 */
.chart-section {
  margin-bottom: 24px;
}

.chart-card {
  height: 100%;
  border-radius: 8px;
  overflow: hidden;
  transition: all 0.3s;
  margin-bottom: 20px;
}

.chart-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.chart-title {
  font-size: 16px;
  font-weight: 500;
  color: #303133;
  margin: 0;
}

.chart-actions {
  margin-left: auto;
}

.chart-container {
  height: 300px;
}

/* 最近活动区域样式 */
.activity-section {
  margin-bottom: 24px;
}

.activity-card {
  border-radius: 8px;
  overflow: hidden;
  transition: all 0.3s;
  margin-bottom: 20px;
  height: 100%;
}

.card-header-with-action {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.section-title {
  font-size: 16px;
  font-weight: 500;
  margin: 0;
  color: #303133;
}

.view-more {
  font-size: 13px;
  color: #409eff;
  text-decoration: none;
}

.view-more:hover {
  color: #66b1ff;
}

.activity-list {
  max-height: 400px;
  overflow-y: auto;
}

.activity-item {
  display: flex;
  align-items: flex-start;
  padding: 12px 0;
}

.activity-icon {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
  flex-shrink: 0;
}

.conversation-icon {
  background-color: #ecf5ff;
  color: #409eff;
}

.login-icon {
  background-color: #f0f9eb;
  color: #67c23a;
}

.feedback-icon {
  background-color: #fdf6ec;
  color: #e6a23c;
}

.positive-icon {
  background-color: #f0f9eb;
  color: #67c23a;
}

.negative-icon {
  background-color: #fef0f0;
  color: #f56c6c;
}

.suggestion-icon {
  background-color: #fdf6ec;
  color: #e6a23c;
}

.activity-content {
  flex: 1;
}

.activity-title {
  font-weight: 500;
  color: #303133;
  margin-bottom: 4px;
  display: flex;
  align-items: center;
}

.feedback-rating {
  margin-left: 8px;
}

.activity-desc {
  font-size: 13px;
  color: #606266;
  margin-bottom: 4px;
  word-break: break-all;
}

.activity-meta {
  font-size: 12px;
  color: #909399;
}

.activity-time {
  margin-left: 8px;
}

.empty-data {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 0;
  color: #909399;
}

.empty-data i {
  font-size: 48px;
  margin-bottom: 16px;
  color: #dcdfe6;
}

/* 系统状态区域样式 */
.status-section {
  margin-bottom: 24px;
}

.status-card, .todo-card {
  border-radius: 8px;
  overflow: hidden;
  transition: all 0.3s;
  margin-bottom: 20px;
  height: 100%;
}

.status-block {
  margin-bottom: 20px;
}

.block-title {
  font-size: 15px;
  font-weight: 500;
  margin-bottom: 12px;
  color: #303133;
  padding-bottom: 8px;
  border-bottom: 1px solid #ebeef5;
}

/* 系统参数样式 */
.param-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.param-item {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px dashed #ebeef5;
}

.param-item:last-child {
  border-bottom: none;
}

.param-label {
  color: #606266;
  flex: 0 0 60%;
}

.param-value {
  color: #303133;
  font-weight: 500;
}

/* 操作日志样式 */
.log-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.log-item {
  padding: 8px 0;
  border-bottom: 1px dashed #ebeef5;
}

.log-item:last-child {
  border-bottom: none;
}

.log-content {
  margin-bottom: 4px;
}

.log-admin {
  font-weight: 500;
  color: #409eff;
  margin-right: 4px;
}

.log-action {
  color: #606266;
}

.log-time {
  font-size: 12px;
  color: #909399;
}

.block-footer {
  margin-top: 12px;
  text-align: center;
}

.view-more-link {
  font-size: 13px;
  color: #409eff;
  text-decoration: none;
}

.view-more-link:hover {
  color: #66b1ff;
}

/* 系统版本样式 */
.version-info {
  padding: 8px 0;
}

.current-version {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
}

.version-label {
  color: #606266;
  margin-right: 8px;
  flex: 0 0 auto;
}

.version-number {
  font-size: 18px;
  font-weight: 600;
  color: #409eff;
}

.version-date {
  margin-bottom: 12px;
}

.version-value {
  color: #303133;
}

.version-notes {
  background-color: #f5f7fa;
  padding: 10px;
  border-radius: 4px;
}

.notes-title {
  font-weight: 500;
  margin-bottom: 4px;
  color: #303133;
}

.notes-content {
  font-size: 13px;
  color: #606266;
  white-space: pre-line;
}

/* 待处理事项样式 */
.todo-list {
  display: flex;
  flex-direction: column;
}

.todo-item {
  display: flex;
  align-items: center;
  padding: 16px 0;
  border-bottom: 1px solid #ebeef5;
  text-decoration: none;
  color: inherit;
  transition: background-color 0.3s;
}

.todo-item:hover {
  background-color: #f5f7fa;
}

.todo-item:last-child {
  border-bottom: none;
}

.todo-icon {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
  position: relative;
  font-size: 20px;
}

.feedback-icon {
  background-color: #ecf5ff;
  color: #409eff;
}

.document-icon {
  background-color: #f0f9eb;
  color: #67c23a;
}

.warning-icon {
  background-color: #fef0f0;
  color: #f56c6c;
}

.todo-badge {
  position: absolute;
  top: -6px;
  right: -6px;
}

.todo-content {
  flex: 1;
}

.todo-title {
  font-weight: 500;
  color: #303133;
  margin-bottom: 4px;
}

.todo-desc {
  font-size: 13px;
  color: #606266;
}

.todo-action {
  margin-left: 12px;
  color: #909399;
  font-size: 16px;
}

.warning-item {
  background-color: #fff8f8;
}

.empty-todo {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 0;
  color: #67c23a;
}

.empty-todo i {
  font-size: 48px;
  margin-bottom: 16px;
}
</style>