<template>
  <div class="feedback-status">
    <!-- 搜索和筛选区域 -->
    <div class="search-container">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择处理状态">
            <el-option label="全部" value=""></el-option>
            <el-option label="待处理" value="pending"></el-option>
            <el-option label="处理中" value="processing"></el-option>
            <el-option label="已解决" value="resolved"></el-option>
            <el-option label="已拒绝" value="rejected"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="提交时间">
          <el-date-picker
            v-model="searchForm.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
          ></el-date-picker>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="resetSearchForm">重置</el-button>
        </el-form-item>
      </el-form>
    </div>
    
    <!-- 统计卡片 -->
    <div class="stats-container">
      <el-row :gutter="20">
        <el-col :xs="24" :sm="12" :md="6">
          <el-card shadow="hover" class="stats-card">
            <div class="stats-icon pending-icon">
              <el-icon><Clock /></el-icon>
            </div>
            <div class="stats-info">
              <div class="stats-title">待处理</div>
              <div class="stats-value">{{ statusStats.pending || 0 }}</div>
            </div>
          </el-card>
        </el-col>
        
        <el-col :xs="24" :sm="12" :md="6">
          <el-card shadow="hover" class="stats-card">
            <div class="stats-icon processing-icon">
              <el-icon><Loading /></el-icon>
            </div>
            <div class="stats-info">
              <div class="stats-title">处理中</div>
              <div class="stats-value">{{ statusStats.processing || 0 }}</div>
            </div>
          </el-card>
        </el-col>
        
        <el-col :xs="24" :sm="12" :md="6">
          <el-card shadow="hover" class="stats-card">
            <div class="stats-icon resolved-icon">
              <el-icon><Check /></el-icon>
            </div>
            <div class="stats-info">
              <div class="stats-title">已解决</div>
              <div class="stats-value">{{ statusStats.resolved || 0 }}</div>
            </div>
          </el-card>
        </el-col>
        
        <el-col :xs="24" :sm="12" :md="6">
          <el-card shadow="hover" class="stats-card">
            <div class="stats-icon rejected-icon">
              <el-icon><Close /></el-icon>
            </div>
            <div class="stats-info">
              <div class="stats-title">已拒绝</div>
              <div class="stats-value">{{ statusStats.rejected || 0 }}</div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>
    
    <!-- 反馈状态列表 -->
    <div class="table-container">
      <el-table 
        :data="feedbackList" 
        border 
        style="width: 100%" 
        v-loading="loading"
        :cell-style="{ padding: '12px 8px' }"
        :header-cell-style="{ background:'#f5f7fa', color:'#606266', fontWeight: 'bold' }">
        <el-table-column prop="feedback_id" label="ID" min-width="80" align="center"></el-table-column>
        <el-table-column prop="feedback_type" label="反馈类型" min-width="120" align="center">
          <template #default="scope">
            <el-tag :type="getTypeColor(scope.row.feedback_type)">
              {{ getTypeName(scope.row.feedback_type) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="feedback_content" label="反馈内容" min-width="280" align="left" show-overflow-tooltip></el-table-column>
        <el-table-column prop="created_at" label="提交时间" min-width="160" align="center"></el-table-column>
        <el-table-column prop="status" label="处理状态" min-width="100" align="center">
          <template #default="scope">
            <el-select v-model="scope.row.status" size="small" @change="(val) => handleStatusChange(scope.row, val)">
              <el-option label="待处理" value="pending"></el-option>
              <el-option label="处理中" value="processing"></el-option>
              <el-option label="已解决" value="resolved"></el-option>
              <el-option label="已拒绝" value="rejected"></el-option>
            </el-select>
          </template>
        </el-table-column>
        <el-table-column label="操作" min-width="160" align="center">
          <template #default="scope">
            <el-button size="small" type="primary" @click="handleViewDetail(scope.row)">回复</el-button>
            <el-button size="small" type="danger" v-if="scope.row.status !== 'rejected'" @click="handleReject(scope.row)">
              拒绝
            </el-button>
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
    </div>
    
    <!-- 反馈详情和回复对话框 -->
    <el-dialog 
      title="反馈回复" 
      v-model="dialogVisible" 
      width="600px"
      :close-on-click-modal="false"
    >
      <div class="feedback-detail" v-if="currentFeedback">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="反馈ID">{{ currentFeedback.feedback_id }}</el-descriptions-item>
          <el-descriptions-item label="反馈类型">
            <el-tag :type="getTypeColor(currentFeedback.feedback_type)">
              {{ getTypeName(currentFeedback.feedback_type) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="反馈内容">
            <div class="feedback-content">{{ currentFeedback.feedback_content }}</div>
          </el-descriptions-item>
          <el-descriptions-item label="提交时间">{{ currentFeedback.created_at }}</el-descriptions-item>
          <el-descriptions-item label="处理状态">
            <el-select v-model="currentFeedback.status" size="small">
              <el-option label="待处理" value="pending"></el-option>
              <el-option label="处理中" value="processing"></el-option>
              <el-option label="已解决" value="resolved"></el-option>
              <el-option label="已拒绝" value="rejected"></el-option>
            </el-select>
          </el-descriptions-item>
          <el-descriptions-item v-if="currentFeedback.admin_reply" label="管理员回复">
            {{ currentFeedback.admin_reply }}
          </el-descriptions-item>
        </el-descriptions>
        
        <!-- 管理员回复表单 -->
        <div class="reply-form">
          <el-divider content-position="center">回复内容</el-divider>
          <el-form :model="replyForm" ref="replyFormRef" :rules="replyRules">
            <el-form-item prop="reply">
              <el-input 
                v-model="replyForm.reply" 
                type="textarea" 
                rows="4" 
                placeholder="请输入回复内容..."
              ></el-input>
            </el-form-item>
          </el-form>
        </div>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="success" @click="handleSubmitReply">提交回复</el-button>
        </span>
      </template>
    </el-dialog>
    
    <!-- 批量处理对话框 -->
    <el-dialog 
      title="批量处理反馈" 
      v-model="batchDialogVisible" 
      width="500px"
      :close-on-click-modal="false"
    >
      <div class="batch-form">
        <el-form :model="batchForm" ref="batchFormRef">
          <el-form-item label="选择状态" prop="status">
            <el-select v-model="batchForm.status" placeholder="请选择处理状态">
              <el-option label="待处理" value="pending"></el-option>
              <el-option label="处理中" value="processing"></el-option>
              <el-option label="已解决" value="resolved"></el-option>
              <el-option label="已拒绝" value="rejected"></el-option>
            </el-select>
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="batchDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleBatchUpdate">确认更新</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { Clock, Loading, Check, Close } from '@element-plus/icons-vue';
import { API_BASE_URL } from '../../../config';

// 状态变量
const loading = ref(false);
const feedbackList = ref([]);
const total = ref(0);
const pageSize = ref(10);
const currentPage = ref(1);
const dialogVisible = ref(false);
const batchDialogVisible = ref(false);
const currentFeedback = ref(null);
const feedbackTypes = ref([]);
const statusStats = ref({});
const replyFormRef = ref(null);
const batchFormRef = ref(null);

// 搜索表单
const searchForm = reactive({
  status: '',
  dateRange: []
});

// 回复表单
const replyForm = reactive({
  reply: ''
});

// 批量处理表单
const batchForm = reactive({
  status: ''
});

// 回复表单验证规则
const replyRules = {
  reply: [
    { required: true, message: '请输入回复内容', trigger: 'blur' },
    { min: 2, max: 500, message: '回复内容长度在 2 到 500 个字符', trigger: 'blur' }
  ]
};

// 获取反馈状态统计
const fetchStatusStats = async () => {
  try {
    const adminId = localStorage.getItem('admin_id');
    let url = `${API_BASE_URL}/admin/feedback/status-stats`;
    
    if (adminId) {
      url += `?admin_id=${adminId}`;
    }
    
    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    const data = await response.json();
    
    if (data.code === 200) {
      statusStats.value = data.data;
    } else {
      ElMessage.error(data.message || '获取反馈状态统计失败');
    }
  } catch (error) {
    console.error('获取反馈状态统计错误:', error);
    ElMessage.error('网络连接异常，请稍后再试');
  }
};

// 获取反馈类型列表
const fetchFeedbackTypes = async () => {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/feedback/types`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    const data = await response.json();
    
    if (data.code === 200) {
      feedbackTypes.value = data.data;
    } else {
      ElMessage.error(data.message || '获取反馈类型失败');
    }
  } catch (error) {
    console.error('获取反馈类型错误:', error);
    ElMessage.error('网络连接异常，请稍后再试');
  }
};

// 获取反馈列表
const fetchFeedbackList = async () => {
  loading.value = true;
  try {
    // 构建查询参数
    const params = new URLSearchParams();
    params.append('page', currentPage.value);
    params.append('page_size', pageSize.value);
    
    if (searchForm.status) {
      params.append('status', searchForm.status);
    }
    
    if (searchForm.dateRange && searchForm.dateRange.length === 2) {
      const startDate = formatDate(searchForm.dateRange[0]);
      const endDate = formatDate(searchForm.dateRange[1]);
      params.append('start_date', startDate);
      params.append('end_date', endDate);
    }
    
    const adminId = localStorage.getItem('admin_id');
    if (adminId) {
      params.append('admin_id', adminId);
    }
    
    const response = await fetch(`${API_BASE_URL}/admin/feedback/list?${params.toString()}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    const data = await response.json();
    
    if (data.code === 200) {
      feedbackList.value = data.data.feedback_list;
      total.value = data.data.total;
    } else {
      ElMessage.error(data.message || '获取反馈列表失败');
    }
  } catch (error) {
    console.error('获取反馈列表错误:', error);
    ElMessage.error('网络连接异常，请稍后再试');
  } finally {
    loading.value = false;
  }
};

// 格式化日期
const formatDate = (date) => {
  const d = new Date(date);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
};

// 搜索处理
const handleSearch = () => {
  currentPage.value = 1;
  fetchFeedbackList();
};

// 重置搜索表单
const resetSearchForm = () => {
  searchForm.status = '';
  searchForm.dateRange = [];
  currentPage.value = 1;
  fetchFeedbackList();
};

// 分页大小改变
const handleSizeChange = (size) => {
  pageSize.value = size;
  fetchFeedbackList();
};

// 当前页码改变
const handleCurrentChange = (page) => {
  currentPage.value = page;
  fetchFeedbackList();
};

// 查看反馈详情并回复
const handleViewDetail = (feedback) => {
  currentFeedback.value = { ...feedback };
  replyForm.reply = feedback.admin_reply || '';
  dialogVisible.value = true;
};

// 更新反馈状态
const handleStatusChange = async (feedback, newStatus) => {
  if (!feedback) return;
  
  const statusNames = {
    'pending': '待处理',
    'processing': '处理中',
    'resolved': '已解决',
    'rejected': '已拒绝'
  };
  
  const action = statusNames[newStatus];
  const adminId = localStorage.getItem('admin_id');
  
  try {
    const response = await fetch(`${API_BASE_URL}/admin/feedback/status`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        feedback_id: feedback.feedback_id,
        status: newStatus,
        admin_id: adminId
      })
    });
    
    const data = await response.json();
    
    if (data.code === 200) {
      ElMessage({
        type: 'success',
        message: `反馈已标记为${action}`,
        duration: 2000,
        showClose: true
      });
      
      // 刷新状态统计
      fetchStatusStats();
    } else {
      // 恢复原状态
      const originalFeedback = feedbackList.value.find(f => f.feedback_id === feedback.feedback_id);
      if (originalFeedback) {
        feedback.status = originalFeedback.status;
      }
      ElMessage.error(data.message || `标记反馈为${action}失败`);
    }
  } catch (error) {
    console.error(`更新反馈状态错误:`, error);
    // 恢复原状态
    const originalFeedback = feedbackList.value.find(f => f.feedback_id === feedback.feedback_id);
    if (originalFeedback) {
      feedback.status = originalFeedback.status;
    }
    ElMessage.error('网络连接异常，请稍后再试');
  }
};

