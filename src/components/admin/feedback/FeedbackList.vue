<template>
  <div class="feedback-list">
    <!-- 搜索和筛选区域 -->
    <div class="search-container">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="反馈类型">
          <el-select v-model="searchForm.feedbackType" placeholder="请选择反馈类型">
            <el-option label="全部" value=""></el-option>
            <el-option v-for="type in feedbackTypes" :key="type.type_code" :label="type.type_name" :value="type.type_code"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="处理状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态">
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
    
    <!-- 反馈列表 -->
    <div class="table-container">
      <el-table 
        :data="feedbackList" 
        border 
        style="width: 100%" 
        v-loading="loading"
        :cell-style="{ padding: '12px 8px' }"
        :header-cell-style="{ background:'#f5f7fa', color:'#606266', fontWeight: 'bold' }">
        <el-table-column prop="feedback_id" label="ID" min-width="80" align="center"></el-table-column>
        <el-table-column prop="user_id" label="用户ID" min-width="80" align="center"></el-table-column>
        <el-table-column prop="feedback_type" label="反馈类型" min-width="120" align="center">
          <template #default="scope">
            <el-tag :type="getTypeColor(scope.row.feedback_type)">
              {{ getTypeName(scope.row.feedback_type) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="feedback_content" label="反馈内容" min-width="300" align="left" show-overflow-tooltip></el-table-column>
        <el-table-column prop="created_at" label="提交时间" min-width="160" align="center"></el-table-column>
        <el-table-column prop="status" label="处理状态" min-width="100" align="center">
          <template #default="scope">
            <el-tag :type="getStatusColor(scope.row.status)">
              {{ getStatusName(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" min-width="180" align="center">
          <template #default="scope">
            <el-button size="small" type="primary" @click="handleViewDetail(scope.row)">查看详情</el-button>
            <el-button size="small" :type="scope.row.status === 'resolved' ? 'info' : 'success'" 
                      :disabled="scope.row.status === 'resolved'" 
                      @click="handleUpdateStatus(scope.row, 'resolved')">
              标记已解决
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
    
    <!-- 反馈详情对话框 -->
    <el-dialog 
      title="反馈详情" 
      v-model="dialogVisible" 
      width="600px"
      :close-on-click-modal="false"
    >
      <div class="feedback-detail" v-if="currentFeedback">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="反馈ID">{{ currentFeedback.feedback_id }}</el-descriptions-item>
          <el-descriptions-item label="用户ID">
            {{ currentFeedback.user_id ? currentFeedback.user_id : '匿名反馈' }}
          </el-descriptions-item>
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
            <el-tag :type="getStatusColor(currentFeedback.status)">
              {{ getStatusName(currentFeedback.status) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item v-if="currentFeedback.admin_reply" label="管理员回复">
            {{ currentFeedback.admin_reply }}
          </el-descriptions-item>
          <el-descriptions-item v-if="currentFeedback.replied_at" label="回复时间">
            {{ currentFeedback.replied_at }}
          </el-descriptions-item>
        </el-descriptions>
        
        <!-- 管理员回复表单 -->
        <div class="reply-form" v-if="currentFeedback.status !== 'resolved' && currentFeedback.status !== 'rejected'">
          <el-divider content-position="center">管理员回复</el-divider>
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
          <el-button @click="dialogVisible = false">关闭</el-button>
          <el-button 
            v-if="currentFeedback && currentFeedback.status !== 'rejected'"
            type="danger"
            @click="handleUpdateStatus(currentFeedback, 'rejected')"
          >
            拒绝反馈
          </el-button>
          <el-button 
            v-if="currentFeedback && currentFeedback.status !== 'resolved'"
            type="success"
            @click="handleSubmitReply"
          >
            提交回复并解决
          </el-button>
          <el-button 
            v-if="currentFeedback && currentFeedback.status !== 'processing'"
            type="warning"
            @click="handleUpdateStatus(currentFeedback, 'processing')"
          >
            标记处理中
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { API_BASE_URL } from '../../../config';

// 状态变量
const loading = ref(false);
const feedbackList = ref([]);
const total = ref(0);
const pageSize = ref(10);
const currentPage = ref(1);
const dialogVisible = ref(false);
const currentFeedback = ref(null);
const feedbackTypes = ref([]);
const replyFormRef = ref(null);

// 搜索表单
const searchForm = reactive({
  feedbackType: '',
  status: '',
  dateRange: []
});

// 回复表单
const replyForm = reactive({
  reply: ''
});

// 回复表单验证规则
const replyRules = {
  reply: [
    { required: true, message: '请输入回复内容', trigger: 'blur' },
    { min: 2, max: 500, message: '回复内容长度在 2 到 500 个字符', trigger: 'blur' }
  ]
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
    
    if (searchForm.feedbackType) {
      params.append('feedback_type', searchForm.feedbackType);
    }
    
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
  searchForm.feedbackType = '';
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

// 查看反馈详情
const handleViewDetail = (feedback) => {
  currentFeedback.value = { ...feedback };
  replyForm.reply = '';
  dialogVisible.value = true;
};

// 更新反馈状态
const handleUpdateStatus = async (feedback, newStatus) => {
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
      
      // 更新本地数据
      if (currentFeedback.value && currentFeedback.value.feedback_id === feedback.feedback_id) {
        currentFeedback.value.status = newStatus;
      }
      
      // 刷新列表
      fetchFeedbackList();
      
      // 如果是在详情页操作的，可以关闭对话框
      if (newStatus === 'resolved' || newStatus === 'rejected') {
        dialogVisible.value = false;
      }
    } else {
      ElMessage.error(data.message || `标记反馈为${action}失败`);
    }
  } catch (error) {
    console.error(`更新反馈状态错误:`, error);
    ElMessage.error('网络连接异常，请稍后再试');
  }
};

// 提交回复并解决
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
          status: 'resolved',
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

// 获取状态名称
const getStatusName = (status) => {
  const statusMap = {
    'pending': '待处理',
    'processing': '处理中',
    'resolved': '已解决',
    'rejected': '已拒绝'
  };
  return statusMap[status] || status;
};

// 获取状态对应的标签颜色
const getStatusColor = (status) => {
  const colorMap = {
    'pending': 'info',
    'processing': 'warning',
    'resolved': 'success',
    'rejected': 'danger'
  };
  return colorMap[status] || 'info';
};

// 页面加载时获取反馈列表和反馈类型
onMounted(() => {
  fetchFeedbackTypes();
  fetchFeedbackList();
});
</script>

<style scoped>
.feedback-list {
  padding: 20px;
}

.search-container {
  background-color: #fff;
  padding: 20px;
  border-radius: 4px;
  margin-bottom: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
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

.feedback-detail {
  padding: 10px;
}

.feedback-content {
  white-space: pre-wrap;
  line-height: 1.5;
}

.reply-form {
  margin-top: 20px;
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