// 拒绝反馈
const handleReject = (feedback) => {
  ElMessageBox.confirm(
    '确定要拒绝该反馈吗？', 
    '拒绝确认', 
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    handleStatusChange(feedback, 'rejected');
  }).catch(() => {
    // 用户取消操作
  });
};

// 提交回复
const handleSubmitReply = async () => {
  if (!replyFormRef.value) return;
  
  await replyFormRef.value.validate(async (valid) => {
    if (!valid) return;
    
    const adminId = localStorage.getItem('admin_id');
    
    try {
      const response = await fetch(`${API_BASE_URL}/admin/feedback/reply`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          feedback_id: currentFeedback.value.feedback_id,
          admin_reply: replyForm.reply,
          status: currentFeedback.value.status,
          admin_id: adminId
        })
      });
      
      const data = await response.json();
      
      if (data.code === 200) {
        ElMessage({
          type: 'success',
          message: '回复提交成功',
          duration: 2000,
          showClose: true
        });
        
        // 刷新列表
        fetchFeedbackList();
        
        // 刷新状态统计
        fetchStatusStats();
        
        // 关闭对话框
        dialogVisible.value = false;
      } else {
        ElMessage.error(data.message || '回复提交失败');
      }
    } catch (error) {
      console.error('提交回复错误:', error);
      ElMessage.error('网络连接异常，请稍后再试');
    }
  });
};

// 打开批量处理对话框
const openBatchDialog = () => {
  batchForm.status = '';
  batchDialogVisible.value = true;
};

// 批量更新状态
const handleBatchUpdate = async () => {
  if (!batchForm.status) {
    ElMessage.warning('请选择处理状态');
    return;
  }
  
  try {
    const adminId = localStorage.getItem('admin_id');
    
    const response = await fetch(`${API_BASE_URL}/admin/feedback/batch-status`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        status: batchForm.status,
        admin_id: adminId,
        condition: {
          status: searchForm.status,
          start_date: searchForm.dateRange && searchForm.dateRange.length === 2 ? formatDate(searchForm.dateRange[0]) : null,
          end_date: searchForm.dateRange && searchForm.dateRange.length === 2 ? formatDate(searchForm.dateRange[1]) : null
        }
      })
    });
    
    const data = await response.json();
    
    if (data.code === 200) {
      ElMessage({
        type: 'success',
        message: `批量更新成功，共更新 ${data.data.affected_count} 条记录`,
        duration: 2000,
        showClose: true
      });
      
      // 刷新列表和统计
      fetchFeedbackList();
      fetchStatusStats();
      
      // 关闭对话框
      batchDialogVisible.value = false;
    } else {
      ElMessage.error(data.message || '批量更新失败');
    }
  } catch (error) {
    console.error('批量更新错误:', error);
    ElMessage.error('网络连接异常，请稍后再试');
  }
};

// 获取反馈类型名称
const getTypeName = (typeCode) => {
  const type = feedbackTypes.value.find(t => t.type_code === typeCode);
  return type ? type.type_name : typeCode;
};

// 获取反馈类型对应的标签颜色
const getTypeColor = (typeCode) => {
  const colorMap = {
    'suggestion': 'success',
    'bug': 'danger',
    'content': 'warning',
    'other': 'info'
  };
  return colorMap[typeCode] || 'info';
};

// 页面加载时获取数据
onMounted(() => {
  fetchFeedbackTypes();
  fetchFeedbackList();
  fetchStatusStats();
});
</script>

<style scoped>
.feedback-status {
  padding: 20px;
}

.search-container {
  background-color: #fff;
  padding: 20px;
  border-radius: 4px;
  margin-bottom: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.stats-container {
  margin-bottom: 20px;
}

.stats-card {
  border-radius: 8px;
  padding: 0;
  display: flex;
  align-items: center;
  margin-bottom: 20px;
  cursor: pointer;
  transition: all 0.3s;
}

.stats-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.15);
}

.stats-icon {
  padding: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 6px 0 0 6px;
  font-size: 24px;
  width: 80px;
  height: 80px;
}

.pending-icon {
  background-color: #e6f7ff;
  color: #1890ff;
}

.processing-icon {
  background-color: #fff7e6;
  color: #fa8c16;
}

.resolved-icon {
  background-color: #f6ffed;
  color: #52c41a;
}

.rejected-icon {
  background-color: #fff1f0;
  color: #f5222d;
}

.stats-info {
  padding: 15px 20px;
  flex: 1;
}

.stats-title {
  font-size: 14px;
  color: #909399;
  margin-bottom: 8px;
}

.stats-value {
  font-size: 22px;
  font-weight: bold;
  color: #303133;
}

.table-container {
  background-color: #fff;
  padding: 20px;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.pagination-container {
  margin-top: 20px;
  text-align: right;
}

.feedback-content {
  white-space: pre-wrap;
  line-height: 1.5;
}

.reply-form {
  margin-top: 20px;
}

.batch-actions {
  margin-bottom: 15px;
  display: flex;
  justify-content: flex-end;
}

/* 添加操作按钮间距 */
.el-button + .el-button {
  margin-left: 8px;
}

/* 确保表格在小屏幕上也能水平滚动 */
@media (max-width: 1200px) {
  .table-container {
    overflow-x: auto;
  }
}

/* 移除按钮点击后的黑色边框 */
.el-button:focus {
  outline: none !important;
  box-shadow: none !important;
}

/* 改善按钮点击状态 */
.el-button:active {
  opacity: 0.9;
  transform: scale(0.98);
}
</style> 